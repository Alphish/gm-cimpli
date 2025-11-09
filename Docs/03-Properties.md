[Home](/README.md)

**Previous:** [Commands](/Docs/02-Commands.md)

# Properties

A properties system can be used for managing and providing specific values. In particular, properties can attach additional logic to setting a value, making sure it's in the correct range or having related values update as well. They can be helpful for binding to UI systems, exposing special variables to a scripting system etc.

## Interface

The properties system consists of a single type, the **Property** interface, which requires the following members:

- `get_value() -> Any` - a method to retrieve the property value
- `set_value(value: Any) -> Undefined` - a method to set the property value
- `value_changed: EventSubject` - an [event subject](/Docs/01-Events.md) that notifies about returned property value changing

Because Feather doesn't recognise interface types, the property type is specified in JSDoc as `Struct`

## Implementation

In Cimpli library, the property interface is implemented with **CimpliProperty** constructor. It stores and provides its own value. It has the following arguments:

- `[initial]: Any` - the initial value of the property, undefined by default

CimpliProperty implements the **Property** interface in the following way:

- `get_value` - returns the value of its stored property
- `set_value` - sets the value of its stored property and, if it's different, sends an event via the `value_changed` subject
- `value_changed` - automatically created as an instance of CimpliEventSubject

## Example

The following example demonstrates using the properties system to implement a color picker:

**Create** event of the `ui_ColorPicker` object:

```gml
color = c_white;

red_property = new CimpliProperty(color_get_red(color));
green_property = new CimpliProperty(color_get_green(color));
blue_property = new CimpliProperty(color_get_blue(color));

recalculate_color = function() {
    color = make_color_rgb(red_property.get_value(), green_property.get_value(), blue_property.get_value());
}

red_property.value_changed.add_handler(recalculate_color);
green_property.value_changed.add_handler(recalculate_color);
blue_property.value_changed.add_handler(recalculate_color);

// create sliders for specific components
instance_create_depth(x + 4, y + 4, depth - 10, ui_ColorSlider, { color_component_property: red_property, image_blend: c_red });
instance_create_depth(x + 4, y + 20, depth - 10, ui_ColorSlider, { color_component_property: green_property, image_blend: c_lime });
instance_create_depth(x + 4, y + 36, depth - 10, ui_ColorSlider, { color_component_property: blue_property, image_blend: c_blue });
```

**Step** event of the `ui_ColorSlider` object:

```gml
// perform various slider interaction logic
// and determine up-to-date slider value

// apply the latest slider value to its bound property
color_component_property.set_value(slider_value);
```

**Next:** [Logging](/Docs/04-Logging.md)
