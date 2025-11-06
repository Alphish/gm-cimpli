test_value_property = new CimpliProperty("Lorem");
test_value_changed = test_value_property.value_changed;

observer_index = 0;

add_observer_command = new CimpliCommand(function() {
    var _observer = test_value_changed.add_callback(function(_data, _sender, _ob) {
        show_debug_message($"Value of {_data} sent by {instanceof(_sender)} was received by observer #{_ob.index}.");
    });
    _observer.index = observer_index++;
    rebuild_buttons();
}, function() {
    return array_length(test_value_changed.observers) < 5;
});

clear_observers_command = new CimpliCommand(function() {
    test_value_changed.clear_observers();
    rebuild_buttons();
}, function() {
    return array_length(test_value_changed.observers) > 0;
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
    
    array_foreach(test_value_changed.observers, function(_observer, _index) {
        instance_create_layer(240, 100 + 40 * _index, layer, ui_TestButton, {
            text: $"Remove observer #{_observer.index}",
            command: remove_observer_command,
            command_parameter: _observer,
            image_xscale: 12,
            image_yscale: 2,
        });
    });
}
