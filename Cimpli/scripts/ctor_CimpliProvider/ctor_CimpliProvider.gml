/// @desc A basic resource/dependency provider implementation, resolving the applicable value for a given specifier and optional additional arguments.
/// @arg {Bool} ignorecase      Whether the specifier to resolve should be handled in a case-insensitive manner or not.
function CimpliProvider(_ignorecase = false) constructor {
    /// @desc Indicates whether specifiers to resolve are handler in a case-insensitive manner.
    /// @returns {Bool}
    ignore_case = _ignorecase;
    
    /// @desc A struct mapping specifier strings to relevant resolvers.
    /// @returns {Struct}
    resolvers = {};
    
    /// @ignore
    static resolve_key = function(_specifier) {
        return ignore_case ? string_lower(_specifier) : string(_specifier);
    }
    
    // ---------
    // Resolvers
    // ---------
    
    /// @desc Registers a resolver with the given specifier. If a matching specifier already exists, an error will be thrown.
    /// @arg {Any} specifier        The specifier to register the resolver with.
    /// @arg {Struct} resolver      The resolver to deliver a value when requested.
    static add_resolver = function(_specifier, _resolver) {
        var _key = resolve_key(_specifier);
        if (struct_exists(resolvers, _key))
            throw CimpliException.duplicate_key("The provider", _key);
        
        resolvers[$ _key] = _resolver;
    }
    
    /// @desc Registers a constant value resolver with the given specifier. If a matching specifier already exists, an error will be thrown.
    /// @arg {Any} specifier        The specifier to register the resolver with.
    /// @arg {Any} value            The value to resolve the specifier to.
    static add_value = function(_specifier, _value) {
        var _resolver = new CimpliProviderResolver(_value, /* constant */ true);
        add_resolver(_specifier, _resolver);
    }
    
    /// @desc Registers a value generator resolver with the given specifier. If a matching specifier already exists, an error will be thrown.
    /// @arg {Any} specifier        The specifier to register the resolver with.
    /// @arg {Function} generator   The generator of the value to resolve the specifier to.
    static add_generator = function(_specifier, _generator) {
        var _resolver = new CimpliProviderResolver(_generator, /* constant */ false);
        add_resolver(_specifier, _resolver);
    }
    
    /// @desc Registers a resolver with the given specifier. If a matching specifier already exists, it will be overwritten.
    /// @arg {Any} specifier        The specifier to register the resolver with.
    /// @arg {Struct} resolver      The resolver to deliver a value when requested.
    static put_resolver = function(_specifier, _resolver) {
        var _key = resolve_key(_specifier);
        resolvers[$ _key] = _resolver;
    }
    
    /// @desc Registers a constant value resolver with the given specifier. If a matching specifier already exists, it will be overwritten.
    /// @arg {Any} specifier        The specifier to register the resolver with.
    /// @arg {Any} value            The value to resolve the specifier to.
    static put_value = function(_specifier, _value) {
        var _resolver = new CimpliProviderResolver(_value, /* constant */ true);
        put_resolver(_specifier, _resolver);
    }
    
    /// @desc Registers a value generator resolver with the given specifier. If a matching specifier already exists, it will be overwritten.
    /// @arg {Any} specifier        The specifier to register the resolver with.
    /// @arg {Function} generator   The generator of the value to resolve the specifier to.
    static put_generator = function(_specifier, _generator) {
        var _resolver = new CimpliProviderResolver(_generator, /* constant */ false);
        put_resolver(_specifier, _resolver);
    }
    
    /// @desc Removes the resolver registered under the given specifier. Returns whether a matching specifier was found and removed.
    /// @arg {Any} specifier        The specifier to remove the resolver of.
    /// @returns {Bool}
    static remove_resolver = function(_specifier) {
        var _key = resolve_key(_specifier);
        if (!struct_exists(resolvers, _key))
            return false;
        
        struct_remove(resolvers, _key);
        return true;
    }
    
    /// @desc Attempts to retrieve a resolver with a given specifier. If no resolver is found, returns the undefined value.
    /// @arg {Any} specifier        The specifier to find the resolver of.
    /// @returns {Struct,Undefined}
    static try_get_resolver = function(_specifier) {
        var _key = resolve_key(_specifier);
        return resolvers[$ _key];
    }
    
    /// @desc Retrieves a resolver with a given specifier. If no resolver is found, an error is thrown.
    /// @arg {Any} specifier        The specifier to find the resolver of.
    /// @returns {Struct}
    static get_resolver = function(_specifier) {
        var _key = resolve_key(_specifier);
        if (!struct_exists(resolvers, _key))
            throw CimpliException.unknown_key("The provider", _key);
        
        return resolvers[$ _key];
    }
    
    // ---------
    // Providing
    // ---------
    
    /// @desc Checks if a value can be resolved and provided for a given specifier and arguments.
    /// @arg {Any} specifier        The specifier to check.
    /// @arg {Any} [args]           Additional arguments to resolve the value with.
    /// @returns {Bool}
    static can_provide = function(_specifier, _args = undefined) {
        var _key = resolve_key(_specifier);
        return struct_exists(resolvers, _key);
    }
    
    /// @desc Attempts to resolve a value with a given specifier and optional arguments. If the value cannot be resolved, the undefined value is returned.
    /// @arg {Any} specifier        The specifier to resolve the value of.
    /// @arg {Any} [args]           Additional arguments to resolve the value with.
    /// @returns {Any}
    static try_provide = function(_specifier, _args = undefined) {
        var _key = resolve_key(_specifier);
        var _resolver = resolvers[$ _key];
        return !is_undefined(_resolver) ? _resolver.resolve(_args, self, _specifier, _key) : undefined;
    }
    
    /// @desc Attempts to resolve a value with a given specifier and optional arguments. If the value cannot be resolved, an error is thrown.
    /// @arg {Any} specifier        The specifier to resolve the value of.
    /// @arg {Any} [args]           Additional arguments to resolve the value with.
    /// @returns {Any}
    static provide = function(_specifier, _args = undefined) {
        var _key = resolve_key(_specifier);
        if (!struct_exists(resolvers, _key))
            throw CimpliException.unknown_key("The provider", _key);
        
        var _entry = resolvers[$ _key];
        return _entry.resolve(_args, self, _specifier, _key);
    }
}
