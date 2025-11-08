/// @desc A basic task implementation, performing processing step by step until reaching the result.
/// @arg {Function} step            A function performing a single processing step and returning whether processing should stop.
/// @arg {Function} [result]        A function retrieving a result upon completion, if any.
/// @arg {Function} [progress]      A function retrieving the current progress, if any.
function CimpliTask(_step, _result = undefined, _progress = undefined) constructor {
    /// @ignore
    process_step = _step;
    
    /// @ignore
    result_retriever = _result;
    
    /// @ignore
    progress_retriever = _progress;
    
    /// @desc The event subject notifying about a task progress.
    /// @returns {Struct}
    task_progressed = !is_undefined(progress_retriever) ? new CimpliEventSubject(self) : undefined;
    
    /// @desc Indicates whether the task has been completed or cancelled.
    /// @returns {Bool}
    is_finished = false;
    
    /// @desc Indicates whether the task has been successfully completed.
    /// @returns {Bool}
    is_completed = false;
    
    /// @desc The result of the task.
    /// @returns {Any}
    result = undefined;
    
    /// @desc The event subject notifying about a successful completion.
    /// @returns {Struct}
    task_completed = new CimpliEventSubject(self);
    
    /// @desc The event subject notifying about a task cancellation.
    /// @returns {Struct}
    task_cancelled = new CimpliEventSubject(self);
    
    /// @desc Performs a single processing step and returns whether the processing should stop.
    /// @returns {Bool}
    static process = function() {
        return process_step();
    }
    
    /// @desc Sends information about the latest progress.
    static update_progress = function() {
        if (is_undefined(progress_retriever))
            return;
        
        var _progress = progress_retriever();
        task_progressed.send(_progress);
    }
    
    /// @desc Attempts to complete the task if it's not finished and returns whether completion was successful.
    /// @returns {Bool}
    static try_complete = function() {
        if (is_finished)
            return false;
        
        is_finished = true;
        is_completed = true;
        result = !is_undefined(result_retriever) ? result_retriever() : undefined;
        task_completed.send(result);
        return true;
    }
    
    /// @desc Attempts to cancel the task if it's not finished and returns whether cancellation was successful.
    /// @returns {Bool}
    static try_cancel = function() {
        if (is_finished)
            return false;
        
        is_finished = true;
        is_completed = false;
        task_cancelled.send();
        return true;
    }
}
