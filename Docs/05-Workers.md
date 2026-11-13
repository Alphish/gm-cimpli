[Home](/README.md)

**Previous:** [Logging](/Docs/04-Logging.md)

# Workers

The workers system helps manage long-running tasks so they can be executed over multiple frames. With such a system, it's possible to adapt the amount of time spent on background tasks each frame while keeping player interaction functional.

## Interfaces

The workers system uses the following types:

- **TaskProcessor** interface, exposing methods for processing task logic and progress tracking
- **Task** interface, exposing methods for managing task processing, as well as event subjects notifying about task changes
- **Worker** interface, exposing methods for processing scheduled tasks

---

The **TaskProcessor** interface requires the following members:

- `is_completed: Bool` - whether the task has been completed or not
- `result: Any` - the result of successful task completion
- `error: Any` - the error that has occurred during the task processing
- `init() -> Undefined` - a method reserving whatever resources are required by the task; by putting resource reservation in this method as opposed to the constructor, one may create many tasks in advance while only having resources reserved for ongoing ones
- `process_step() -> Bool` - a method performing a single processing step, returning whether more steps are needed
- `cleanup(auto: Bool) -> Undefined` - a method cleaning up whatever resources were reserved by the task; the "auto" flag indicates whether the cleanup call comes from the general task processing (true) or is done explicitly (false)

Additionally, a custom task processor may implement:

- `handle_exception(exception) -> Undefined` to handle exceptions thrown during task processing; if not present, the task manager exception handling will be applied instesad

Because Feather doesn't recognise interface types, the task type is specified in JSDoc as `Struct`

---

The **Task** interface requires the following members:

- `is_finished: Bool` - indicates whether the task has been finished, whether by completion, failure or cancellation
- `is_canceled: Bool` - indicates whether the task has been canceled
- `get_result() -> Any` - returns the processing result, if any
- `get_error() -> Any` - returns the processing error, if any
- `init() -> Undefined` - initialises the underlying task processor
- `run_step() -> Bool` - performs a single processing step, returning whether more processing is needed
- `run_until(limit: Real, [steps]: Real) -> Real` - processes the task up to the given time limit; returns the number of remaining steps
- `run_to_end() -> Bool` - immediately executes the task until completion and returns `true` to indicate no more steps are needed.
- `try_cancel() -> Bool` - a method attempting to cancel the task before the result is resolved; it returns whether cancellation succeeded
- `when_task_started_subject(): EventSubject` - a method providing an [event subject](/Docs/01-Events.md) notifying about the task being initialised, sending the underlying processor instance
- `when_task_progressed_subject(): EventSubject` - a method providing an [event subject](/Docs/01-Events.md) notifying about the progress, sending the underlying processor instance
- `when_task_finished_subject(): EventSubject` - a method providing an [event subject](/Docs/01-Events.md) notifying about processing finishing with completion or failure, sending the processor with its result and error
- `when_task_completed_subject(): EventSubject` - a method providing an [event subject](/Docs/01-Events.md) notifying about successful completion, sending the task result
- `when_task_failed_subject(): EventSubject` - a method providing an [event subject](/Docs/01-Events.md) notifying about failure, sending the task error
- `when_task_canceled_subject(): EventSubject` - a method providing an [event subject](/Docs/01-Events.md) notifying about cancellation

The task implementation should clean up the underlying processor after finishing or cancelling. To allow accessing task processor data from the relevant events, the cleanup should be performed after sending the events.

Because Feather doesn't recognise interface types, the task type is specified in JSDoc as `Struct`

---

The **Worker** interface requires the following methods:

- `is_busy() -> Bool` - indicates whether the worker manages an ongoing task
- `run_step() -> Bool` - runs a single processing step of the ongoing task and returns whether the task was finished
- `run_until(limit: Real, [steps]: Real) -> Bool` - runs as many steps as possible within the given time limit, with an optional number of guaranteed steps (1 by default); returns whether the processing has finished
- `run_to_end() -> Bool` - immediately processes any remaining tasks until no more processing is needed
- `try_cancel([task]: Task) -> Bool` - attempts to cancel a given task, or all of the worker's tasks if no task is specified

