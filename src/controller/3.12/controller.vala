/*
 * ApplicationController is listening to all signals emitted by the view layer
 */
public class ApplicationController : BaseApplicationController {
    
    public ApplicationController(Gtk.Window window, Ui.MainApplicationView view, MessageDispatcher message_dispatcher) {
        base(window, view, message_dispatcher);
    }
    
    protected override void handle_container_rename(Docker.Model.Container container, Gtk.Label label) {
        
        var pop = new Gtk.Popover(label);
        pop.position = Gtk.PositionType.BOTTOM;
         
        var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        box.margin = 5;
        box.pack_start(new Gtk.Label("New name"), false, true, 5);
         
        var entry = new Gtk.Entry();
        entry.set_text(label.get_text());
        
        box.pack_end(entry, false, true, 5);
        
        pop.add(box);
         
        entry.activate.connect (() => {
            try {
                container.name = entry.text;
                
                repository.containers().rename(container);
                
                this.init_container_list();
                
            } catch (Docker.IO.RequestError e) {
                message_dispatcher.dispatch(Gtk.MessageType.ERROR, (string) e.message);
            }
        });
         
        pop.show_all();   
    }
}
