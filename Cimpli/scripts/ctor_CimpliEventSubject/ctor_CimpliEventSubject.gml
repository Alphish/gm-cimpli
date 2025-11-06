/// @desc A simple implementation of the event subject, managing its observers and sending events to them.
/// @arg {String} name          The name of the subject.
/// @arg {Any} [sender]         The entity passed as the event sender.
function CimpliEventSubject(_name, _sender = undefined) constructor {
    /// @desc The name of the subject.
    /// @returns {String}
    name = _name;
    
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
    
    /// @desc Creates and adds an observer executing a given callback when the event is sent. Returns the newly created observer.
    /// @arg {Function} callback    The callback to execute upon receiving the event.
    /// @returns {Struct.CimpliEventObserver}
    static add_callback = function(_callback) {
        var _observer = new CimpliEventObserver(self, _callback);
        return add_observer(_observer);
    }
    
    /// @desc Removes the observer so it's no longer notified about future events. Returns whether the observer was removed or not.
    /// @arg {Struct} observer      The observer to remove.
    /// @returns {Bool}
    static remove_observer = function(_observer) {
        var _index = array_get_index(observers, _observer);
        if (_index < 0)
            return false;
        
        array_delete(observers, _index, 1);
        return true;
    }
    
    /// @desc Sends the event to notify the observers. Event data and a sender override can be optionally provided.
    /// @arg {Any} [data]           The data to send to observers.
    /// @arg {Any} [sender]         The entity to report as the event sender, as opposed to subject's own sender.
    static send = function(_data = undefined, _sender = undefined) {
        _sender ??= sender;
        for (var i = 0, _count = array_length(observers); i < _count; i++) {
            observers[i].receive(_data, _sender, self);
        }
    }
}
