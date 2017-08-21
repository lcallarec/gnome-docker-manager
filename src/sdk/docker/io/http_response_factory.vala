namespace Sdk.Docker.Io {

    /**
     * Response from an http request to a docker remote api
     */
    public class HttpResponseFactory : GLib.Object {

        public static Response create(Soup.Message message) {
            
            Response response = new Response();

            response.status = (int) message.status_code;

            var headers = new Gee.HashMap<string, string>();
            message.response_headers.foreach((name, value) => {
                headers.set(name, value);
            });

            response.headers = headers;
            
            try {
                
                response.payload = (string) message.response_body.data;
                               
            } catch (Error e) {
                throw e;
            }

            return response;
        }

        /**
         * SocketResponse that 
         */ 
        public static FutureResponse future_create(Soup.Message message, FutureResponse response) {
            
            response.status = (int) message.status_code;

            var headers = new Gee.HashMap<string, string>();
            message.response_headers.foreach((name, value) => {
                headers.set(name, value);
            });

            response.headers = headers;
            
            try {
                
                response.payload = (string) message.response_body.data;
                               
            } catch (Error e) {
                throw e;
            }

            return response;
                
        }
        
    }
}
