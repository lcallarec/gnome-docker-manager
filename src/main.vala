/*
 * DockerManager.vala
 *
 * Laurent Callarec <l.callarec@gmail.com>
 *
 */
public class DockerManager : Gtk.Window {

    public const string APPLICATION_NAME = "Dockery";

    public const string APPLICATION_SUBNAME = "A graphical Docker client";

    private ApplicationController ac;

    public static void main (string[] args) {
        Gtk.init(ref args);

        if (Environment.get_variable("RTL") != null) {
            Gtk.Widget.set_default_direction(Gtk.TextDirection.RTL);
        }
        else {
            Gtk.Widget.set_default_direction(Gtk.TextDirection.LTR);
        }

        if (args[1] == "--dark-theme") {
            Gtk.Settings.get_default().set("gtk-application-prefer-dark-theme", true);
        }

        var dm = new DockerManager();
        dm.show_all();

        Gtk.main();
    }

    public DockerManager () {

        Object(window_position: Gtk.WindowPosition.CENTER);

        this.set_default_size(700, 600);
        this.destroy.connect(Gtk.main_quit);

        //Css provider
        var provider = this.create_css_provider("resources/css/main.css");

        var screen = Gdk.Screen.get_default();
        Gtk.StyleContext.add_provider_for_screen(screen, provider, 600);

        //Add application icons to degault icon theme
        this.set_icon_theme("resources/icons/");

        //Window Application name & Icon
        this.set_wmclass(DockerManager.APPLICATION_NAME, DockerManager.APPLICATION_NAME);
        this.set_icon_name("docker-icon");

        //View container
        Dockery.View.MainContainer main_container = new Dockery.View.MainContainer();
        this.add(main_container);

        //// START
        this.set_titlebar(main_container.headerbar);

        //ApplicationController
        this.ac = new ApplicationController(this, main_container, new MessageDispatcher(main_container.infobar));
        ac.boot();
    }

    protected Gtk.CssProvider create_css_provider(string css_path) {

        var provider = new Gtk.CssProvider();

        #if GTK_LTE_3_14
        provider.load_from_path(css_path);
        #endif

        #if GTK_GTE_3_16
        provider.load_from_resource("/org/lcallarec/dockery/" + css_path);
        #endif

        return provider;
    }

    protected void set_icon_theme(string icon_path) {
        #if GTK_GTE_3_16
        new Gtk.IconTheme().get_default().add_resource_path("/org/lcallarec/dockery/" + icon_path);
        #endif
    }
}

/**
 * Dispatch messages
 */
public class MessageDispatcher : GLib.Object {

    private Gtk.InfoBar infobar;

    private Gtk.Label label;

    public MessageDispatcher(Gtk.InfoBar bar) {
        infobar = bar;
        label   = new Gtk.Label(null);
        label.wrap = true;
        label.wrap_mode = Pango.WrapMode.WORD_CHAR;
        infobar.get_content_area().add(label);
    }

    public void dispatch(Gtk.MessageType type, string message) {
        infobar.set_message_type(type);
        label.label = message;
        infobar.show();
        label.show();
    }
}
