subject_tested = new CimpliEventSubject("tested", id);

event_index = 0;
observer_index = 0;

send_event_command = new CimpliCommand(function() {
    var _index = event_index++;
    subject_tested.send(_index);
});

add_observer_command = new CimpliCommand(function() {
    var _observer = subject_tested.add_callback(function(_data, _sender, _subject) {
        show_debug_message($"Value of {_data} sent by {_sender.object_index} through '{_subject.name}' event.");
    });
    _observer.index = observer_index++;
    rebuild_buttons();
}, function() {
    return array_length(subject_tested.observers) < 5;
});

clear_observers_command = new CimpliCommand(function() {
    subject_tested.clear_observers();
    rebuild_buttons();
}, function() {
    return array_length(subject_tested.observers) > 0;
});

remove_observer_command = new CimpliCommand(function(_observer) {
    _observer.remove();
    rebuild_buttons();
});

rebuild_buttons = function() {
    with (ui_TestButton) {
        if (string_starts_with(text, "Remove observer"))
            instance_destroy();
    }
    
    array_foreach(subject_tested.observers, function(_observer, _index) {
        instance_create_layer(240, 40 * _index, layer, ui_TestButton, {
            text: $"Remove observer #{_observer.index}",
            command: remove_observer_command,
            command_parameter: _observer,
            image_xscale: 12,
            image_yscale: 2,
        });
    });
}
