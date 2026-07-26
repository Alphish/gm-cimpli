/// @desc A basic task processor base, with its processor logic.
function CimpliTaskProcessor() constructor {
    /// @desc The status of the task processing so far.
    /// @returns {Any}
    status = false;
    
    /// @desc The result of the task completion.
    /// @returns {Any}
    result = undefined;
    
    /// @desc The error causing the task failure.
    /// @returns {Any}
    error = undefined;
    
    /// @desc Prepares the task resources, if any.
    static init = function() {
        // nothing by default
    }
    
    /// @desc Performs a single step of the task processing logic.
    /// @returns {Bool}
    static process_step = function() {
        throw CimpliException.not_implemented(self, nameof(process_step));
    }
    
    /// @desc Returns the task progress so far.
    /// @returns {Any}
    static get_progress = function() {
        return undefined;
    }
    
    /// @desc Finishes processing the task.
    /// @returns {Bool}
    static finish = function() {
        status = true;
        return true;
    }
    
    /// @desc Successfully completes the task with the given result.
    /// @arg {Any} result       The result to complete the task with.
    /// @returns {Bool}
    static complete_with = function(_result) {
        result = _result;
        return finish();
    }
    
    /// @desc Finishes processing the task with the given result.
    /// @arg {Any} error        The error to fail the task with.
    /// @returns {Bool}
    static fail_with = function(_error) {
        error = _error;
        return finish();
    }
    
    /// @desc Returns whether the task processing has finished or not.
    /// @returns {Bool}
    static is_finished = function() {
        return bool(status);
    }
    
    /// @desc Cleans up the task resources, if any.
    /// @arg {Bool} auto        Indicates if the cleanup was called manually (false) or from the general task management system (true).
    static cleanup = function(_auto = false) {
        // nothing by default
    }
}
