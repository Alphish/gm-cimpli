is_enabled = command.can_execute(command_parameter);
is_hovered = is_enabled && position_meeting(mouse_x, mouse_y, id);

if (is_hovered && mouse_check_button_pressed(mb_left))
    command.execute(command_parameter);
