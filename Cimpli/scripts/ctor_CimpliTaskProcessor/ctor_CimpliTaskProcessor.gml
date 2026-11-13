/// @desc A basic task processor base, with its processor logic.
function CimpliTaskProcessor() constructor {
    /// @desc Indicates whether the task processing has completed successfully or not.
    /// @returns {Bool}
    is_completed = false;
    
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
    
    /// @desc Updates the task processing status or progress before reporting an update. Returns whether some progress should be reported or not.
    /// @returns {Bool}
    static prepare_update = function() {
        return true;
    }
    
    /// @desc Finishes processing the task.
    /// @returns {Bool}
    static complete = function() {
        is_completed = true;
        return true;
    }
    
    /// @desc Successfully completes the task with the given result.
    /// @arg {Any} result       The result to complete the task with.
    /// @returns {Bool}
    static complete_with = function(_result) {
        result = _result;
        return complete();
    }
    
    /// @desc Cleans up the task resources, if any.
    /// @arg {Bool} auto        Indicates if the cleanup was called manually (false) or from the general task management system (true).
    static cleanup = function(_auto = false) {
        // nothing by default
    }
}
