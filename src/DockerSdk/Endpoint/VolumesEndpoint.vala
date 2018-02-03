namespace Dockery.DockerSdk.Endpoint {

    using global::Dockery.DockerSdk.Serializer;

    public class VolumeEndpoint : Endpoint {

        private VolumeDeserializerInterface volume_deserializer;

         public VolumeEndpoint(Client.Client client, VolumeDeserializerInterface volume_deserializer) {
             base(client);
             this.volume_deserializer = volume_deserializer;
         }

         /**
          * Get a list of all images
          * https://docs.docker.com/engine/reference/api/docker_remote_api_v1.21/#list-containers
          */
         public Model.VolumeCollection list() throws Io.RequestError {

            try {
                return parse_volume_list_payload(this.client.send("GET", "/volumes").payload);
            } catch (Io.RequestError e) {
                 throw new Io.RequestError.FATAL("Error while fetching volumes list from docker daemon : %s".printf(e.message));
            }
        }
       
        /**
         * Parse volume list response payload
         */
        private Model.VolumeCollection parse_volume_list_payload(string payload) {
            try {
                return this.volume_deserializer.deserializeList(payload);
            } catch (Error e) {
                return new Model.VolumeCollection();
            }
            
        }
    }
}
