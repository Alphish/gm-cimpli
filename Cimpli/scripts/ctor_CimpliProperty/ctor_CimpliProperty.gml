/// @desc A basic property implementation, with a value getter and setter and value change event subject.
/// @arg {Any} [initial]        The initial property value.
function CimpliProperty(_initial = undefined) constructor {
    /// @desc The value of the property.
    /// @returns {Any}
    value = _initial;
    
    /// @desc The event subject notifying about value changes.
    /// @returns {Struct}
    value_changed = new CimpliEventSubject(self);
    
    /// @desc Gets the value of the property.
    /// @returns {Any}
    static get_value = function() {
        return value;
    }
    
    /// @desc Sets the value of the property.
    /// @args {Any} value       The new value to set.
    static set_value = function(_value) {
        if (_value == value)
            return; // no changes needed
        
        value = _value;
        value_changed.send(value);
    }
}
