/// @desc A basic task implementation, performing processing step by step until reaching the result.
/// @arg {Struct} processor         The processor performing the task logic.
function CimpliTask(_processor) constructor {
    /// @desc The processor performing the task logic.
    /// @returns {Struct}
    processor = _processor;
    
    /// @desc Indicates whether the task has finished (through success, failure or cancellation).
    /// @returns {Bool}
    is_finished = false;
    
    /// @desc Indicates whether the task has been cancelled.
    /// @returns {Bool}
    is_cancelled = false;
    
    /// @ignore
    previous_status = processor.status;
    
    /// @desc The event subject notifying about the task status changing.
    /// @returns {Struct}
    status_changed = new CimpliEventSubject(self);
    
    /// @desc The event subject notifying about the task starting.
    /// @returns {Struct}
    task_started = new CimpliEventSubject(self);
    
    /// @desc The event subject notifying about the task progress.
    /// @returns {Struct}
    task_progressed = new CimpliEventSubject(self);
    
    /// @desc The event subject notifying about the task finishing.
    /// @returns {Struct}
    task_finished = new CimpliEventSubject(self);
    
    /// @desc The event subject notifying about the task successful completion.
    /// @returns {Struct}
    task_completed = new CimpliEventSubject(self);
    
    /// @desc The event subject notifying about the task failure.
    /// @returns {Struct}
    task_failed = new CimpliEventSubject(self);
    
    /// @desc The event subject notifying about the task cancellation.
    /// @returns {Struct}
    task_cancelled = new CimpliEventSubject(self);
    
    /// @desc Gets whichever result the task produced, if any.
    /// @returns {Any}
    static get_result = function() {
        return processor.result;
    }
    
    /// @desc Gets whichever error happened during task processing, if any.
    /// @returns {Any}
    static get_error = function() {
        return processor.error;
    }
    
    /// @desc Prepares the task resources, if any.
    init = function() {
        processor.init();
        task_started.send(processor);
    }
    
    /// @desc Performs a single processing step and returns whether the processing should stop.
    /// @returns {Bool}
    process = method(processor, processor.process_step);
    
    /// @desc Checks task changes and sends appropriate updates.
    static check_updates = function() {
        if (is_finished)
            return;
        
        if (processor.status != previous_status) {
            previous_status = processor.status;
            status_changed.send(processor.status);
        }
        
        var _progress = processor.get_progress();
        if (!is_undefined(_progress))
            task_progressed.send(_progress);
        
        if (processor.is_finished()) {
            is_finished = true;
            task_finished.send(processor);
            
            if (is_undefined(processor.error))
                task_completed.send(processor.result);
            else
                task_failed.send(processor.error);
            
            processor.cleanup(/* auto */ true);
        }
    }
    
    /// @desc Attempts to cancel the task if it's not finished and returns whether cancellation was successful.
    /// @returns {Bool}
    static try_cancel = function() {
        if (is_finished)
            return false;
        
        is_finished = true;
        is_cancelled = true;
        task_cancelled.send();
        
        processor.cleanup(/* auto */ true);
        return true;
    }
}
