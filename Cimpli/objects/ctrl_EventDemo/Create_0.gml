test_value_property = new CimpliProperty("Lorem");
test_value_changed = test_value_property.value_changed;

logger = new UiLogger("TRACE");

observer_index = 0;

add_observer_command = new CimpliCommand(function() {
    var _observer = test_value_changed.add_handler(function(_data, _sender, _ob) {
        logger.log_info($"Value of {_data} sent by {instanceof(_sender)} was received by observer #{_ob.index}.");
    });
    _observer.index = observer_index++;
    rebuild_buttons();
    logger.log_success($"Added observer #{_observer.index}");
}, function() {
    return array_length(test_value_changed.observers) < 5;
});

clear_observers_command = new CimpliCommand(function() {
    test_value_changed.clear_observers();
    rebuild_buttons();
    logger.log_warning($"All observers cleared!")
}, function() {
    return array_length(test_value_changed.observers) > 0;
});

remove_observer_command = new CimpliCommand(function(_observer) {
    _observer.remove();
    rebuild_buttons();
    logger.log_warning($"Removed observer #{_observer.index}")
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
