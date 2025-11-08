/// @desc A simple implementation of the event subject, managing its observers and sending events to them.
/// @arg {Any} [sender]         The entity passed as the event sender.
function CimpliEventSubject(_sender = undefined) constructor {
    /// @ignore
    sender = _sender ?? self;
    
    /// @ignore
    observers = [];
    
    /// @desc Adds an observer to be notified when the event is sent. Also, returns the observer.
    /// @arg {Struct} observer      The observer to notify.
    /// @returns {Struct}
    static add_observer = function(_observer) {
        array_push(observers, _observer);
        return _observer;
    }
    
    /// @desc Creates and adds an observer calling a given handler when the event is sent. Returns the newly created observer.
    /// @arg {Function} handler     The function to call upon receiving the event.
    /// @returns {Struct.CimpliEventObserver}
    static add_handler = function(_handler) {
        var _observer = new CimpliEventObserver(self, _handler);
        return add_observer(_observer);
    }
    
    /// @desc Removes the observer so it's no longer notified about future events. Returns whether the observer was removed or not.
    /// @arg {Struct} observer      The observer to remove.
    /// @returns {Bool}
    static remove_observer = function(_observer) {
        var _index = array_get_index(observers, _observer);
        if (_index < 0)
            return false;
        
        _observer.on_removal();
        array_delete(observers, _index, 1);
        return true;
    }
    
    /// @desc Removes all observers so they're no longer notified about future events.
    static clear_observers = function() {
        array_foreach(observers, function(_observer) {
            _observer.on_removal();
        });
        array_resize(observers, 0);
    }
    
    /// @desc Sends the event to notify the observers. Event data and a sender override can be optionally provided.
    /// @arg {Any} [data]           The data to send to observers.
    /// @arg {Any} [sender]         The entity to report as the event sender, as opposed to subject's own sender.
    static send = function(_data = undefined, _sender = undefined) {
        _sender ??= sender;
        for (var i = 0, _count = array_length(observers); i < _count; i++) {
            observers[i].receive(_data, _sender);
        }
    }
}
