logs = [];

level_colors = {
    "TRACE": c_gray,
    "DEBUG": c_silver,
    "INFO": c_aqua,
    "SUCCESS": c_lime,
    "WARNING": c_yellow,
    "ERROR": c_orange,
    "CRITICAL": c_red,
};

level_abbreviation = {
    "TRACE": "TRC",
    "DEBUG": "DBG",
    "INFO": "INF",
    "SUCCESS": "SCS",
    "WARNING": "WRN",
    "ERROR": "ERR",
    "CRITICAL": "CRT",
};

max_logs = (room_height - 40) div 20;

add_log = function(_level, _message) {
    array_push(logs, { level: _level, message: _message });
    while (array_length(logs) > max_logs)
        array_shift(logs);
}
