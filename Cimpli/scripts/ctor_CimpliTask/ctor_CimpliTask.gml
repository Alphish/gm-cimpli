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
    
    /// @desc Prepares and retrieves the event subject notifying about the task starting.
    /// @returns {Struct}
    static when_task_started_subject = function() {
        task_started ??= new CimpliEventSubject(self);
        return task_started;
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task progress.
    /// @returns {Struct}
    static when_task_progressed_subject = function() {
        task_progressed ??= new CimpliEventSubject(self);
        return task_progressed;
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task finishing.
    /// @returns {Struct}
    static when_task_finished_subject = function() {
        task_finished ??= new CimpliEventSubject(self);
        return task_finished;
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task successful completion.
    /// @returns {Struct}
    static when_task_completed_subject = function() {
        task_completed ??= new CimpliEventSubject(self);
        return task_completed;
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task failure.
    /// @returns {Struct}
    static when_task_failed_subject = function() {
        task_failed ??= new CimpliEventSubject(self);
        return task_failed;
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task cancellation.
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
    
    /// @desc Performs a single processing step. Returns whether more processing is required.
    /// @returns {Bool}
    static run_step = function() {
        if (is_finished)
            return true;
        
        var _result = false;
        try {
            _result = processor.process_step();
        } catch (_exception) {
            handle_exception(_exception);
        }
        
        check_updates();
        
        // checking both finishing variable and the processing step result
        // because a processor may return true to indicate more processing is not immedaitely needed, but may be resumed later
        // (e.g. because the processor has to wait for an asynchronous response)
        return is_finished || _result;
    }
    
    /// @desc Processes the task up to the given time limit. Returns 0 when more processing is required, or 1 + remaining steps when no more processing is needed.
    /// @arg {Real} limit       The time limit after which processing should stop.
    /// @arg {Real} [steps]     A number of steps to perform regardless of the time limit.
    /// @returns {Real}
    static run_until = function(_limit, _steps = 1) {
        if (is_finished)
            return true;
        
        var _remaining_steps = 0;
        try {
            _remaining_steps = process_until(_limit, _steps);
        } catch (_exception) {
            handle_exception(_exception);
        }
        
        check_updates();
        return _remaining_steps >= 0 ? _remaining_steps + 1 : (is_finished ? 1 : 0);
    }
    
    /// @ignore
    static process_until = function(_limit, _steps) {
        var _result = false;
        
        while (_steps-- > 0) {
            _result = processor.process_step();
            if (_result)
                return _steps;
        }
        
        while (get_timer() <= _limit) {
            _result = processor.process_step();
            if (_result)
                return 0;
        }
        
        return -1;
    }
    
    /// @desc Immediately processes the task until a completion or a failure.
    /// @returns {Bool}
    static run_to_end = function(_limit, _steps = 1) {
        if (is_finished)
            return true;
        
        try {
            while (!processor.process_step()) {}
        } catch (_exception) {
            handle_exception(_exception);
        }
        
        check_updates();
        return true;
    }
    
    /// @ignore
    static handle_exception = function(_exception) {
        if (is_callable(processor[$ "handle_exception"]))
            processor.handle_exception(_exception);
        else
            processor.error = _exception;
    }
    
    /// @ignore
    static check_updates = function() {
        if (is_finished)
            return true;
        
        if (is_callable(processor[$"prepare_update"]) && processor.prepare_update())
            send_event(task_progressed, processor);
        
        if (processor.is_completed || !is_undefined(processor.error)) {
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
        send_event(task_canceled, processor);
        
        processor.cleanup(/* auto */ true);
        return true;
    }
    
    /// @ignore
    static send_event = function(_subject, _data = undefined) {
        if (!is_undefined(_subject))
            _subject.send(_data);
    }
}
