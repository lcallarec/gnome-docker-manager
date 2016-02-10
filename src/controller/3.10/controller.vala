/*
 * ApplicationController is listening to all signals emitted by the view layer
 */
public class ApplicationController : BaseApplicationController {
    
    public ApplicationController(Gtk.Window window, Ui.MainApplicationView view, MessageDispatcher message_dispatcher) {
        base(window, view, message_dispatcher);
    }
    
    protected override void handle_container_rename(Docker.Model.Container container, Gtk.Label label) {

    }
}
