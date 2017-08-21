namespace Sdk.Docker {

    public class HttpClient : RestClient {

        private Soup.Session session = new Soup.Session();

        public HttpClient(string http_uri) {
            this.uri = http_uri;
        }

        public override bool supportUri() {
            return uri.has_prefix("http://") || uri.has_prefix("https://");
        }

        /**
         * Send a message to docker daemon and return the response
         */
        public override Io.Response send(string method, string endpoint, string? body = null) throws Io.RequestError {

            var message = new Soup.Message(method, this.uri + endpoint);
            if (body != null) {
                var request_body = new Soup.MessageBody();
                request_body.append_take(body.data);
            }
            
            try {
                session.send_message(message);
            } catch(GLib.IOError e) {
                //this.request_error(query);
                string err_message = "IO error : %s".printf(e.message);
                throw new Io.RequestError.FATAL(err_message);
            }

            var response = Io.HttpResponseFactory.create(message);

            //this.response_success(response);
            return response;
        }

        /**
         * Send a message to docker daemon and return the future response
         */
        public override Io.FutureResponse future_send(string method, string endpoint, string? body = null) throws Io.RequestError {
            var message = new Soup.Message(method, this.uri + endpoint);
            
            if (body != null) {
                var request_body = new Soup.MessageBody();
                request_body.append_take(body.data);
            }

           Io.FutureResponse future_response = new Io.FutureResponse();
            
            GLib.Thread<int> thread = new GLib.Thread<int>("future_send", () => {

                try {
                    session.send_message(message);
                } catch(GLib.IOError e) {
                    //this.request_error(query);
                    string err_message = "IO error : %s".printf(e.message);
                    throw new Io.RequestError.FATAL(err_message);
                }
                
                Io.HttpResponseFactory.future_create(message, future_response);
                return 0;
            });

            return future_response;
        }

    }
}
