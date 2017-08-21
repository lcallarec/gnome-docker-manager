/**
 * ApplicationController is listening to all signals emitted by the view layer
 */
public class ApplicationController : GLib.Object {

    protected Sdk.Docker.Repository? repository;
    protected Gtk.Window window;
    protected MessageDispatcher message_dispatcher;
    protected View.MainApplicationView view;

    public ApplicationController(Gtk.Window window, View.MainApplicationView view, MessageDispatcher message_dispatcher) {
        this.window             = window;
        this.view               = view;
        this.message_dispatcher = message_dispatcher;

        string? docker_endpoint = discover_connection();
        if (null != docker_endpoint) {
            __connect(docker_endpoint);
        } else {
            this.view.headerbar.on_docker_daemon_connect(docker_endpoint, false);
            message_dispatcher.dispatch(Gtk.MessageType.ERROR, "Can't locate docker daemon");
        }
    }


    public void listen_container_view() {

        view.containers.container_status_change_request.connect((requested_status, container) => {

            try {
                string message = "";
                if (requested_status == Sdk.Docker.Model.ContainerStatus.PAUSED) {
                    repository.containers().pause(container);
                    message = "Container %s successfully unpaused".printf(container.id);
                } else if (requested_status == Sdk.Docker.Model.ContainerStatus.RUNNING) {
                    repository.containers().unpause(container);
                    message = "Container %s successfully paused".printf(container.id);
                }
                this.init_container_list();
                message_dispatcher.dispatch(Gtk.MessageType.INFO, message);

            } catch (Sdk.Docker.Io.RequestError e) {
                message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
            }
        });

        view.containers.container_remove_request.connect((container) => {

            Gtk.MessageDialog msg = new Gtk.MessageDialog(
                window, Gtk.DialogFlags.MODAL,
                Gtk.MessageType.WARNING,
                Gtk.ButtonsType.OK_CANCEL,
                "Really remove the container %s (%s)?".printf(container.name, container.id)
            );

            msg.response.connect((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.OK:

                        try {
                            repository.containers().remove(container);
                            this.init_container_list();
                        } catch (Sdk.Docker.Io.RequestError e) {
                            message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
                        }

                        break;
                    case Gtk.ResponseType.CANCEL:
                        break;
                    case Gtk.ResponseType.DELETE_EVENT:
                        break;
                }

                msg.destroy();

            });

            msg.show();
        });

        view.containers.container_start_request.connect((container) => {

            try {
                repository.containers().start(container);
                string message = "Container %s successfully started".printf(container.id);
                this.init_container_list();
                message_dispatcher.dispatch(Gtk.MessageType.INFO, message);

            } catch (Sdk.Docker.Io.RequestError e) {
                message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
                this.init_container_list();
            }
        });

        view.containers.container_bash_in_request.connect((container) => {

            try {

                var term_window = new Gtk.Window();

                var titlebar = new Gtk.HeaderBar();
                titlebar.title = "Bash-in %s".printf(container.name);
                titlebar.show_close_button = true;

                term_window.set_titlebar(titlebar);

                var term = new View.Docker.Terminal.from_bash_in_container(container);
                term.parent_container_widget = term_window;
                term.start();

                term_window.window_position = Gtk.WindowPosition.MOUSE;
                term_window.transient_for = window;
                term_window.add(term);
                term_window.show_all();

            } catch (Error e) {
                message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
            }
        });

        view.containers.container_stop_request.connect((container) => {
            try {

                repository.containers().stop(container);
                string message = "Container %s successfully stopped".printf(container.id);
                this.init_container_list();
                message_dispatcher.dispatch(Gtk.MessageType.INFO, message);

            } catch (Sdk.Docker.Io.RequestError e) {
                message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
            }
        });

        view.containers.container_kill_request.connect((container) => {

            try {
                repository.containers().kill(container);
                string message = "Container %s successfully killed".printf(container.id);
                this.init_container_list();
                message_dispatcher.dispatch(Gtk.MessageType.INFO, message);

            } catch (Sdk.Docker.Io.RequestError e) {
                message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
            }
        });

