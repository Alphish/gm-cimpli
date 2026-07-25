[Home](/README.md)

**Previous:** [Logging](/Docs/04-Logging.md)

# Workers

The workers system helps manage long-running tasks so they can be executed over multiple frames. With such a system, it's possible to adapt the amount of time spent on background tasks each frame while keeping player interaction functional.

## Interfaces

The workers system uses the following types:

- **TaskProcessor** interface, exposing methods for processing task logic and progress tracking
- **Task** interface, exposing methods for managing task processing, as well as event subjects notifying about task changes
- **Worker** interface, exposing methods for processing the underlying task

---

The **TaskProcessor** interface requires the following members:

- `status: Any` - the status of the task processing
- `result: Any` - the result of successful task completion
- `error: Any` - the error causing the task failure
- `init() -> Undefined` - a method reserving whatever resources are required by the task; by putting resource reservation in this method as opposed to the constructor, one may create many tasks in advance while only having resources reserved for ongoing ones
- `process_step() -> Bool` - a method performing a single processing step, returning whether more steps are needed
- `get_progress() -> Any` - a method returning the processing progress so far
- `is_finished() -> Bool` - a method returning whether the processing has finished with completion or error
- `cleanup(auto: Bool) -> Undefined` - a method cleaning up whatever resources were reserved by the task; the "auto" flag indicates whether the cleanup call comes from the general task processing (true) or is done explicitly (false)

Because Feather doesn't recognise interface types, the task type is specified in JSDoc as `Struct`

---

The **Task** interface requires the following members:

- `is_finished: Bool` - a variable indicating whether the task has been finished by completion or cancellation
- `is_canceled: Bool` - a variable indicating whether the task has been canceled
- `get_result() -> Any` - a method returning the processing result, if any
- `get_error() -> Any` - a method returning the processing error, if any
- `init() -> Undefined` - a method initialising the underlying task processor
- `process() -> Bool` - a method performing a single processing step, returning whether more steps are needed
- `check_updates() -> Undefined` - a method checking for task processing updates and sending relevant events
- `try_cancel() -> Bool` - a method attempting to cancel the task before the result is resolved; it returns whether cancellation succeeded
- `status_changed: EventSubject` - an [event subject](/Docs/01-Events.md) that notifies about task status change, sending the status value
- `task_started: EventSubject` - an [event subject](/Docs/01-Events.md) that notifies about task being initialised, sending the underlying processor instance
- `task_progressed: EventSubject` - an [event subject](/Docs/01-Events.md) that notifies about progress, sending a progress object
- `task_finished: EventSubject` - an [event subject](/Docs/01-Events.md) that notifies about processing finishing with completion or failure, sending the processor with its result and error
- `task_completed: EventSubject` - an [event subject](/Docs/01-Events.md) that notifies about successful completion, sending the task result
- `task_failed: EventSubject` - an [event subject](/Docs/01-Events.md) that notifies about failure, sending the task error
- `task_canceled: EventSubject` - an [event subject](/Docs/01-Events.md) that notifies about cancellation

The task implementation should clean up the underlying processor after finishing or cancelling. To allow accessing task processor data from the relevant events, the cleanup should be performed after sending the events.

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

In Cimpli library, the task manager and the worker are implemented with **CimpliTask** and **CimpliWorker** constructors, respectively. On top of that, there's a **CimpliTaskProcessor** constructor that isn't a complete task processor implementation on its own, but serves as a base for specific implementations.

---

**CimpliTaskProcessor** is a base for specific task processor implementations. Its constructor has no arguments. It stubs/implements the **TaskProcessor** interface in the following way:

- `status` - set to **false** when the task is not finished, set to **true** otherwise
- `result` - retrieves the result of the successful completion, if any
- `error` - retrieves the cause of the failed processing, if any
- `init` - does nothing by default
- `process_step` - **must be implemented in the constructor derived from CimpliTaskProcessor** or otherwise set in CimpliTaskProcessor instance; otherwise, a "not implemented" exception will be thrown
- `get_progress` - returns **undefined**, indicating no progress; the implementation may be replaced in the derived constructor
- `is_finished` - returns whether the **status** is truthy or falsy; the implementation may be replaced in the derived constructor (e.g. to check named statuses)
- `cleanup` - does nothing by default

Additionally, CimpliTaskProcessor exposes the following utility methods that can be returned from the processing step:

- `finish() -> Bool` - sets the status to true and returns true (indicating completed processing)
- `complete_with(result) -> Bool` - sets the result to the given value, the status to true and returns true (indicating completed processing)
- `fail_with(error) -> Bool` - sets the error to the given value, the status to true and returns true (indicating completed processing)

---

**CimpliTask** is a basic task implementation, with its behaviour customised with functions. Its constructor has the following arguments:

- `processor: TaskProcessor` - the underlying task logic processor

CimpliTask implements the **Task** interface in the following way:

- `is_finished` - initially false, set to true upon completion or cancellation
- `is_canceled` - initially false, set to true only upon cancellation
- `get_result` - relays the result of the underlying processor
- `get_error` - relays the error of the underlying processor
- `init` - performs the underlying initialisation logic and notifies about the task being started
- `process` - performs the underlying processing step
- `check_updates` - checks the task changes and notifies about status update, progress update and task finishing; after finishing and sending events, it cleans up the underlying processor
- `try_cancel` - if task wasn't already finished, marks it as finished and canceled, sends the task cancellation notification and cleans up the underlying processor
- `status_changes` - automatically created as an instance of CimpliEventSubject
- `task_progressed` - automatically created as an instance of CimpliEventSubject
- `task_finished` - automatically created as an instance of CimpliEventSubject
- `task_completed` - automatically created as an instance of CimpliEventSubject
- `task_failed` - automatically created as an instance of CimpliEventSubject
- `task_canceled` - automatically created as an instance of CimpliEventSubject

---

**CimpliWorker** is a basic worket implementation, managing a single underlying task. Its constructor has the following arguments:

- `task: Task` - the underlying task to process

Because this implementation is meant to manage only single tasks, the underlying task is initialised within the worker constructor.

CimpliWorker implements the **Worker** interface in the following way:

- `is_busy` - returns whether the underlying task was finished
- `run_step` - performs a single task processing step, then sends the progress update; if no more processing steps are needed, attempts the task completion
- `run_until` - performs processing steps until reaching the time limit, then sends the progress update; if no more processing steps are needed, attempts the task completion
- `run_to_end` - performs task processing steps until it's indicated no more steps are needed, then sends the progress update and attempts the task completion
- `try_cancel` - attempts to cancel the underlying task

## Example

The following example demonstrates using the workers system for procedural generation.

The `DungeonGeneratorProcessor` constructor:

```gml
function DungeonGeneratorProcessor(_config) : CimpliTaskProcessor() constructor {
    remaining_rooms = _config.rooms;
    total_rooms = array_length(remaining_rooms);
    dungeon = {};
    
    process_step = function() {
        var _room = array_pop(remaining_rooms);
        // perform generator logic on the room
        
        // returns whether all rooms were processed
        if (array_length(remaining_rooms) == 0)
            return complete_with(dungeon);
        else
            return false;
    }
    
    get_progress = function() {
        var _processed_rooms = total_rooms - array_length(remaining_rooms);
        return { processed: _processed_rooms, total: total_rooms };
    }
}

```

**Create** event of the `ctrl_DungeonGenerator` object, with a `config` object variable:

```gml
generator = new DungeonGeneratorProcessor(config);
progress_percent = 0;

task = new CimpliTask(generator);

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

**Next:** [Providers](/Docs/06-Providers.md)
