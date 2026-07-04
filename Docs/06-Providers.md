[Home](/README.md)

**Previous:** [Workers](/Docs/05-Workers.md)

# Providers

The providers system helps with delivering necessary dependencies to whichever entities requested them. For example:

- a dialogue system may require the player name or the current time to display within the dialogue
- the player may request a jumping sound or a walking sound from an audio provider, with the walking sound having a slightly randomised pitch
- an enemy may request a movement pattern, with "idle" pattern using a shared instance and "follow" pattern having separate instances for each enemy

## Interfaces

The providers system uses the following types:

- **ProviderResolver** interface, exposing the method for resolving and delivering a given value
- **Provider** interface, exposing methods for retrieving values based on a specifier and optional arguments

Details may vary between implementations, but as a rule of thumb one may expect:

- the Provider will accept a **specifier** and optional **arguments** to resolve the value with
- the Provider may map the specifier onto a **key** to find the resolver with
- based on these, the Provider will decide on the best resolution method for the given value
- the resolution method will accept the given arguments, the Provider itself, the specifier originally passed to the provider and the key the provider used for mapping

---

The **ProviderResolver** interface requires the following method:

- `resolve(args: Any, provider: Provider, specifier: Any, key: Any) -> Any` - a method delivering the required value based on given arguments (if any); it may additionally use the provider to resolve additional dependencies, or the specifier and the key used for resolving the value

Because Feather doesn't recognise interface types, the provider resolver type is specified in JSDoc as `Struct`

---

The **Provider** interface requires the following methods:

- `can_provide(specifier: Any, [args: Any]) -> Bool` - a method checking if the provider can resolve a value for the given specifier and arguments
- `try_provide(specifier: Any, [args: Any]) -> Any` - a method attempting to resolve a value for the given specifier and arguments; if it's not possible, returns **undefined**
- `provide(specifier: Any, [args: Any]) -> Any` - a method resolving a value for the given specifier and arguments; if the value cannot be resolved, an exception should be thrown

Because Feather doesn't recognise interface types, the provider type is specified in JSDoc as `Struct`

## Implementation

In Cimpli library, the provider resolver and the provider itself are implemented with **CimpliProviderResolver** and **CimpliResolver** constructors.

---

**CimpliProviderResolver** is a basic provider resolver implementation, either delivering a fixed value or generating a new one every time. Its constructor has the following parameters:

- `source: Any` - the source of the resolved value
- `[constant: Bool]` - an optional flag specifying whether the source should be treated as a value itself or a generator method; if not specified, the source will be treated as a generator if it's not a method or as a fixed value otherwise

CimpliProviderResolver implements the **ProviderResolver** interface in the following way:

- `resolve` - if marked as constant, returns the source value itself; otherwise, it calls the source method with all arguments (resolve arguments, provider, specifier and key)

---

**CimpliProvider** is a basic provider implementation, finding the relevant resolver based on a key and then using the resolver to determine the value to deliver. Its constructor has the following arguments:

- `[ignorecase: Bool]` - whether the provider should use case-insensitive search when finding resolvers or not

CimpliProvider implements the **Provider** interface in the following way:

- `can_provide` - checks if a resolver has been registered with the given specifier/key
- `try_provide` - finds the resolver registered with the given specifier/key and provides the value resolved with it; if not found, returns **undefined**
- `provide` - finds the resolver registered with the given specifier/key and provides the value resolved with it; if not found, throws an exception

Additionally, CimpliProvider exposes the following methods for managing available resolvers:

