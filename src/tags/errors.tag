<errors>
  <section class="section">
    <div class="tile is-ancestor">
      <div class="tile is-parent">
        <div class="tile is-child is-8">
          <h1 class="title">{ opts.project }</h1>
        </div>
        <div class="tile is-child is-4 has-text-right">
          <a href="?status=#/projects/{ encodeURIComponent(opts.project) }">all</a>
          |
          <a href="?status=resolved#/projects/{ encodeURIComponent(opts.project) }">resolved</a>
          |
          <a href="?status=unresolved#/projects/{ encodeURIComponent(opts.project) }">unresolved</a>
        </div>
      </div>
    </div>
    <div class="tile is-ancestor">
      <div class="tile is-parent">
        <div class="tile is-child">
          <table class="table projects-errors">
            <tbody>
              <tr each="{ error, i in opts.errors }">
                <td><a href="#/projects/{ encodeURIComponent(error.project) }/errors/{ encodeURIComponent(error.message) }">{ error.message }</a></td>
                <td>{ error.type }</td>
                <td><span class="tag is-danger is-small">{ error.count }</span></td>
                <td>{ moment(error.lastUpdated).fromNow() }</td>
                <td class="has-text-right">
                  <a if={ error.status == 'unresolved' } class={ button: true, is-small: true, is-loading: error.isLoading } class="button is-small" onclick={ resolve }>
                    <span class="icon is-small">
                      <i class="fa fa-exclamation"></i>
                    </span>
                    <span>{ error.status }</span>
                  </a>
                  <a if={ error.status == 'resolved' } class={ button: true, is-small: true, is-loading: error.isLoading } class="button is-small" onclick={ unresolve }>
                    <span class="icon is-small">
                      <i class="fa fa-check"></i>
                    </span>
                    <span>{ error.status }</span>
                  </a>
                  <a class={ button: true, btn-delete: true, is-small: true, is-loading: error.isLoading  } class="button is-small" onclick={ delete }>
                    <span class="icon is-small">
                      <i class="fa fa-times"></i>
                    </span>
                    <span>delete</span>
                  </a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </section>

  <style scoped>
    .tag.is-danger {
      background-color: #EA513C;
    }
    .btn-delete {
      color: #DA5019;
    }
  </style>

  <script type="babel">
    const self = this;
    const project = opts.project;
    const req = opts.req;

    self.moment = opts.moment;

    const changeStatus = (e, status) => {
      const message = e.item.error.message;
      e.item.error.isLoading = true;
      self.update();
      req.patch('/projects/' + encodeURIComponent(project) + '/errors/' + encodeURIComponent(message), {
        status: status
      })
         .then((res) => {
           e.item.error.status = status;
         })
         .catch((err) => {
           throw new Error(err);
         })
         .then((data) => {
           e.item.error.isLoading = false;
           self.update();
         });
    };

    self.resolve = (e) => {
      changeStatus(e, 'resolved');
    }

    self.unresolve = (e) => {
      changeStatus(e, 'unresolved');
    }

    self.delete = (e) => {
      const message = e.item.error.message;
      if (!confirm('Are you sure you want to delete "' + message + '" ?')) {
        return;
      }
      e.item.error.isLoading = true;
      self.update();
      req.delete('/projects/' + encodeURIComponent(project) + '/errors/' + encodeURIComponent(message))
         .then((res) => {
           alert('"' + message + '" has been deleted');
           location.reload();
         })
         .catch((err) => {
           throw new Error(err);
           e.item.error.isLoading = false;
           self.update();
         });
    };
  </script>
</errors>
