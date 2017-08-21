namespace Sdk.Docker {

    public abstract class RestClient : Client, GLib.Object {
        
        public string uri { get; protected set;}
        
        public abstract Io.Response send(string method, string endpoint, string? body = null) throws Io.RequestError;
        public abstract Io.FutureResponse future_send(string method, string endpoint, string? body = null) throws Io.RequestError;        
        public abstract bool supportUri();
    }

}
