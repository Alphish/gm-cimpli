[Home](/README.md)

**Previous:** [Logging](/Docs/04-Logging.md)

# Workers

The worker system helps manage long-running tasks so they can be executed over multiple frames. With such a system, it's possible to adapt the amount of time spent on background tasks each frame while keeping player interaction functional.

## Interfaces

The worker system uses the following types:

- **Task** interface, exposing methods for task processing and management, as well as event subjects notifying about task changes
- **Worker** interface, exposing methods for processing the underlying task

---

The **Task** interface requires the following members:

- `process() -> Bool` - a method performing a single processing step, returning whether more steps are needed
- `update_progress() -> Undefined` - a method sending a progress update
- `try_complete() -> Bool` - a method attempting to complete the task and resolve the result; it returns whether completion succeeded
- `try_cancel() -> Bool` - a method attempting to cancel the task before the result is resolved; it returns whether cancellation succeeded
- `is_finished: Bool` - a variable indicating whether the task was finished by completion or cancellation
- `is_completed: Bool` - a variable indicating whether the task was successfully completed
- `result: Any` - the result produced by the completed task
- `task_progressed: EventSubject` - an [event subject](/Docs/01-Events.md) that notifies about progress, sending a progress object
- `task_completed: EventSubject` - an [event subject](/Docs/01-Events.md) that notifies about completion, sending the task result
- `task_cancelled: EventSubject` - an [event subject](/Docs/01-Events.md) that notifies about cancellation

Because Feather doesn't recognise interface types, the task type is specified in JSDoc as `Struct`

---

The **Worker** interface requires the following methods:

- `is_busy() -> Bool` - indicates whether the worker manages an ongoing task
- `run_step() -> Bool` - runs a single processing step of the underlying task and returns whether the task was finished
- `run_until(limit: Real, [steps]: Real) -> Bool` - runs as many steps as possible within the given time limit, with an optional number of guaranteed steps (1 by default); returns whether the task was finished
- `run_to_end() -> Bool` - runs the underlying task until completion or interruption and returns whether the task was finished
- `try_cancel() -> Bool` - attempts to cancel the underlying task and returns whether it was successful

Because Feather doesn't recognise interface types, the worker type is specified in JSDoc as `Struct`

## Implementation

In Cimpli library, the task and the worker are implemented with **CimpliTask** constructor and **CimpliWorker**, respectively.

---

**CimpliTask** is a basic task implementation, with its behaviour customised with functions. Its constructor has the following arguments:

- `step: Function` - a parameterless function performing a processing step and returning whether more processing is needed
- `[result]: Function` - a parameterless function returning the result upon the task completion; if no such function is given, the sent result is undefined
- `[progress]: Function` - a parameterless function returning the current task progress; if  no such function is given, no progress notifications are sent

CimpliTask implements the **Task** interface in the following way:

- `process` - performs and returns the result of step processing function
- `update_progress` - if progress function was given, sends a task progress notification with the current progress object
- `try_complete` - if task wasn't already finished, marks it as finished and completed, resolves the result and sends the task completion notification with this result
- `try_cancel` - if task wasn't already finished, marks it as finished but not completed and sends the task cancellation notification
- `is_finished` - initially false, set to true upon completion or cancellation
- `is_completed` - initially false, set to true only upon successful completion
- `result` - initially undefined, resolved to an arbitrary object upon completion
- `task_progressed` - automatically created as an instance of CimpliEventSubject
- `task_completed` - automatically created as an instance of CimpliEventSubject
- `task_cancelled` - automatically created as an instance of CimpliEventSubject

---

**CimpliWorker** is a basic worket implementation, managing a single underlying task. Its constructor has the following arguments:

- `task: Task` - the underlying task to process

CimpliWorker implements the **Worker** interface in the following way:

- `is_busy` - returns whether the underlying task was finished
- `run_step` - performs a single task processing step, then sends the progress update; if no more processing steps are needed, attempts the task completion
- `run_until` - performs processing steps until reaching the time limit, then sends the progress update; if no more processing steps are needed, attempts the task completion
- `run_to_end` - performs task processing steps until it's indicated no more steps are needed, then sends the progress update and attempts the task completion

## Example

The following example demonstrates using the worker system for procedural generation.

The `DungeonGenerator` constructor:

```gml
function DungeonGenerator(_config) constructor {
    remaining_rooms = _config.rooms;
    total_rooms = array_length(remaining_rooms);
    dungeon = {};
    
    generate_room = function() {
        var _room = array_pop(remaining_rooms);
        // perform generator logic on the room
        
        // returns whether all rooms were processed
        return array_length(remaining_rooms) == 0;
    }
    
    get_progress = function() {
        var _processed_rooms = total_rooms - array_length(remaining_rooms);
        return { processed: _processed_rooms, total: total_rooms };
    }
    
    get_dungeon = function() {
        return dungeon;
    }
}

```

**Create** event of the `ctrl_DungeonGenerator` object, with a `config` object variable:

```gml
generator = new DungeonGenerator(config);
progress_percent = 0;

task = new CimpliTask(
    /* step */ generator.generate_room,
    /* result */ generator.get_dungeon,
    /* progress */ generator.get_progress
    );

task.task_progressed.add_handler(function(_progress) {
    progress_percent = round(100 * _progress.processed / _progress.total);
});
task.task_completed.add_handler(function(_dungeon) {
    instance_create_layer(0, 0, layer, ctrl_DungeonGameplay, { dungeon_data: _dungeon });
    instance_destroy();
});

worker = new CimpliWorker(task);
```

**Step** event of the `ctrl_DungeonGenerator` object:

```gml
var _limit = get_timer() + 20000; // spend 20ms on processing
worker.run_until(_limit);
```

**Draw GUI** event of the `ctrl_DungeonGenerator` object:
```gml
draw_clear(c_black);

draw_set_color(c_white);
draw_set_alpha(1);
draw_set_font(fnt_LoadingProgress);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(display_get_gui_width() div 2, display_get_gui_height() div 2, $"Generating dungeon...\n{progress_percent}%");
```

With such a system, the dungeon will be gradually generated while the player can see the progress.
