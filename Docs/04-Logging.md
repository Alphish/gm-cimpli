[Home](/README.md)

**Previous:** [Properties](/Docs/03-Properties.md)

# Logging

A logging system is useful for recording various events and information during the game's runtime. Different loggers might record different events - for example, a debug message logger would cover all events, while an in-game console logger would only record warnings and errors.

## Interface

The logging system consists of a single type, the **Logger** interface, which requires the following methods:

- `log_message(level: String, message: Any) -> Undefined` - logs a message with the given level
- `log_trace(message: Any) -> Undefined` - logs a message with the TRACE level
- `log_debug(message: Any) -> Undefined` - logs a message with the DEBUG level
- `log_info(message: Any) -> Undefined` - logs a message with the INFO level
- `log_success(message: Any) -> Undefined` - logs a message with the SUCCESS level
- `log_warning(message: Any) -> Undefined` - logs a message with the WARNING level
- `log_error(message: Any) -> Undefined` - logs a message with the ERROR level
- `log_critical(message: Any) -> Undefined` - logs a message with the CRITICAL level

For more flexibility, a logger can accept any kind of message, and it's up to the implementation to handle whatever message comes its way accordingly.

Because Feather doesn't recognise interface types, the property type is specified in JSDoc as `Struct`

## Implementation

In Cimpli library, the logger interface is implemented with **CimpliLogger** constructor. It has the following arguments:

- `[level]: String,Array,Struct` - the minimum logging level, or an array or a struct of applicable levels

CimpliLogger implements the **Logger** interface by making `log_message` check if the given level is applicable, and if so, writing the message to the debug output. On top of that, `log_trace`, `log_debug`, `log_info` etc. are implemented by making a `log_message` call with a correct level. This makes **CimpliLogger** useful as a base for more specific loggers, overriding core message logging while keeping level-specific methods intact.

Internally, `log_message` of CimpliLogger uses the following methods:
- `filter_level(level: String) -> Bool` - returns whether a given log message level is applicable
- `write_log(level: String, message: Any) -> Undefined` - writes the log message after confirming the level is applicable

In particular, `filter_level`:

- given the undefined logger level, treats it as always true
- given a level string, logs messages of that level's importance or higher (from the least to the most important: TRACE, DEBUG, INFO, SUCCESS, ERROR, CRITICAL)
- given an array of level strings, logs messages only for levels given in the array
- given a struct with level string key, logs messages only if the level value exists on the struct and if it's true

A developer may choose to replace the `filter_level` or `write_log` function in their implementation derived from CimpliLogger, to change the core logging logic while keeping the surrounding utilities.

## Example

This example showcases a custom logger derived from CimpliLogger to include a timestamp.

```gml
function TimestampLogger(_level = undefined) : CimpliLogger(_level) constructor {
    static write_log = function(_level, _message) {
        var _hours = string_replace(string_format(current_hour, 2, 0), " ", "0");
        var _minutes = string_replace(string_format(current_minute, 2, 0), " ", "0");
        var _seconds = string_replace(string_format(current_second, 2, 0), " ", "0");
        show_debug_message($"[{_hours}:{_minutes}:{_seconds}] {_level}: {_message}");
    }
}
```

The following code creates a logger for the log level of SUCCESS or higher, then tries logging a message for each built-in level:

```gml
var _logger = new TimestampLogger("SUCCESS");
_logger.log_trace("This is a trace message.");
_logger.log_debug("This is a debug message.");
_logger.log_info("This is an info message.");
_logger.log_success("This is a success message.");
_logger.log_warning("This is a warning message.");
_logger.log_error("This is an error message!");
_logger.log_critical("This is a critical message!!!");
```

In the output, only the success, warning, error and critical messages were written:

```
[20:47:52] SUCCESS: This is a success message.
[20:47:52] WARNING: This is a warning message.
[20:47:52] ERROR: This is an error message!
[20:47:52] CRITICAL: This is a critical message!!!
```
