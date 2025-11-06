subject_tested = new CimpliEventSubject("tested", id);

event_index = 0;
observer_index = 0;

send_event = function() {
    var _index = event_index++;
    subject_tested.send(_index);
}

add_observer = function() {
    var _observer = subject_tested.add_callback(function(_data, _sender, _subject) {
        show_debug_message($"Value of {_data} sent by {_sender.object_index} through '{_subject.name}' event.");
    });
    _observer.index = observer_index++;
    rebuild_observers();
}

remove_observer = function() {
    self.observer.remove();
    self.demo.rebuild_observers();
}

rebuild_observers = function() {
    with (ui_TestButton) {
        if (string_starts_with(text, "Remove observer"))
            instance_destroy();
    }
    
    array_foreach(subject_tested.observers, function(_observer, _index) {
        instance_create_layer(240, 40 * _index, layer, ui_TestButton, {
            text: $"Remove observer #{_observer.index}",
            command: method({ observer: _observer, demo: id }, self.remove_observer),
            image_xscale: 12,
            image_yscale: 2,
        });
    });
}
