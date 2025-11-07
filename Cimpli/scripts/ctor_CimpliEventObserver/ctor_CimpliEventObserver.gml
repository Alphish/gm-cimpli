/// @desc A simple implementation of the event observer, receiving and handling events from the subject.
/// @arg {Struct} subject           The subject sending events.
/// @arg {Function} handler         The function handling incoming events.
function CimpliEventObserver(_subject, _handler) constructor {
    /// @desc The subject sending events.
    /// @returns {Struct}
    subject = _subject;
    
    /// @desc The function handling incoming events.
    /// @returns {Function}
    handler = _handler;
    
    /// @desc Handles the incoming event.
    /// @args data          Additional event data.
    /// @args sender        The entity responsible for sending the event.
    static receive = function(_data, _sender) {
        handler(_data, _sender, self);
    }
    
    /// @desc Removes the observer from its subject, so it no longer responds to its events.
    /// @returns {Bool}
    static remove = function() {
        return subject.remove_observer(self);
    }
    
    /// #desc Ensures a correct state after observer removal, whatever it is for the given observer.
    static on_removal = function() {
        // a simple observer needs no additional removal logic
    }
}
