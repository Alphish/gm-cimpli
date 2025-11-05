/// @desc A simple implementation of the event observer, receiving and handling events from the subject.
/// @arg {Struct} subject           The subject sending events.
/// @arg {Function} callback        The callback handling incoming events.
function CimpliEventObserver(_subject, _callback) constructor {
    /// @desc The subject sending events.
    /// @returns {Struct}
    subject = _subject;
    
    /// @desc The callback handling incoming events.
    /// @returns {Function}
    callback = _callback;
    
    /// @desc Handles the incoming event.
    /// @args data          Additional event data.
    /// @args sender        The entity responsible for sending the event.
    /// @args subject       The subject sending the event.
    static receive = function(_data, _sender, _subject) {
        callback(_data, _sender, _subject);
    }
    
    /// @desc Removes the observer from its subject, so it no longer responds to its events.
    /// @returns {Bool}
    static remove = function() {
        return subject.remove_observer(self);
    }
}
