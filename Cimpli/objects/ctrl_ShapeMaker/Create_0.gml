shape_sprite_property = new CimpliProperty(spr_ShapeRound);
shape_size_property = new CimpliProperty(1);
shape_color_property = new CimpliProperty(c_red);

shape_provider = new CimpliProvider();

shape_provider.add_generator(spr_ShapeRound, function(_provider, _args) {
    var _instargs = { sprite_index: spr_ShapeRound, image_xscale: _args.size, image_yscale: _args.size, image_blend: _args.color };
    return instance_create_layer(0, 0, "Shapes", obj_ExampleShape, _instargs);
    });

shape_provider.add_generator(spr_ShapeSquare, function(_provider, _args) {
    var _instargs = { sprite_index: spr_ShapeSquare, image_xscale: _args.size, image_yscale: _args.size, image_blend: _args.color, image_angle: random(360) };
    return instance_create_layer(0, 0, "Shapes", obj_ExampleShape, _instargs);
    });

shape_provider.add_generator(spr_ShapeTriangle, function(_provider, _args) {
    var _instargs = { sprite_index: spr_ShapeTriangle, image_xscale: _args.size, image_yscale: _args.size, image_blend: _args.color, image_angle: random(360) };
    return instance_create_layer(0, 0, "Shapes", obj_ExampleShape, _instargs);
    });

var _star_instance = instance_create_layer(room_width div 2, room_height div 2, "Shapes", obj_ExampleShape, { sprite_index: spr_ShapeStar, image_blend: #FFC000, unique: true });
shape_provider.add_value(spr_ShapeStar, _star_instance);

make_shape = function(_x, _y) {
    var _sprite = shape_sprite_property.get_value();
    var _args = { size: shape_size_property.get_value(), color: merge_color(shape_color_property.get_value(), c_white, 0.5) };
    var _shape = shape_provider.provide(_sprite, _args);
    _shape.x = _x;
    _shape.y = _y;
}

view_instructions_command = new CimpliCommand(function() {
    layer_set_visible("Instructions", true);
});
