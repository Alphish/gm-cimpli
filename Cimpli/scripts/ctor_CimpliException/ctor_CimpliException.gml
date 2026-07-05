/// @desc An exception to be thrown due to invalid Cimpli usage.
/// @arg {String} code              The code of the exception to differentiate between different exception causes.
/// @arg {String} description       A detailed description explaining the exception.
function CimpliException(_code, _description) constructor {
    /// @desc The code of the exception to differentiate between different exception causes.
    /// @type {String}
    code = _code;
    
    /// @desc A detailed description explaining the exception.
    /// @type {String}
    description = _description;
    
    toString = function() {
        return $"Cimpli.{code}: {description}";
    }
}

// -------------------
// Creating exceptions
// -------------------

/// @desc Creates a Cimpli method not implemented exception, thrown from base methods to be implemented in derived type.
/// @arg {Struct} context           The instance whose method was not implemented.
/// @arg {String} method            The name of method that requires implementation in the derived type.
CimpliException.not_implemented = function(_context, _method) {
    return new CimpliException(
        nameof(not_implemented),
        $"{instanceof(_context)}.{_method} was not implemented."
        );
}

/// @desc Creates a Cimpli duplicate key exception, thrown when adding an entry to a collection with the matching key already present.
/// @arg {String} context           The description of the collection containing the matching key.
/// @arg {Any} key                  The key of the entry being added.
CimpliException.duplicate_key = function(_collection, _key) {
    return new CimpliException(
        nameof(duplicate_key),
        $"{_collection} already contains an entry with the '{_key}' key."
        );
}

/// @desc Creates a Cimpli unknown key exception, thrown when accessing a collection without a matching key.
/// @arg {String} context           The description of the collection being accessed.
/// @arg {Any} key                  The key of the entry being accessed.
CimpliException.unknown_key = function(_collection, _key) {
    return new CimpliException(
        nameof(unknown_key),
        $"{_collection} does not contain any entry with the '{_key}' key."
        );
}
