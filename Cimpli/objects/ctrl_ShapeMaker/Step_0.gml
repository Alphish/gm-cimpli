if (layer_get_visible("Instructions")) {
    if (mouse_check_button_pressed(mb_left))
        layer_set_visible("Instructions", false);
    
    return;
}

with (ui_ActionButton) event_user(0);
with (ui_SelectButton) event_user(0);
with (obj_ShapePanel) event_user(0);