        view.containers.container_restart_request.connect((container) => {

            try {
                repository.containers().restart(container);
                string message = "Container %s successfully restarted".printf(container.id);
                this.init_container_list();
                message_dispatcher.dispatch(Gtk.MessageType.INFO, message);

            } catch (Sdk.Docker.Io.RequestError e) {
                message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
            }
        });

        view.containers.container_rename_request.connect((container, relative_to, pointing_to) => {
            this.handle_container_rename(container, relative_to, pointing_to);
        });
    }

    public void listen_image_view() {

         view.images.images_remove_request.connect((images) => {

            /** Find containers created from the images we want to remove */

            Sdk.Docker.Model.ContainerCollection containers = this.repository.containers().find_by_images(images);
            
            var dialog = new View.Docker.Dialog.RemoveImagesDialog(images, containers, window);

            dialog.response.connect((source, response_id) => {

                switch (response_id) {
                    case Gtk.ResponseType.APPLY:
                        try {
                            if (containers.size > 0) {
                                foreach(Sdk.Docker.Model.ContainerStatus status in Sdk.Docker.Model.ContainerStatus.all()) {
                                    foreach(Sdk.Docker.Model.Container container in containers.get_by_status(status)) {
                                        this.repository.containers().remove(container, true);
                                        message_dispatcher.dispatch(Gtk.MessageType.INFO, "Container %s successfully removed".printf(container.name));
                                    }
                                }
                            }
                            
                            foreach (Sdk.Docker.Model.Image image in images) {
                                this.repository.images().remove(image, true);
                                message_dispatcher.dispatch(Gtk.MessageType.INFO, "Image %s successfully removed".printf(image.name));
                            }

                            message_dispatcher.dispatch(Gtk.MessageType.INFO, "All images and containers being used successfully removed");

                        } catch (Sdk.Docker.Io.RequestError e) {
                            message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
                        }

                        this.init_container_list();
                        this.init_image_list();

                        break;
                    case Gtk.ResponseType.CANCEL:
                        break;
                    case Gtk.ResponseType.DELETE_EVENT:
                        break;
                    case Gtk.ResponseType.CLOSE:
                        break;
                }

                dialog.destroy();

            });

            dialog.show_all();
        });

        view.images.image_create_container_request.connect((image) => {

            try {
                this.repository.containers().create(new Sdk.Docker.Model.ContainerCreate.from_image(image));
                this.init_container_list();
            } catch (Sdk.Docker.Io.RequestError e) {
                message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
            }

        });

        view.images.image_create_container_with_request.connect((image) => {

            try {

                var dialog = new View.Docker.Dialog.CreateContainerWith(image, window);

                dialog.response.connect((source, response_id) => {

                    switch (response_id) {
                        case Gtk.ResponseType.APPLY:

                            Gee.HashMap<string, string> data = dialog.get_view_data();
                            this.repository.containers().create(new Sdk.Docker.Model.ContainerCreate.from_hash_map(image, data));
                            dialog.destroy();
                            this.init_container_list();
                            break;

                        case Gtk.ResponseType.CANCEL:
                        case Gtk.ResponseType.DELETE_EVENT:
                        case Gtk.ResponseType.CLOSE:
                            dialog.destroy();
                            break;
                    }
            });

            dialog.show_all();

            } catch (Error e) {
                message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
            }

        });
    }

    public void listen_headerbar() {

        view.headerbar.docker_daemon_connect_request.connect((docker_path) => {

            try {
                __connect(docker_path);
            } catch (Error e) {
                this.view.headerbar.on_docker_daemon_connect(
                    docker_path,
                    false,
                    new Notification.Message(Gtk.MessageType.ERROR, "Can't connect  docker daemon at %s".printf(docker_path))
                );
            }
        });

        view.headerbar.docker_daemon_disconnect_request.connect(() => {
            __disconnect();
        });

        view.headerbar.docker_daemon_autoconnect_request.connect(() => {
            string? docker_endpoint = discover_connection();
            if (null != docker_endpoint) {
                __connect(docker_endpoint);
            } else {
                this.view.headerbar.on_docker_daemon_connect(docker_endpoint, false, new Notification.Message(Gtk.MessageType.ERROR, "Can't locate docker daemon"));
            }
        });
    }

    public void listen_docker_hub() {

        view.headerbar.search_image_in_docker_hub.connect((target, term) => {

            try {
                Sdk.Docker.Model.HubImage[] images =  repository.images().search(term);
                target.set_images(images);
            } catch (Sdk.Docker.Io.RequestError e) {
                message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
            }
        });

        view.headerbar.pull_image_from_docker_hub.connect((target, image) => {

            var decorator = new View.Docker.Decorator.CreateImageDecorator(target.message_box_label);
            var future_response = repository.images().future_pull(image);

            future_response.on_payload_line_received.connect((line) => {

                if (null != line) {
                    try {
                        decorator.update(line);
                    } catch (Error e) {
                        message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
                    }
                }
            });

            future_response.on_finished.connect(() => {
                try {
                    decorator.update(null);
                } catch (Error e) {
                    message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
                }
            });

        });
    }

    protected void init_image_list() throws Sdk.Docker.Io.RequestError {
        Sdk.Docker.Model.ImageCollection images = new Sdk.Docker.Model.ImageCollection();
        try {
            images = repository.images().list();
        } catch (Sdk.Docker.Io.RequestError e) {
            message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
        } finally {
            this.view.images.init(images);
        }
    }

    protected void init_container_list() throws Sdk.Docker.Io.RequestError {

        var container_collection = new Sdk.Docker.Model.ContainerCollection();

        foreach(Sdk.Docker.Model.ContainerStatus status in Sdk.Docker.Model.ContainerStatus.all()) {
            var containers = repository.containers().list(status);
            container_collection.add_collection(containers);
        }

        this.view.containers.init(container_collection);
    }

    protected bool __connect(string docker_endpoint) throws Error {

        repository = create_repository(docker_endpoint);
        
        if (repository != null) {
            
            repository.connected.connect((repository) => {
                docker_daemon_post_connect(docker_endpoint);
            });

            repository.connect();

            return true;
        }
        
        return false;
        
    }

     protected bool __disconnect() {

        this.view.headerbar.on_docker_daemon_connect(null, false);

        repository = null;

        message_dispatcher.dispatch(Gtk.MessageType.INFO, "Disconnected from Docker daemon");

        return true;
    }

    protected string? discover_connection() {

        var endpoint_discovery = new Sdk.Docker.UnixSocketEndpointDiscovery();

        return endpoint_discovery.discover();
    }


    protected Sdk.Docker.Repository? create_repository(string uri) {

        Sdk.Docker.Client? client = Sdk.Docker.ClientFactory.create_from_uri(uri);
        
        if (client != null) {
            return new Sdk.Docker.Repository(client);
        }
        
        message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) "Failed to connect to %s".printf(uri));
        
        return null;
        
    }

    protected void handle_container_rename(Sdk.Docker.Model.Container container, Gtk.Widget relative_to, Gdk.Rectangle pointing_to) {

        #if GTK_GTE_3_16
        var pop = new Gtk.Popover(relative_to);
        pop.position = Gtk.PositionType.BOTTOM;
        pop.pointing_to = pointing_to;

        var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        box.margin = 5;
        box.pack_start(new Gtk.Label("New name"), false, true, 5);

        var entry = new Gtk.Entry();
        entry.set_text(container.name);

        box.pack_end(entry, false, true, 5);

        pop.add(box);

        entry.activate.connect (() => {
            try {
                container.name = entry.text;

                repository.containers().rename(container);

                this.init_container_list();

            } catch (Sdk.Docker.Io.RequestError e) {
                message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
            }
        });

        pop.show_all();
        #endif
    }


    protected void docker_daemon_post_connect(string docker_endpoint) {

        try {
            this.init_image_list();
            this.init_container_list();
            this.view.headerbar.on_docker_daemon_connect(docker_endpoint, true);
            message_dispatcher.dispatch(Gtk.MessageType.INFO, "Connected to docker daemon");
        } catch (Sdk.Docker.Io.RequestError e) {
            message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
            this.view.images.init(new Sdk.Docker.Model.ImageCollection());
            this.view.containers.init(new Sdk.Docker.Model.ContainerCollection() );
        }
    }
}