Because Feather doesn't recognise interface types, the worker type is specified in JSDoc as `Struct`

## Implementation

In Cimpli library, the task manager and the worker are implemented with **CimpliTask** and **CimpliWorker** constructors, respectively. On top of that, there's a **CimpliTaskProcessor** constructor that isn't a complete task processor implementation on its own, but serves as a base for specific implementations.

---

**CimpliTaskProcessor** is a base for specific task processor implementations. Its constructor has no arguments. It stubs/implements the **TaskProcessor** interface in the following way:

- `is_completed` - starts out as **false**, set to **true** upon completion
- `result` - retrieves the result of the successful completion, if any
- `error` - retrieves the cause of the failed processing, if any
- `init` - does nothing by default
- `process_step` - **must be implemented in the constructor derived from CimpliTaskProcessor** or otherwise set in CimpliTaskProcessor instance; without that, a "not implemented" exception will be thrown
- `cleanup` - does nothing by default

Additionally, CimpliTaskProcessor exposes the following utility methods that can be returned from the processing step:

- `complete() -> Bool` - sets the **is_completed** flag; returns **true**
- `complete_with(result) -> Bool` - assigns the given value to the **result** variable and sets the **is_completed** flag; returns **true**

---

**CimpliTask** is a basic task implementation, with its behaviour customised with functions. Its constructor has the following arguments:

- `processor: TaskProcessor` - the underlying task logic processor

CimpliTask implements the **Task** interface in the following way:

- `is_finished` - initially false, set to true upon completion or cancellation
- `is_canceled` - initially false, set to true only upon cancellation
- `get_result` - relays the result of the underlying processor
- `get_error` - relays the error of the underlying processor
- `init` - performs the underlying initialisation logic and notifies about the task being started
- `run_step` - performs a single step of the underlying processor's logic, handling any errors if needed
- `run_until` - performs the underlying processor's logic until the given time limit, handling any errors if needed
- `run_to_end` - performs the underlying processor's logic until completion or an error
- `try_cancel` - if task wasn't already finished, marks it as finished and canceled, sends the task cancellation notification and cleans up the underlying processor
- `when_task_started_subject` - prepares an instance of CimpliEventSubject if not present already, then returns the subject
- `when_task_progressed_subject` - prepares an instance of CimpliEventSubject if not present already, then returns the subject
- `when_task_finished_subject` - prepares an instance of CimpliEventSubject if not present already, then returns the subject
- `when_task_completed_subject` - prepares an instance of CimpliEventSubject if not present already, then returns the subject
- `when_task_failed_subject` - prepares an instance of CimpliEventSubject if not present already, then returns the subject
- `when_task_canceled_subject` - prepares an instance of CimpliEventSubject if not present already, then returns the subject

---

**CimpliWorker** is a basic worket implementation, managing a queue of tasks. Its constructor has no arguments. It implements the **Worker** interface in the following way:

- `is_busy` - returns whether the underlying task was finished
- `run_step` - performs a single step of the ongoing task
- `run_until` - processes scheduled tasks until the given time limit
- `run_to_end` - processes all the tasks in the queue until completion or interruption
- `try_cancel` - attempts to cancel the given task if one is scheduled in the worker; if no task is given, attempts to cancel all tasks in the queue

Additionally, CimpliWorker exposes the following method:

- `schedule_task(task: Task) -> Undefined` - adds the given task to the worker queue

- 

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
}

```

**Create** event of the `ctrl_DungeonGenerator` object, with a `config` object variable:

```gml
woirker = new CimpliWorker();
generator = new DungeonGeneratorProcessor(config);
progress_percent = 0;

task = new CimpliTask(generator);

task.when_task_progressed_subject().add_handler(function(_processor) {
    var _total = _processor.total_rooms;
    var _progress = _total - array_length(_processor.remaining_rooms);
    progress_percent = round(100 * _progress / _total);
});
task.when_task_completed_subject().add_handler(function(_dungeon) {
    instance_create_layer(0, 0, layer, ctrl_DungeonGameplay, { dungeon_data: _dungeon });
    instance_destroy();
});

worker.schedule_task(task);
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
