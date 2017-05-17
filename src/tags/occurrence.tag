<occurrence>
  <section class="section">
    <nav class="level">
      <p class="level-item">
        - <a class="link is-info" href="?status=unresolved#/projects/{ encodeURIComponent(opts.project) }">{ opts.project }</a>
        - <a class="link is-info" href="#/projects/{ encodeURIComponent(opts.project) }/errors/{ encodeURIComponent(opts.message) }">{ opts.message }</a>
        - { opts.moment(opts.timestamp).format('YYYY-MM-DDTHH:mm:ssZZ') }
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
  </script>
</occurrence>
