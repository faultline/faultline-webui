<overview>
  <section class="section">
    <nav class="level">
      <p class="level-item">
        - <a class="link is-info" href="?status=unresolved#/projects/{ encodeURIComponent(opts.project) }">{ opts.project }</a>
      </p>
    </nav>

    <h1 class="title">{ opts.message }</h1>
    <div class="container">
      <div>
        <h3>type</h3>
        <pre><code>{ opts.type }</code></pre>
      </div>
      <div>
        <h3>timestamp</h3>
        <pre><code>{ opts.timestamp }</code></pre>
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
      <h3>timeline [{opts.moment(opts.start).format('YYYY-MM-DDTHH:mm:ssZZ')} - {opts.moment(opts.end).format('YYYY-MM-DDTHH:mm:ssZZ')}]</h3>
      <div id="timeseries">
      </div>
    </div>
  </section>

  <style scoped>
    h3 {
      margin-top: 10px;
      font-weight: bold;
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
  </script>
</overview>
