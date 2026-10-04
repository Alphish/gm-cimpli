/// @desc A basic property implementation, with a value getter and setter and value change event subject.
/// @arg {Any} [initial]        The initial property value.
function CimpliProperty(_initial = undefined) constructor {
    /// @desc The value of the property.
    /// @returns {Any}
    value = _initial;
    
    /// @ignore
    value_changed = undefined;
    
    /// @desc Prepares and retrieves the event subject notifying about a value change.
    /// @returns {Struct}
    static when_value_changed_subject = function() {
        value_changed ??= new CimpliEventSubject(self);
        return value_changed;
    }
    
    /// @desc Gets the value of the property.
    /// @returns {Any}
    static get_value = function() {
        return value;
    }
    
    /// @desc Sets the value of the property.
    /// @arg {Any} value        The new value to set.
    static set_value = function(_value) {
        if (_value == value)
            return; // no changes needed
        
        value = _value;
        if (!is_undefined(value_changed))
            value_changed.send(value);
    }
}
