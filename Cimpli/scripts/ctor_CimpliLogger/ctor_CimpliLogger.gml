/// @desc A simple implementation of the logger, with methods to handle logging different kinds of events.
/// @arg {String,Array,Struct} [level]      The minimum logging level, or an array or a struct of applicable levels.
function CimpliLogger(_level = undefined) constructor {
    /// @desc Specifies applicable logging levels.
    /// @returns {String,Array,Struct,Undefined}
    level = _level;
    
    // ------------
    // Core logging
    // ------------
    
    /// @desc Logs a message with a given level, if the level is applicable.
    /// @arg {String} level     The level to log the message with.
    /// @arg {Any} message      The message to log.
    static log_message = function(_level, _message) {
        var _upper_level = string_upper(_level);
        if (filter_level(_upper_level))
            make_log(_upper_level, _message);
    }
    
    /// @desc Determines whether the given logging level applies to the given logger.
    /// @arg {String} level     The level to check.
    /// @returns {Bool}
    static filter_level = function(_level) {
        static severity_values = {
            "TRACE": 0,
            "DEBUG": 10,
            "INFO": 20,
            "SUCCESS": 30,
            "WARNING": 40,
            "ERROR": 50,
            "CRITICAL": 60,
        };
        
        if (is_undefined(level))
            return true;
        else if (is_array(level))
            return array_contains(level, _level);
        else if (is_struct(level))
            return level[$ _level] == true;
        else
            return (severity_values[$ level] ?? 0) <= (severity_values[$ _level] ?? 0);
    }
    
    /// @desc Performs the logging operation after confirming the logging level is applicable.
    /// @arg {String} level     The level to log the message with.
    /// @arg {Any} message      The message to log.
    static make_log = function(_level, _message) {
        show_debug_message($"{_level}: {_message}");
    }
    
    // ---------------
    // Specific levels
    // ---------------
    
    /// @desc Logs a detailed trace message.
    /// @arg {Any} message      The message to log.
    static log_trace = function(_message) {
        log_message("TRACE", _message);
    }
    
    /// @desc Logs a debug message.
    /// @arg {Any} message      The message to log.
    static log_debug = function(_message) {
        log_message("DEBUG", _message);
    }
    
    /// @desc Logs an information message.
    /// @arg {Any} message      The message to log.
    static log_info = function(_message) {
        log_message("INFO", _message);
    }
    
    /// @desc Logs a success message.
    /// @arg {Any} message      The message to log.
    static log_success = function(_message) {
        log_message("SUCCESS", _message);
    }
    
    /// @desc Logs a warning message.
    /// @arg {Any} message      The message to log.
    static log_warning = function(_message) {
        log_message("WARNING", _message);
    }
    
    /// @desc Logs an error message.
    /// @arg {Any} message      The message to log.
    static log_error = function(_message) {
        log_message("ERROR", _message);
    }
    
    /// @desc Logs a critical error message.
    /// @arg {Any} message      The message to log.
    static log_critical = function(_message) {
        log_message("CRITICAL", _message);
    }
}
