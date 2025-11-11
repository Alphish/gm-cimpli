logger = new UiLogger("TRACE");
log_level_property = new CimpliProperty("TRACE");
log_level_property.value_changed.add_handler(function(_value) {
    logger = new UiLogger(_value);
});

// ------------
// Calculations
// ------------

calculated_sum = 0;
remaining_terms = [];
terms_count = 0;

calculation_arg_property = new CimpliProperty();

worker = undefined;
calculation_started = new CimpliEventSubject(id);
calculation_progressed = new CimpliEventSubject(id);
calculation_completed = new CimpliEventSubject(id);
calculation_cancelled = new CimpliEventSubject(id);

begin_calculation_command = new CimpliCommand(function() {
    if (!is_undefined(worker) && worker.is_busy()) {
        worker.cancel();
        worker = undefined;
    }
    
    var _number = calculation_arg_property.get_value();
    if (is_undefined(_number)) {
        logger.log_critical($"Unknown number of terms to calculate!");
        return;
    }
    
    calculated_sum = 0;
    remaining_terms = array_create_ext(_number, function(i) { return i + 1; });
    terms_count = _number;
    
    var _task = new CimpliTask(calculate_next_term, get_calculated_sum, get_calculation_progress);
    _task.task_progressed.add_handler(method(calculation_progressed, calculation_progressed.send));
    _task.task_completed.add_handler(method(calculation_completed, calculation_completed.send));
    _task.task_cancelled.add_handler(method(calculation_cancelled, calculation_cancelled.send));
    
    worker = new CimpliWorker(_task);
    
    calculation_started.send(_number);
});

cancel_calculation_command = new CimpliCommand(function() {
    worker.try_cancel();
    worker = undefined;
}, function() {
    return !is_undefined(worker) && worker.is_busy();
});

calculate_next_term = function() {
    calculated_sum += array_shift(remaining_terms);
    return array_length(remaining_terms) <= 0;
}

get_calculated_sum = function() {
    return calculated_sum;
}

get_calculation_progress = function() {
    return $"{terms_count - array_length(remaining_terms)}/{terms_count}";
}

// ---------
// Observers
// ---------

observer_index = 1;
observer_added = new CimpliEventSubject(id);
observer_removed = new CimpliEventSubject(id);
all_observers = [];

add_observer = function(_subject, _type, _handler) {
    var _observer = _subject.add_handler(_handler);
    _observer.type = _type;
    _observer.index = observer_index++;
    _observer.on_removal = method({ observer: _observer, subject: observer_removed }, function() {
        subject.send(observer);
    });
    array_push(all_observers, _observer);
    observer_added.send(_observer);
    rebuild_buttons();
}

can_add_observer = function() {
    return array_length(all_observers) < 10;
}

observe_start_command = new CimpliCommand(function() {
    add_observer(calculation_started, "Start", function(_number, _sender, _observer) {
        logger.log_info($"Calculation started for {_number} terms (#{_observer.index})");
    });
}, can_add_observer);

observe_progress_command = new CimpliCommand(function() {
    add_observer(calculation_progressed, "Progress", function(_progress, _sender, _observer) {
        logger.log_trace($"Calculation progress: {_progress} (#{_observer.index})");
    });
}, can_add_observer);

observe_completion_command = new CimpliCommand(function() {
    add_observer(calculation_completed, "Complete", function(_result, _sender, _observer) {
        logger.log_success($"Calculation completed with result {_result} (#{_observer.index})");
    });
}, can_add_observer);

observe_cancellation_command = new CimpliCommand(function() {
    add_observer(calculation_cancelled, "Cancel", function(_, _sender, _observer) {
        logger.log_error($"Calculation has been cancelled (#{_observer.index})");
    });
}, can_add_observer);

observe_count_command = new CimpliCommand(function() {
    add_observer(calculation_arg_property.value_changed, "Count", function(_number, _sender, _observer) {
        logger.log_debug($"Terms count changed to {_number} (#{_observer.index})");
    });
}, can_add_observer);

observe_loglevel_command = new CimpliCommand(function() {
    add_observer(log_level_property.value_changed, "Log Level", function(_level, _sender, _observer) {
        logger.log_critical($"Log level changed to {_level} (#{_observer.index})");
    });
}, can_add_observer);

observe_add_observer_command = new CimpliCommand(function() {
    add_observer(observer_added, "Observe", function(_new, _sender, _observer) {
        logger.log_success($"Added {_new.type} observer #{_new.index} (#{_observer.index})");
    });
}, can_add_observer);

observe_remove_observer_command = new CimpliCommand(function() {
    add_observer(observer_removed, "Unobserve", function(_deleted, _sender, _observer) {
        logger.log_warning($"Removed {_deleted.type} observer #{_deleted.index} (#{_observer.index})");
    });
}, can_add_observer);

clear_observers_command = new CimpliCommand(function() {
    calculation_started.clear_observers();
    calculation_progressed.clear_observers();
    calculation_completed.clear_observers();
    calculation_cancelled.clear_observers();
    
    calculation_arg_property.value_changed.clear_observers();
    log_level_property.value_changed.clear_observers();
    log_level_property.value_changed.add_handler(function(_value) {
        logger = new UiLogger(_value);
    });
    
    observer_added.clear_observers();
    observer_removed.clear_observers();
    
    array_resize(all_observers, 0);
    rebuild_buttons();
}, function() {
    return array_length(all_observers) > 0;
});

remove_observer_command = new CimpliCommand(function(_observer) {
    _observer.remove();
    array_delete(all_observers, array_get_index(all_observers, _observer), 1);
    rebuild_buttons();
});

rebuild_buttons = function() {
    with (ui_ActionButton) {
        if (command == other.remove_observer_command)
            instance_destroy();
    }
    
    array_foreach(all_observers, function(_observer, _index) {
        instance_create_layer(220, 300 + 40 * _index, layer, ui_ActionButton, {
            text: $"Unobs. {_observer.type} #{_observer.index}",
            command: remove_observer_command,
            command_parameter: _observer,
            image_xscale: 10 / 3,
            image_yscale: 2 / 3,
            base_color: merge_color(c_yellow, c_white, 0.5),
            hover_color: c_yellow,
        });
    });
}

// -------------
// Miscellaneous
// -------------

view_instructions_command = new CimpliCommand(function() {
    layer_set_visible("Instructions", true);
});

visit_website_command = new CimpliCommand(function() {
    url_open("https://github.com/Alphish/gm-cimpli");
});

// -------
// Startup
// -------

observe_start_command.execute();
observe_progress_command.execute();
observe_completion_command.execute();
observe_cancellation_command.execute();
