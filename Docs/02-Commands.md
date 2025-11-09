[Home](/README.md)

**Previous:** [Events](/Docs/01-Events.md)

# Commands

A command system helps define specific actions that can be executed from various sources. In particular, commands may be linked to UI components, hotkeys, interactable entities like entities etc., making the command trigger independent from its logic.

## Interface

The command system consists of a single type, the **Command** interface, which requires the following methods:

- `execute([parameter]: Any) -> Undefined` - performs the command logic
- `can_execute([parameter]: Any) -> Bool` - checks if the command can be executed with the given parameter

Because Feather doesn't recognise interface types, the command type is specified in JSDoc as `Struct`

## Implementation

In Cimpli library, the command interface is implemented with **CimpliCommand** constructor. It has the following arguments:

- `action: Function` - a function accepting up to one parameter, containing the command execution logic
- `[condition]: Function` - an optional function accepting up to one parameter, returning whether the command can be executed

CimpliCommand implements the **Command** interface in the following way:

- `execute` - checks if the command can be executed with the given parameter, and if so, performs the command action
- `can_execute` - evaluates the condition function with the given parameter, or returns "true" if no condition was given

## Example

The following example demonstrates using the command system to handle saving level in a level editor.

**Create** event of the `ctrl_LevelEditor` object:

```gml
has_changes = false;

save_command = new CimpliCommand(function() {
    var _save_content = level_data.serialize();
    file_write_all_text(level_filename, _save_content);
}, function() {
    return has_changes;
})
```

**Step** event of the `ctrl_LevelEditor` object:

```gml
if (keyboard_check_pressed(ord("S")) && keyboard_check(vk_control))
    save_command.execute();
```

**Step** event of the `ui_SaveButton` object:

```gml
// grey out the save button if saving is not available
image_blend = ctrl_LevelEditor.save_command.can_execute() ? c_white : c_gray;

if (position_meeting(mouse_x, mouse_y, id) && mouse_check_button_pressed(mb_left))
    ctrl_LevelEditor.save_command.execute();
```

**Next:** [Properties](/Docs/03-Properties.md)
