/// @desc A basic worker implementation, managing processing of scheduled tasks.
function CimpliWorker() constructor {
    /// @desc The currently running task.
    /// @returns {Struct}
    ongoing_task = undefined;
    
    /// @desc The tasks waiting for execution.
    /// @returns {Array<Struct>}
    pending_tasks = [];
    
    /// @desc Schedules a task to be executed.
    /// @arg {Struct} task          The task to schedule.
    static schedule_task = function(_task) {
        array_push(pending_tasks, _task);
    }
    
    /// @desc Checks if the worker has an ongoing task.
    /// @returns {Bool}
    static is_busy = function() {
        return !is_undefined(ongoing_task) || array_length(pending_tasks) > 0;
    }
    
    /// @desc Performs a single step of the ongoing task. Returns whether there is any processing left to be done.
    /// @returns {Bool}
    static run_step = function() {
        if (!prepare_task())
            return true;
        
        return ongoing_task.run_step() && prepare_task();
    }
    
    /// @desc Executes scheduled tasks until the given time limit. Returns whether there is any processing left to be done.
    /// @arg {Real} limit       The time limit after which processing should stop.
    /// @arg {Real} [steps]     A number of steps to perform regardless of the time limit.
    /// @returns {Bool}
    static run_until = function(_limit, _steps = 1) {
        if (!prepare_task())
            return true;
        
        while (_steps > 0 || get_timer() <= _limit) {
            _steps = ongoing_task.run_until(_limit, _steps) - 1; // run_until of the task returns "remaining steps + 1"
            if (_steps == -1)
                return false;
            
            ongoing_task = undefined;
            if (!prepare_task())
                return true;
        }
        return false;
    }
    
    /// @desc Executes scheduled tasks until all are finished, successfully or otherwise.
    /// @returns {Bool}
    static run_to_end = function() {
        while (prepare_task()) {
            ongoing_task.run_to_end();
            ongoing_task = undefined;
        }
        return true;
    }
    
    /// @ignore
    static prepare_task = function() {
        if (!is_undefined(ongoing_task))
            return true; // there is an ongoing task already
        
        ongoing_task = array_shift(pending_tasks);
        if (is_undefined(ongoing_task))
            return false; // there are no tasks remaining
        
        ongoing_task.init();
        return true;
    } 
    
    /// @desc Attempts to cancel the given task, or all scheduled tasks. Returns whether at least one task was canceled as a result.
    /// @arg {Struct} [task]    The specific task to cancel. If none is given, all scheduled tasks are canceled.
    /// @returns {Bool}
    static try_cancel = function(_task = undefined) {
        if (!is_busy())
            return false;
        
        var _result = false;
        if (is_undefined(_task)) {
            if (!is_undefined(ongoing_task)) {
                _result = _result || ongoing_task.try_cancel();
                ongoing_task = undefined;
            }
            _result = array_reduce(pending_tasks, function(_res, _task) { return _res || _task.try_cancel(); }, _result);
            array_resize(pending_tasks, 0);
            return _result;
        } else if (ongoing_task == _task) {
            var _result = ongoing_task.try_cancel();
            ongoing_task = undefined;
            return _result;
        } else {
            var _idx = array_get_index(pending_tasks, _task);
            if (_idx < 0)
                return false;
            
            var _result = pending_tasks[_idx].try_cancel();
            array_delete(pending_tasks, _idx, 1);
            return _result;
        }
    }
}
