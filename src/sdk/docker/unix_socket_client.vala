namespace Sdk.Docker {

    public class UnixSocketClient : RestClient {

        const string HTTP_METHOD_HEADER_SUFFIX = " HTTP/1.1\r\nHost: localhost\r\n";

        private SocketClient client = new SocketClient();

        public UnixSocketClient(string socket_uri) {
            this.uri = socket_uri;
        }

        public override bool supportUri() {
            return uri.has_prefix("unix://");
        }

        /**
         * Send a message to docker daemon and return the response
         */
        public override Io.Response send(string method, string endpoint, string? body = null) throws Io.RequestError {
    
            StringBuilder request_builder = new StringBuilder("%s %s".printf(method, endpoint));
            
            request_builder.append(UnixSocketClient.HTTP_METHOD_HEADER_SUFFIX);

            if (body != null) {
                request_builder.append("Content-Length: %d\r\n".printf(body.length));
                //If there's a body, considerer it's an application/json type
                request_builder.append("Content-Type: application/json\r\n");
                request_builder.append("\r\n");
                request_builder.append(body);

            }

            //end of HTTP request
            request_builder.append("\r\n");

            string query = request_builder.str;

            var conn = this.create_connection();

            try {
                conn.output_stream.write(query.data);
            } catch(GLib.IOError e) {
                this.request_error(query);
                string err_message = "IO error : %s".printf(e.message);
                throw new Io.RequestError.FATAL(err_message);
            }

            var response = Io.SocketResponseFactory.create(new DataInputStream(conn.input_stream));

            this.response_success(response);

            return response;
        }

        /**
         * Send a message to docker daemon and return the response
         */
        public override Io.FutureResponse future_send(string method, string endpoint, string? body = null) throws Io.RequestError {

            StringBuilder request_builder = new StringBuilder("%s %s".printf(method, endpoint));
            
            request_builder.append(UnixSocketClient.HTTP_METHOD_HEADER_SUFFIX);

            if (body != null) {
                request_builder.append("Content-Length: %d\r\n".printf(body.length));
                //If there's a body, considerer it's an application/json type
                request_builder.append("Content-Type: application/json\r\n");
                request_builder.append("\r\n");
                request_builder.append(body);
            }

            //end of HTTP request
            request_builder.append("\r\n");

            string query = request_builder.str;
            
            Io.FutureResponse future_response = new Io.FutureResponse();
            
            GLib.Thread<int> thread = new GLib.Thread<int>("future_send", () => {
                var conn = this.create_connection();

                try {
                    conn.output_stream.write(query.data);
                } catch(GLib.IOError e) {
                    this.request_error(query);
                    string err_message = "IO error : %s".printf(e.message);
                    throw new Io.RequestError.FATAL(err_message);
                }
                
                Io.SocketResponseFactory.future_create(new DataInputStream(conn.input_stream), future_response);
                return 0;
            });

            return future_response;
        }

        /**
         * Create the connection to docker daemon
         */
        private SocketConnection? create_connection() throws Io.RequestError {
            try {
                
                var url = Dockery.Convert.Uri.get_url_from_uri(this.uri);
                return this.client.connect(
                    new UnixSocketAddress(url)
                );
                
            } catch (GLib.Error e) {
                this.request_error(e.message);
                string err_message = "%s :\n(%s)".printf(this.uri, e.message);
                throw new Io.RequestError.FATAL(err_message);
            }
        }
    }
}
