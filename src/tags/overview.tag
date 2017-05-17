<overview>
  <section class="section">
    <nav class="level">
      <p class="level-item">
        - <a class="link is-info" href="?status=unresolved#/projects/{ encodeURIComponent(opts.project) }">{ opts.project }</a>
      </p>
    </nav>

    <div class="tile is-ancestor">
      <div class="tile is-parent">
        <div class="tile is-child is-8">
          <h1 class="title">{ opts.message }</h1>
        </div>
        <div class="tile is-child is-4 has-text-right">
          <!-- @TODO buttons -->
        </div>
      </div>
    </div>

    <div class="container">
      <div>
        <h3>type</h3>
        <pre><code>{ opts.type }</code></pre>
      </div>
      <div>
        <h3>timestamp</h3>
        <pre><code>{ opts.moment(opts.timestamp).format('YYYY-MM-DDTHH:mm:ssZZ') }</code></pre>
      </div>
      <div>
        <h3>backtrace</h3>
        <pre><code>{ backtrace }</code></pre>
      </div>
      <div each="{ k, v in opts.meta }">
        <h3>{ k }</h3>
        <pre><code>{ JSON.stringify(v, null, 2) }</code></pre>
      </div>
    </div>

    <div class="container">
      <div class="tile is-ancestor">
        <div class="tile is-parent">
          <div class="tile is-child is-4">
            <h3>timeline</h3>
          </div>
          <div class="tile is-child is-8 has-text-right">
            <p class="period">
              [
              <input type="datetime-local" name="start" value="{opts.moment(opts.start).format('YYYY-MM-DDTHH:mm:ss')}"/> - <input type="datetime-local" name="end" value="{opts.moment(opts.end).format('YYYY-MM-DDTHH:mm:ss')}" />
              ]
              <a class={ button: true, is-small: true } onclick={ reload }>
                <span class="icon is-small">
                  <i class="fa fa-refresh"></i>
                </span>
              </a>
            </p>
          </div>
        </div>
      </div>
      <div id="timeseries">
      </div>
    </div>

    <div class="container">
      <div class="tile is-ancestor">
        <div class="tile is-parent">
          <div class="tile is-child">
            <h3>occurrences</h3>
            <table class="table occurrences">
              <tbody>
                <tr>
                  <th>timestamp</th>
                  <th>message</th>
                  <th>type</th>
                  <th>browser</th>
                  <th>url</th>
                </tr>
                <tr each="{ occurrence, k in opts.occurrences }">
                  <td>
                    <a href="#/projects/{ encodeURIComponent(occurrence.project) }/errors/{ encodeURIComponent(occurrence.message) }/occurrences/{ occurrence.reversedUnixtime }">
                      { occurrence.timestamp }
                    </a>
                  </td>
                  <td>
                    { occurrence.message }
                  </td>
                  <td>
                    { occurrence.type }
                  </td>
                  <td>
                    <i class="fa fa-{ occurrence.context.browser }" title="{ occurrence.context.userAgent }" aria-hidden="true"></i>
                  </td>
                  <td>
                    { occurrence.context.url }
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

  </section>

  <style scoped>
    h3, p.period {
      margin-top: 10px;
      font-weight: bold;
    }
    p.period .icon {
      margin-left: -2px;
    }
    pre code {
      background-color: whitesmoke;
      color: #4a4a4a;
      display: block;
      overflow-x: auto;
      padding: 16px 20px;
    }
    .c3-axis-x .tick {
      display: none;
    }
    .faultline-tooltip {
      padding: 2px;
      border-style: solid;
      border-color: blue;
      border-width: 3px;
      background-color: white;
      font-weight: bold;
    }
    .faultline-tooltip span {
      display: block;
      font-size: x-small;
    }
  </style>

  <script type="babel">
    // backtrace
    this.backtrace = '';
    opts.backtrace.forEach((t) => {
      this.backtrace += t.file + '(' + t.line + ')  ' +  t.function + "\n";
    });

    // occurrences
    const detector = {
      detectBrowserIcon: function(ua) {
        const parsed = opts.woothee.parse(ua);
        switch (parsed.name) {
          case 'Internet Explorer':
            return 'ie';
          case 'Edge':
            return 'edge';
          case 'Chrome':
            return 'chrome';
          case 'Safari':
            return 'safari';
          case 'Firefox':
            return 'firefox';
          case 'Opera':
            return 'opera';
        }
        return 'question-circle';
      }
    };
    opts.occurrences.forEach((o) => {
      o.context.browser = detector.detectBrowserIcon(o.context.userAgent);
      o.timestamp = opts.moment(o.timestamp).format('YYYY-MM-DDTHH:mm:ssZZ');
    });

    // timeline
    this.on('updated', () => {
      const labelX = 'x';
      const labelErrorCount = 'error count';
      let columnX = [labelX];
      let columnErrorCount = [labelErrorCount];
      let colors = {};
      colors[labelErrorCount] = 'E06A3B';

      opts.items.forEach((i) => {
        let formated = opts.moment(i.timestamp).format('YYYY-MM-DDTHH:mm:ssZZ');
        columnX.push(formated);
        columnErrorCount.push(i.count);
      });

      const start = opts.moment(opts.start).format('YYYY-MM-DDTHH:mm:ssZZ');
      const end = opts.moment(opts.end).format('YYYY-MM-DDTHH:mm:ssZZ');

      let chart = opts.c3.generate({
        bindto: '#timeseries',
        data: {
          x: 'x',
          xFormat: '%Y-%m-%dT%H:%M:%S%Z',
          columns: [
            columnX,
            columnErrorCount
          ],
          type: 'bar',
          colors: colors
        },
        legend: { show: false },
        bar: { width: 8 },
        tooltip: {
          contents: (d, defaultTitleFormat, defaultValueFormat, color) => {
            return '<div class="faultline-tooltip" style="border-color:#' + color(d[0].id) + ';">'
                 + d[0].value
                 + '<span style="color:#' + color(d[0].id) + '">'
                 + opts.moment(d[0].x).format('YYYY-MM-DDTHH:mm:ssZZ')
                 + '</span>'
                 + '</div>';
          }
        },
        subchart: { show: true },
        axis: {
          x: {
            min: start,
            max: end,
            type: 'timeseries',
            tick: {
              values: [start, end],
              format: '%Y-%m-%d %H:%M:%S%Z'
            }
          },
          y: {
            tick: {
              values: (v) => {
                let values = [0, 5];
                let max = v[1];
                let i = 10
                while (i < max) {
                  values.push(i);
                  i = i * 10;
                }
                return values;
              }
            }
          }
        }
      });
    });

    self.reload= (e) => {
      const start = this.start.value;
      const end = this.end.value;
      const url = '?start=' + start + '&end=' + end + '#/projects/' + encodeURIComponent(opts.project) + '/' + encodeURIComponent(opts.message);
      location.href = url;
    };
  </script>
</overview>
