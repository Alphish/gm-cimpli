if (is_callable(command))
    command = new CimpliCommand(command, /* condition */ undefined);

is_enabled = command.can_execute(command_parameter);
is_hovered = false;
