# Cimpli

**Cimpli** - or Common Implementations Library - provides basic implementations of certain recurring types. Other libraries may interact with such types and need simple implementations to use as sensible defaults; **Cimpli** provides such defaults.

## Installation

The Cimpli package has been developed on **GameMaker 2024.14**. It may not work correctly on older versions.

1. Download the Local Package YYMPS file: ...
2. Follow the [GameMaker manual instructions](https://manual.gamemaker.io/monthly/en/#t=IDE_Tools%2FLocal_Asset_Packages.htm) to import the package; import all the assets.
3. The Cimpli implementations should be ready to use!

## Interfaces and Implementations

To better understand the purpose of the library, it's worth learning about interfaces and implementations.

An **interface** describes a set of fields and methods expected to be present on a specific structure. Moreover, an interface carries expectations about types of individual variables, method arguments and return values.

An **implementation** of the interface is a specific entity that matches the interface structure. The implementation might have additional variables and methods on top of what interface expects and different implementations usually have different internal logic of corresponding interface methods, but general expectations are still met - none of variables or methods should be missing, and all of them have compatible types.

Certain programming languages may provide means to strictly specify an interface; GameMaker Language does not. Even so, the concept of the interface - a set of variables and methods another entity may interact with - is still applicable within GameMaker development.

For example, a developer may want to create an inventory system. The inventory expects each of its items to have a string `name` variable, a string `description` variable, an enumeration `type` variable and a numeric `price` variable. All this together can be understood as an "inventory item" interface of sorts, even if the developer may not treat it as such. The inventory may contain instances of `ConsumableItem` or `WeaponItem` or `ArmorItem` constructors, or maybe even plain structs not matching any constructor. But as long as each item is a valid implementation of the "inventory item" interface - i.e. containing the name/description/type/price variables with correct types - the inventory system should be able to handle it properly, even if some items have `consume()` method while others have `equip(slot)` method on top of the common "inventory item" variables.

With that in mind, Cimpli library's purpose is twofold:

- serve as a point of reference for common interfaces used across other libraries
- provide sensible default implementations to libraries that interact with these interfaces

## Cimpli types

The following types are specified and implemented in Cimpli:

- [Events](/Docs/01-Events.md) - an event subject to notify about important occurrences and an event observer to receive and handle these notifications
- [Commands](/Docs/02-Commands.md) - a command to store execution logic regardless of interaction used to trigger it
- [Properties](/Docs/03-Properties.md) - a property to keep track of a value and notify about its changes
