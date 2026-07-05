if (position_meeting(mouse_x, mouse_y, id) && mouse_check_button_pressed(mb_left)) {
    ctrl_ShapeMaker.make_shape(mouse_x, mouse_y);
}

if (mouse_check_button(mb_right)) {
    var _list = ds_list_create();
    var _count = instance_position_list(mouse_x, mouse_y, obj_ExampleShape, _list, false);
    for (var i = 0; i < _count; i++) {
        var _instance = _list[| i];
        if (_instance.unique) {
            _instance.x = -999;
            _instance.y = -999;
        } else {
            instance_destroy(_instance);
        }
    }
    ds_list_destroy(_list);
}
