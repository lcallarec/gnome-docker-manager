namespace Sdk.Docker {

    /**
     * Containers related endpoints
     *
     * Available features :
     * - List containers
     * - Start a container
     * - Stop a container
     * - Rename a container
     * - Kill a container
     * - Pause a container
     * - Unpause a container
     * - Restart a container
     * - Remove a container
     * - Attach to a container
     * - Create a container
     *
     * Missing features :
     * - Inspect a container
     * - List processes running inside a container
     * - Export a container
     * - Get container stats based on resource usage
     * - Resize a container TTY
     * - Attach to a container (WS)
     * - Wait a container
     * - Copy from a container
     * - Retrieve information about container files & folders
     * - Get an archive of a filesystem resource in a container
     * - Extract an archive of files or folders to a directory in a container
     */
    public class ContainerEndpoint : Endpoint {

        public ContainerEndpoint(Client client) {
            base(client);
        }

        /**
         * Retrieve a list of containers
         *
         * See [[https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#list-containers]]
         */
        public Model.ContainerCollection list(Model.ContainerStatus status) throws Io.RequestError {

            try {

                string _status = Model.ContainerStatusConverter.convert_from_enum(status);

                var filters = new Gee.HashMap<string, Gee.ArrayList<string>>();
                var statuses = new Gee.ArrayList<string>();
                statuses.add(_status);
                filters.set("status", statuses);

                filter_builder.add_json_filter("filters", filters);

                var message_builder = new StringBuilder("/containers/json");
                message_builder.append(filter_builder.build());
                return parse_containers_list_payload(this.client.send("GET", message_builder.str).payload, status);

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while fetching container list from docker daemon : %s".printf(e.message));
            }
        }

        /**
         * Pause a single container
         *
         * See [[https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#pause-a-container]]
         */
        public void pause(Sdk.Docker.Model.Container container) throws Io.RequestError {

            try {
                var response = this.client.send("POST", "/containers/%s/pause".printf(container.id));

                var error_messages = create_error_messages();
                error_messages.set(404, "No such container");

                this.throw_error_from_status_code(204, response, error_messages);

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while pausing container %s : %s".printf(container.id, e.message));
            }
        }

        /**
         * Unpause a single container
         *
         * Se See [[https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#unpause-a-container]]
         */
        public void unpause(Sdk.Docker.Model.Container container) throws Io.RequestError {

            try {
                var response = this.client.send("POST", "/containers/%s/unpause".printf(container.id));

                var error_messages = create_error_messages();
                error_messages.set(304, "Container already started");
                error_messages.set(404, "No such container");

                this.throw_error_from_status_code(204, response, error_messages);

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while unpausing container %s : %s".printf(container.id, e.message));
            }
        }

        /**
         * Restart a single container
         *
         * See [[https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#/restart-a-container]]
         */
        public void restart(Sdk.Docker.Model.Container container) throws Io.RequestError {

            try {
                var response = this.client.send("POST", "/containers/%s/restart".printf(container.id));

                var error_messages = create_error_messages();
                error_messages.set(404, "No such container");

                this.throw_error_from_status_code(204, response, error_messages);

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while restarting container %s : %s".printf(container.id, e.message));
            }
        }

        /**
         * Remove a single container
         * Force option : when set to true, will force the removal of running containers
         */
        public void remove(Sdk.Docker.Model.Container container, bool force = false) throws Io.RequestError {

            try {

                StringBuilder message = new StringBuilder("/containers/%s".printf(container.id));

                if (force == true) {
                    message.append("?force=true");
                }

                var response = this.client.send("DELETE", message.str);

                var error_messages = create_error_messages();
                error_messages.set(404, "No such container");

                this.throw_error_from_status_code(204, response, error_messages);

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while killing container %s : %s".printf(container.id, e.message));
            }
        }

        /**
         * Start a single container
         *
         * See See [[https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#start-a-container]]
         */
        public void start(Sdk.Docker.Model.Container container) throws Io.RequestError {

            try {
                var response = this.client.send("POST", "/containers/%s/start".printf(container.id));

                var error_messages = create_error_messages();
                error_messages.set(304, "Container already started");
                error_messages.set(404, "No such container");

                this.throw_error_from_status_code(204, response, error_messages);

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while starting container %s : %s".printf(container.id, e.message));
            }
        }

        /**
         * Start a single container
         *
         * See [[https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#stop-a-container]]
         */
        public void stop(Sdk.Docker.Model.Container container) throws Io.RequestError {

            try {
                var response = this.client.send("POST", "/containers/%s/stop".printf(container.id));

                var error_messages = create_error_messages();
                error_messages.set(304, "Container already stopped");
                error_messages.set(404, "No such container");

                this.throw_error_from_status_code(204, response, error_messages);

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while killing container %s : %s".printf(container.id, e.message));
            }
        }

        /**
         * Kill a single container
         *
         * See See [[https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#kill-a-container]]
         */
        public void kill(Sdk.Docker.Model.Container container) throws Io.RequestError {

            try {
                var response = this.client.send("POST", "/containers/%s/kill".printf(container.id));

                var error_messages = create_error_messages();
                error_messages.set(304, "Container already stopped");
                error_messages.set(404, "No such container");

                this.throw_error_from_status_code(204, response, error_messages);

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while stoping container %s : %s".printf(container.id, e.message));
            }
        }

        /**
         * Rename a single container
         *
         * See See [[https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#rename-a-container]]
         */
        public void rename(Sdk.Docker.Model.Container container) throws Io.RequestError {

            try {
                var response = this.client.send("POST", "/containers/%s/rename?name=%s".printf(container.id, container.name));

                var error_messages = create_error_messages();
                error_messages.set(404, "No such container");
                error_messages.set(409, "Name already assigned to another container");

                this.throw_error_from_status_code(204, response, error_messages);

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while renaming container %s : %s".printf(container.id, e.message));
            }
        }

        /**
         * Get containers that were created from the given image
         *
         * See [[https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#list-containers]]
         */
        public Model.ContainerCollection find_by_image(Sdk.Docker.Model.Image image) throws Io.RequestError {

            try {

                var container_collection = new Model.ContainerCollection();

                foreach(Model.ContainerStatus status in Model.ContainerStatus.all()) {

                    Model.ContainerCollection containers = list(status);

                    foreach(Model.Container container in containers) {
                        if (image.full_id == container.image_id) {
                            container_collection.add(container);
                        }
                    }
                }

                return container_collection;

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while fetching containers by image (%s)".printf(e.message));
            }
        }
        
        /**
         * Get containers that were created from the given images
         *
         * See [[https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#list-containers]]
         */
        public Model.ContainerCollection find_by_images(Sdk.Docker.Model.ImageCollection images) throws Io.RequestError {

            Model.ContainerCollection containers = new Model.ContainerCollection();
            
            try {
                foreach(Model.Image image in images) {
                    containers.add_collection(this.find_by_image(image));
                }

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while fetching containers for images [%s](%s)".printf(string.join(", ", containers.get_ids()), e.message));
            }
            
            return containers;
        }

        /**
         * Create a container from a given Image
         * See [[https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#/create-a-container]]
         */
        public void create(Sdk.Docker.Model.ContainerCreate container_create) throws Io.RequestError {

            try {
                var response = this.client.send("POST", "/containers/create", container_create.serialize());

                var error_messages = create_error_messages();
                error_messages.set(400, "Bad parameter");
                error_messages.set(404, "No such container");
                error_messages.set(406, "Impossible to attach (container not running)");
                error_messages.set(409, "Conflict");

                this.throw_error_from_status_code(201, response, error_messages);

            } catch (Io.RequestError e) {
                throw new Io.RequestError.FATAL("Error while creating container from image %s".printf(container_create.image.id));
            }
        }

        /**
         * Parse containers payload
         */
        private Model.ContainerCollection parse_containers_list_payload(string payload, Model.ContainerStatus status) {

            Model.ContainerCollection containers = new Model.ContainerCollection();

            try {
                var parser = new Json.Parser();
                parser.load_from_data(payload);

                var nodes = parser.get_root().get_array().get_elements();

                foreach (unowned Json.Node node in nodes) {

                    var names_node = node.get_object().get_array_member("Names");
                    uint len       = names_node.get_length();
                    string[] names = {};

                    for (int i = 0; i <= len - 1; i++) {
                        names[i] = names_node.get_string_element(i);
                    }

                    containers.add(new Model.Container.from(
                        node.get_object().get_string_member("Id"),
                        node.get_object().get_int_member("Created"),
                        node.get_object().get_string_member("Command"),
                        node.get_object().get_string_member("ImageID"),
                        names,
                        status
                    ));
                }
            } catch (Error e) {
                return containers;
            }

            return containers;
        }
    }
}
