if (layer_get_visible("Instructions")) {
    if (mouse_check_button_pressed(mb_left))
        layer_set_visible("Instructions", false);
    
    return;
}

with (ui_ActionButton) event_user(0);
with (ui_SelectButton) event_user(0);

var _next_timer = get_timer() + 10000;
if (!is_undefined(worker))
    worker.run_until(_next_timer);
