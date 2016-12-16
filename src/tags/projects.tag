<projects>
  <section class="section">
    <h1 class="title">Projects</h1>
    <div class="tile is-ancestor">
      <div class="tile is-parent">
        <div class="tile is-child">
          <table class="table projects">
            <tbody>
              <tr each="{ project, i in opts.projects }">
                <td><a href="?status=unresolved#/projects/{ encodeURIComponent(project.name) }">{ project.name }</a></td>
                <td class="has-text-right">
                  <a class={ button: true, btn-delete: true, is-small: true, is-loading: project.isLoading  } onclick={ delete }>
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
    .btn-delete {
      color: #DA5019;
    }
  </style>

  <script type="babel">
    const self = this;
    const req = opts.req;

    self.delete = (e) => {
      const project = e.item.project.name;
      if (!confirm('Are you sure you want to delete "' + project + '" ?')) {
        return;
      }
      e.item.project.isLoading = true;
      self.update();
      req.delete('/projects/' + encodeURIComponent(project))
         .then((res) => {
           alert('"' + project + '" has been deleted');
           location.reload();
         })
         .catch((err) => {
           throw new Error(err);
           e.item.project.isLoading = false;
           self.update();
         });
    };
  </script>
</projects>
