namespace Ui.Docker.List {
    
    using global::Docker.Model;
        
   
    public abstract class BaseContainers : Flushable, ContainerViewable, ContainerActionable, Gtk.Box {

        protected Gtk.Notebook notebook;
        protected Gtk.Box empty_box;

        /**
         * Init the container view from a given (nullable) list of containers and return it
         */ 
        public BaseContainers init(global::Docker.Model.Containers? containers, bool show_after_refresh = true) {
            
            this.flush();
            
            if (null == containers) {
                this.notebook  =  null;
                this.empty_box = IconMessageBoxBuilder.create_icon_message_box("No container found", "docker-symbolic");
                this.pack_start(this.empty_box, true, true, 0);
                return this;
            }
            
            this.notebook  =  new Gtk.Notebook();
            this.empty_box = null;

            this.pack_start(this.notebook, true, true, 0);            
            foreach(ContainerStatus status in ContainerStatus.all()) {
                var c = containers.get_by_status(status);
                if (c.is_empty == false) {
                    this.hydrate(status, c);
                }
            }
            
            if (true == show_after_refresh) {
                this.show_all();
            }

            return this;
        }

        /**
         * Add new rows from containers array list
         */
        public int hydrate(ContainerStatus current_status, Gee.ArrayList<Container> containers) {

            int containers_count = 0;
            Gtk.ListBox list_box = new Gtk.ListBox();
            
            foreach(Container container in containers) {

                containers_count++;

                Gtk.ListBoxRow row = new Gtk.ListBoxRow();

                this.decorate_row(row);

                Gtk.Grid row_layout = new Gtk.Grid();
                row_layout.column_spacing = 5;
                row_layout.row_spacing = 0;

                row.add(row_layout);

                var label_name          = create_name_label(container);
                var label_id            = create_id_label(container);
                var label_creation_date = create_creation_date_label(container);
                var label_command       = create_command_label(container);

                Gtk.Separator separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);

                //attach (        Widget child,        int left, int top, int width = 1, int height = 1)
                row_layout.attach(label_name,          0, 0, 1, 1);
                row_layout.attach(label_id,            0, 1, 1, 1);
                row_layout.attach(label_command,       1, 0, 1, 1);
                row_layout.attach(label_creation_date, 1, 1, 1, 1);

                Gtk.Button button_start_stop = create_button_stop_start(ContainerStatus.is_active(current_status), container);
                row_layout.attach(button_start_stop,2, 0, 1, 1);

                Ui.Docker.Menu.ContainerMenu? menu = Ui.Docker.Menu.ContainerMenuFactory.create(container);
                if (null != menu) {
                    Gtk.MenuButton mb = new Gtk.MenuButton();
                    menu.show_all();
                    mb.popup = menu;

                    menu.container_status_change_request.connect((status, container) => {
                        this.container_status_change_request(status, container);
                    });

                    menu.container_remove_request.connect(() => {
                        this.container_remove_request(container);
                    });

                    menu.container_rename_request.connect(() => {
                        this.container_rename_request(container, label_name);
                    });
                    
                    menu.container_kill_request.connect(() => {
                        this.container_kill_request(container);
                    });


                    row_layout.attach(mb,              3, 0, 1, 1);
                }

                row_layout.attach(separator,           0, 2, 5, 2);

                list_box.insert(row, containers_count);
            }

            notebook.append_page(list_box, new Gtk.Label(ContainerStatusConverter.convert_from_enum(current_status)));

            return containers_count;
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
         * Decorate the row for specific gtk3+ versions
         */ 
        protected abstract void decorate_row(Gtk.ListBoxRow row);

        private Gtk.Button create_button_stop_start(bool is_active, Container container) {

            Ui.StartStopButton button = new Ui.StartStopButton.from_active_rule(() => {
                return is_active;
            });

            button.notify["active"].connect(() => {
                if (button.active) {
                    this.container_start_request(container);
                } else {
                    this.container_stop_request(container);
                }
            });

            return button;
        }

        /**
         * Create an id label
         */
        private Gtk.Label create_id_label(Container container) {

            var label = new Gtk.Label(container.id);
            label.halign = Gtk.Align.START;
            label.set_selectable(true);

            return label;
        }

        /**
         * Create a creation date label
         */
        private Gtk.Label create_creation_date_label(Container container) {

            var label = new Gtk.Label("%s: %s".printf("created at", container.created_at.to_string()));
            label.attributes = Fonts.get_minor();
            label.halign = Gtk.Align.START;
            label.set_selectable(true);

            return label;
        }

        /**
         * Create a command label
         */
        private Gtk.Label create_command_label(Container container) {

            var label = new Gtk.Label(container.command);
            label.halign = Gtk.Align.START;
            label.set_hexpand(true);
            label.set_selectable(true);

            return label;
        }

        /**
         * Create a names label
         */
        private Gtk.Label create_name_label(Container container) {

            var label = new Gtk.Label(container.name);
            label.halign = Gtk.Align.START;
            label.attributes = Fonts.get_em();
            label.set_selectable(true);

            return label;
        }
    }
}
