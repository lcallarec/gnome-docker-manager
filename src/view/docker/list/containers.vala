namespace View.Docker.List {

    using global::Sdk.Docker.Model;
    using Dockery.View;


    public class Containers : Flushable, ContainerViewable, Signals.ContainerRequestAction, Gtk.Box {

        private Gtk.Notebook notebook;
        private Gtk.Box empty_box;
        
        private UserActions user_actions = UserActions.get_instance();

        public Containers() {
            user_actions.if_hasnt_feature_set(UserActionsTarget.CURRENT_CONTAINER_NOTEBOOK_PAGE, "0");
        }

        /**
         * Init the container view from a given collection of containers and return it
         */
        public Containers init(ContainerCollection containers, bool show_after_refresh = true) {

            this.flush();

            if (containers.is_empty) {

                this.notebook = null;
                this.empty_box = IconMessageBoxBuilder.create_icon_message_box("No container found", "docker-symbolic")    ;            
                
                this.pack_start(this.empty_box, true, true, 0);

                if (show_after_refresh == true) {
                    this.show_all();
                }

            } else {
            
                this.empty_box = null;
                this.notebook  = new Gtk.Notebook();

                this.pack_start(this.notebook, true, true, 0);

                int page_count = 0;
                foreach(ContainerStatus status in ContainerStatus.all()) {
                    var c = containers.get_by_status(status);
                    if (c.is_empty == false) {
                        page_count++;
                        this.hydrate(status, c);
                    }
                }

                notebook.switch_page.connect((page, page_num) => {
                    user_actions.set_feature(UserActionsTarget.CURRENT_CONTAINER_NOTEBOOK_PAGE, page_num.to_string());
                });

                if (true == show_after_refresh) {
                    this.show_all();

                    int current_page = user_actions.get_feature(UserActionsTarget.CURRENT_CONTAINER_NOTEBOOK_PAGE).to_int();
                    if (current_page + 1 > page_count) {
                        //-1 = last page
                        current_page = -1;
                    }
                    //This code should remain after show_all() invokation, because set_current_page will have no effets if the page is not shown yet
                    notebook.set_current_page(current_page);
                }
            }

            return this;
        }

        public void flush() {
            if (null != this.empty_box) {
                this.remove(this.empty_box);
            }

            if (null != this.notebook) {
                this.remove(this.notebook);
            }
        }

        /**
         * Add new rows from containers array list
         */
        private int hydrate(ContainerStatus current_status, ContainerCollection containers) {

            int containers_count = 0;

            Gtk.TreeIter iter;

            Gtk.ListStore liststore = new Gtk.ListStore(4, typeof (string),  typeof (string), typeof (string), typeof (string));
            liststore.clear();

            foreach(Container container in containers) {
                containers_count++;
                liststore.append(out iter);
                liststore.set(iter, 0, container.name, 1, container.id, 2, container.command, 3, container.created_at.to_string());
            }

            var tv = get_treeview(liststore);

            var selection = tv.get_selection();
            selection.set_mode(Gtk.SelectionMode.SINGLE);

            tv.button_press_event.connect((e) => {
                if (e.button == 3) {
                    Gtk.TreePath tp;
                    tv.get_path_at_pos((int) e.x, (int) e.y, out tp, null, null, null);

                    selection.select_path(tp);

                    Gtk.TreeModel m;
                    Gtk.TreeIter i;
                    selection.get_selected(out m, out i);

                    Value oid;
                    m.get_value(i, 1, out oid);

                    string id = oid as string;

                    if (containers.has_id(id)) {

                        Container container = containers.get_by_id(id);

                        View.Docker.Menu.ContainerMenu? menu = View.Docker.Menu.ContainerMenuFactory.create(container);
                        if (null != menu) {

                            menu.show_all();

                            menu.popup(null, null, null, e.button, e.time);

                            menu.container_status_change_request.connect((status, container) => {
                                this.container_status_change_request(status, container);
                            });

                            menu.container_remove_request.connect(() => {
                                this.container_remove_request(container);
                            });

                            menu.container_rename_request.connect(() => {
                                Gdk.Rectangle rect;
                                tv.get_cell_area (tp, tv.get_column(0), out rect);
                                rect.y = rect.y + rect.height;
                                this.container_rename_request(container, tv, rect);
                            });

                            menu.container_kill_request.connect(() => {
                                this.container_kill_request(container);
                            });

                            menu.container_start_request.connect(() => {
                                this.container_start_request(container);
                            });

                            menu.container_stop_request.connect(() => {
                                this.container_stop_request(container);
                            });

                            menu.container_restart_request.connect(() => {
                                this.container_restart_request(container);
                            });

                            menu.container_bash_in_request.connect(() => {
                                this.container_bash_in_request(container);
                            });

                        }
                    }

                    return true;
                }

                return false;
            });

            notebook.append_page(tv, new Gtk.Label(ContainerStatusConverter.convert_from_enum(current_status)));

            return containers_count;
        }

        /**
         * Decorate the row for specific gtk3+ versions
         */
        private void decorate_row(Gtk.ListBoxRow row) {

        }

        private Gtk.TreeView get_treeview(Gtk.ListStore liststore) {

            var treeview = new Gtk.TreeView();
            treeview.set_model(liststore);

            treeview.vexpand = true;
            treeview.hexpand = true;

            treeview.insert_column_with_attributes(-1, "Name",       new Gtk.CellRendererText(), "text", 0);
            treeview.insert_column_with_attributes(-1, "ID",         new Gtk.CellRendererText(), "text", 1);
            treeview.insert_column_with_attributes(-1, "Command",    new Gtk.CellRendererText(), "text", 2);
            treeview.insert_column_with_attributes(-1, "Created at", new Gtk.CellRendererText(), "text", 3);

            treeview.set_grid_lines(Gtk.TreeViewGridLines.HORIZONTAL);

            return treeview;

        }
    }
}
