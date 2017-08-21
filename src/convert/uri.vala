namespace Dockery.Convert.Uri
{

    public static string get_scheme_from_uri(string uri) {
        return get_nth_uri_part(uri, 0);
    }
    
    public static string get_url_from_uri(string uri) {
        return get_nth_uri_part(uri, 1);
    }
    
    private static string[] split_uri(string uri) {
        return uri.split("://");
    }
    
    private static string get_nth_uri_part(string uri, int8 nth) {
        var uri_parts = split_uri(uri);
        
        return uri_parts[nth];
    }

}
