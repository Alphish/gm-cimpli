/// @desc A basic worker implementation, managing processing of the underlying task.
/// @arg {Struct} task          The underlying task to process.
function CimpliWorker(_task) constructor {
    /// @desc The underlying task.
    /// @returns {Struct}
    task = _task;
    
    /// @desc Checks if the worker has an ongoing task.
    /// @returns {Bool}
    static is_busy = function() {
        return !task.is_finished;
    }
    
    /// @desc Performs a single step of the underlying task and updates it. Returns whether the task requires no further processing.
    /// @returns {Bool}
    static run_step = function() {
        if (task.is_finished)
            return true;
        
        var _step_result = task.process();
        
        task.update_progress();
        if (_step_result)
            return task.try_complete();
    }
    
    /// @desc Executes the underlying task until given time and updates it. Returns whether the task requires no further processing.
    /// @arg {Real} limit       The time limit after which processing should stop.
    /// @arg {Real} [steps]     A number of steps to perform regardless of time limit.
    /// @returns {Bool}
    static run_until = function(_limit, _steps = 1) {
        if (task.is_finished)
            return true;
        
        var _step_result = false;
        repeat (_steps) {
            _step_result = task.process();
            if (_step_result)
                break;
        }
        
        while (get_timer() <= _limit && !_step_result) {
            _step_result = task.process();
        }
        
        task.update_progress();
        if (_step_result)
            return task.try_complete();
    }
    
    /// @desc Executes the underlying task until completion or interruption.
    /// @returns {Bool}
    static run_to_end = function() {
        if (task.is_finished)
            return true;
        
        var _step_result = false;
        while (!_step_result) {
            _step_result = step();
        }
        
        task.update_progress();
        return task.try_complete();
    }
    
    /// @desc Attempts to cancel the underlying task and returns whether it was successful.
    /// @returns {Bool}
    static try_cancel = function() {
        return task.try_cancel();
    }
}
