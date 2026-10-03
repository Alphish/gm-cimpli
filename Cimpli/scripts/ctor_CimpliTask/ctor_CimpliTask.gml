/// @desc A basic task implementation, performing processing step by step until reaching the result.
/// @arg {Struct} processor         The processor performing the task logic.
function CimpliTask(_processor) constructor {
    /// @desc The processor performing the task logic.
    /// @returns {Struct}
    processor = _processor;
    
    /// @desc Indicates whether the task has finished (through success, failure or cancellation).
    /// @returns {Bool}
    is_finished = false;
    
    /// @desc Indicates whether the task has been canceled.
    /// @returns {Bool}
    is_canceled = false;
    
    /// @ignore
    previous_status = processor.status;
    
    /// @ignore
    status_changed = undefined;
    
    /// @ignore
    task_started = undefined;
    
    /// @ignore
    task_progressed = undefined;
    
    /// @ignore
    task_finished = undefined;
    
    /// @ignore
    task_completed = undefined;
    
    /// @ignore
    task_failed = undefined;
    
    /// @ignore
    task_canceled = undefined;
    
    /// @desc Setups and retrieves the event subject notifying about the task status changing.
    /// @returns {Struct}
    static when_status_changed_subject = function() {
        status_changed ??= new CimpliEventSubject(self);
        return status_changed;
    }
    
    /// @desc Setups and retrieves the event subject notifying about the task starting.
    /// @returns {Struct}
    static when_task_started_subject = function() {
        task_started ??= new CimpliEventSubject(self);
        return task_started;
    }
    
    /// @desc Setups and retrieves the event subject notifying about the task progress.
    /// @returns {Struct}
    static when_task_progressed_subject = function() {
        task_progressed ??= new CimpliEventSubject(self);
        return task_progressed;
    }
    
    /// @desc Setups and retrieves the event subject notifying about the task finishing.
    /// @returns {Struct}
    static when_task_finished_subject = function() {
        task_finished ??= new CimpliEventSubject(self);
        return task_finished;
    }
    
    /// @desc Setups and retrieves the event subject notifying about the task successful completion.
    /// @returns {Struct}
    static when_task_completed_subject = function() {
        task_completed ??= new CimpliEventSubject(self);
        return task_completed;
    }
    
    /// @desc Setups and retrieves the event subject notifying about the task failure.
    /// @returns {Struct}
    static when_task_failed_subject = function() {
        task_failed ??= new CimpliEventSubject(self);
        return task_failed;
    }
    
    /// @desc Setups and retrieves the event subject notifying about the task cancellation.
    /// @returns {Struct}
    static when_task_canceled_subject = function() {
        task_canceled ??= new CimpliEventSubject(self);
        return task_canceled;
    }
    
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
        send_event(task_started, processor);
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
            send_event(status_changed, processor.status);
        }
        
        var _progress = processor.get_progress();
        if (!is_undefined(_progress))
            send_event(task_progressed, _progress);
        
        if (processor.is_finished()) {
            is_finished = true;
            send_event(task_finished, processor);
            
            if (is_undefined(processor.error))
                send_event(task_completed, processor.result);
            else
                send_event(task_failed, processor.error);
            
            processor.cleanup(/* auto */ true);
        }
    }
    
    /// @desc Attempts to cancel the task if it's not finished and returns whether cancellation was successful.
    /// @returns {Bool}
    static try_cancel = function() {
        if (is_finished)
            return false;
        
        is_finished = true;
        is_canceled = true;
        send_event(task_canceled);
        
        processor.cleanup(/* auto */ true);
        return true;
    }
    
    /// @ignore
    static send_event = function(_subject, _data = undefined) {
        if (!is_undefined(_subject))
            _subject.send(_data);
    }
}
