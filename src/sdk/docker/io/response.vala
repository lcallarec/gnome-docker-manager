namespace Sdk.Docker.Io {

    /**
     * Generic response
     */
    public class Response : GLib.Object {

        /** Signals */
        public signal void on_status_received(int status);
        public signal void on_headers_received(Gee.HashMap<string, string> headers);
        public signal void on_payload_line_received(string line_payload);
        public signal void on_finished();

        public string? payload { get; set;}

        public int status { get; set;}

        public Gee.HashMap<string, string> headers { get; set;}
    }
}
