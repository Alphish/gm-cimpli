function UiLogger(_level = undefined) : CimpliLogger(_level) constructor {
    static write_log = function(_level, _message) {
        ui_Log.add_log(_level, _message);
    }
}