- `add_resolver(specifier: Any, resolver: ProviderResolver) -> Undefined` - registers a resolver under the given specifier; when a matching registration already exists, throws an exception
- `add_value(specifier: Any, value: Any) -> Undefined` - creates a CimpliProviderResolver with a given fixed value and registers it under the given specifier; when a matching registration already exists, throws an exception
- `add_generator(specifier: Any, generator: Function) -> Undefined` - creates a CimpliProviderResolver with a given generator method and registers it under the given specifier; when a matching registration already exists, throws an exception
- `put_resolver(specifier: Any, resolver: ProviderResolver) -> Undefined` - registers a resolver under the given specifier; replaces an already existing matching registration, if any
- `put_value(specifier: Any, value: Any) -> Undefined` - creates a CimpliProviderResolver with a given fixed value and registers it under the given specifier; replaces an already existing matching registration, if any
- `put_generator(specifier: Any, generator: Function) -> Undefined` - creates a CimpliProviderResolver with a given generator method and registers it under the given specifier; replaces an already existing matching registration, if any
- `remove_resolver(specifier: Any) -> Bool` - removes the resolver registration for the given specifier; returns whether a resolver was successfully removed
- `try_get_resolver(specifier: Any) -> ProviderResolver` - attempts to get a resolver registered under the given specifier; if none is found, returns **undefined**
- `get_resolver(specifier: Any) -> ProviderResolver` - gets a resolver registered under the given specifier; if none is found, throws an exception

CimpliProvider converts the specifier to the string using either the `string` method (when case-sensitive) or `string_lower` method (when case-insensitive). That way, it can handle not only string keys, but also specific numbers, asset handles and similar primitive-like values. Arrays or structs shouldn't be used as specifiers, but in most reasonable use-cases they aren't needed, anyway.

## Example

The following example demonstrates using the providers system for delivering enemy movement behaviour.

**Note:** This example uses `script_get_name` for resolving values. That's because GameMaker sometimes treats script references as numbers (represented as something like "1000089"), and sometimes as handles (represented as something like "ref script SomeScript"). Other asset types shouldn't have this inconsistency.

The `EnemyMovementIdle` constructor:

```gml
function EnemyMovementIdle() constructor {
    static apply = function(_enemy, _timer) {
        // do nothing
    }
}
```

The `EnemyMovementLine` constructor:

```gml
function EnemyMovementLine(_spd, _dir) constructor {
    hspd = lengthdir_x(_spd, _dir);
    vspd = lengthdir_y(_spd, _dir);
    
    static apply = function(_enemy, _timer) {
        _enemy.x += hspd;
        _enemy.y += vspd;
    }
}
```

The `EnemyMovementWave` constructor:

```gml
function EnemyMovementWave(_length, _amplitude, _dir, _period) constructor {
    hspd = lengthdir_x(_length / _period, _dir);
    vspd = lengthdir_y(_length / _period, _dir);
    
    wave_xoffset = lengthdir_x(_amplitude, _dir + 90);
    wave_yoffset = lengthdir_y(_amplitude, _dir + 90)
    period = _period;
    
    static apply = function(_enemy, _timer) {
        var _wave_factor = dsin(360 * _timer / period);
        _enemy.x = _enemy.xstart + hspd * _timer + wave_xoffset * _wave_factor;
        _enemy.y = _enemy.ystart + vspd * _timer + wave_yoffset * _wave_factor;
    }
}
```

Somewhere on the startup:

```gml
global.enemy_movement_provider = new CimpliProvider();
global.enemy_movement_provider.add_value(script_get_name(EnemyMovementIdle), new EnemyMovementIdle());
global.enemy_movement_provider.add_generator(script_get_name(EnemyMovementLine), function(_config) {
    return new EnemyMovementLine(_config.spd, _config.dir);
});
global.enemy_movement_provider.add_generator(script_get_name(EnemyMovementWave), function(_config) {
    return new EnemyMovementWave(_config.length, _config.amplitude, _config.dir, _config.period);
});
```

**Create** event of the `obj_Enemy` object, with `movement_type` and `movement_config` object variables:

```gml
movement = global.enemy_movement_provider.provide(script_get_name(movement_type), movement_config);
timer = 0;
```

**Step** event of the `obj_Enemy` object:

```gml
movement.apply(id, ++timer);
```
