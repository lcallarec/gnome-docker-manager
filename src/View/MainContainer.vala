using View.Docker;
using Dockery;
using Dockery.DockerSdk;

namespace Dockery.View {

    public class MainContainer : Gtk.Box {

        public Gtk.HeaderBar headerbar = new AppHeaderBar(Config.APPLICATION_NAME, Config.APPLICATION_SUBNAME);
        public Gtk.InfoBar infobar = new Controls.MainInfoBar();
        public Gtk.Box local_docker_perspective = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        public SideBar sidebar;
        public Container.ListAll containers;
        public View.Image.ListAll images;
        public View.Volume.ListAll volumes;
        public Gtk.StackSwitcher perspective_switcher = new Gtk.StackSwitcher();
        public EventStream.LiveStreamComponent live_stream_component = new EventStream.LiveStreamComponent();
        private Gtk.Paned local_perspective_paned = new Gtk.Paned(Gtk.Orientation.VERTICAL);
      
        public MainContainer() {

            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);

            //Perspectives
            var perspectives = new Gtk.Stack();

            //Perspective switcher
            this.perspective_switcher = new Controls.PerspectiveSwitcher(perspectives);

            this.headerbar.pack_start(this.perspective_switcher);
            var docker_connect = new Controls.DockerConnect();
            this.headerbar.pack_end(docker_connect);

            //Perspective : Local Docker
            this.containers = new Container.ListAll().init(new Model.ContainerCollection());
            this.images = new View.Image.ListAll().init(new Model.ImageCollection());
            this.volumes = new View.Volume.ListAll().init(new Model.VolumeCollection());

            Gtk.Stack stack = new Gtk.Stack();
            stack.expand = true;
            stack.set_transition_type(Gtk.StackTransitionType.CROSSFADE);

            this.sidebar = new SideBar(stack);

            //Perspectives
            this.setup_local_docker_perspective(stack);
            perspectives.add_titled(local_perspective_paned, "local-docker", "Local Docker stack");
            this.pack_start(perspectives, true, true, 0);

            //Infobar
            this.pack_end(infobar, false, true, 0);
        }

        private void setup_local_docker_perspective(Gtk.Stack stack) {

            stack.add_named(containers, "containers");
            stack.add_named(images, "images");
            stack.add_named(volumes, "volumes");

            var main_view = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            main_view.pack_start(sidebar, false, true, 0);
            main_view.pack_start(new Gtk.Separator(Gtk.Orientation.VERTICAL), false, true, 0);
            main_view.pack_start(stack, false, true, 0);

            local_docker_perspective.pack_start(main_view, false, true);

            this.local_perspective_paned.add1(local_docker_perspective);
            this.local_perspective_paned.add2(this.live_stream_component);
            
            //Compute paned positions and limits
            this.local_perspective_paned.realize.connect(() => {
                int pos = this.local_perspective_paned.get_allocated_height() - 22;
                this.local_perspective_paned.position = pos;
            });
        }
   }
}
