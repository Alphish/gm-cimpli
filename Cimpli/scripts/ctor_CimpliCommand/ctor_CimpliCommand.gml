/// @desc A simple implementation of the command, with its execution logic and optional check if execution is possible.
/// @arg {Function} action          A function performed upon execution.
/// @arg {Function} [condition]     A function returning whether the command can be executed.
function CimpliCommand(_action, _condition = undefined) constructor {
    /// @desc A function performed upon execution.
    /// @returns {Function}
    action = _action;
    
    /// @desc A function returning whether the command can be executed, or undefined.
    /// @returns {Function,Undefined}
    condition = _condition;
    
    /// @desc Executes the command. A parameter can be optionally given.
    /// @arg {Any} [parameter]      The parameter used during execution.
    static execute = function(_parameter = undefined) {
        if (can_execute(_parameter))
            action(_parameter);
    }
    
    /// @desc Checks if the command can be executed. A parameter to execute the command with can be optionally given.
    /// @arg {Any} [parameter]      The parameter used during execution.
    /// @returns {Bool}
    static can_execute = function(_parameter = undefined) {
        return is_undefined(condition) ? true : condition(_parameter);
    }
}
