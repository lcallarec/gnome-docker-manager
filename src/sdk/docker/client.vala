namespace Sdk.Docker {

    public interface Client : GLib.Object {
        
        public abstract Io.Response send(string method, string endpoint, string? body = null) throws Io.RequestError;
        public abstract Io.FutureResponse future_send(string method, string endpoint, string? body = null) throws Io.RequestError;
        public abstract bool supportUri();
                
        /**
         * This signal is emitted just after a valid and handled response has been created
         */
        public signal void response_success(Io.Response response);

        /**
         * This signal is emitted just after a request error
         */
        public signal void request_error(string data);

    }
}
