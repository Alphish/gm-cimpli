/// @desc A basic resolver implementation, with a resolved value source given as a fixed value or a method returning the value.
/// @arg {Any} source               The source of the resolved value.
/// @arg {Bool} [constant]          Whether the value should be provider as-is or resolved as method/function call.
function CimpliProviderResolver(_source, _constant = undefined) constructor {
    /// @desc The source of the resolved value.
    /// @returns {Any}
    source = _source;
    
    /// @desc Indicates whether the source provides a fixed value or generates a method result.
    /// @returns {Bool}
    is_constant = _constant ?? !is_method(source);
    
    /// @desc Resolves the value to provide.
    /// @arg {Any} args             Additional arguments to resolve the value with.
    /// @arg {Struct} provider      The provider for resolving additional dependencies.
    /// @arg {Any} specifier        The specifier used to request the value.
    /// @arg {Any} key              The key used to find the entry.
    /// @returns {Any}
    static resolve = function(_args, _provider, _specifier, _key) {
        return is_constant ? source : source(_args, _provider, _specifier, _key);
    }
}
