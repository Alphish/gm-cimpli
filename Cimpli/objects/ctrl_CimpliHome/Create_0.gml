last_info_layer = "Info_Intro";
info_layer_property = new CimpliProperty("Info_Intro");
info_layer_property.value_changed.add_handler(function(_layer) {
    layer_set_visible(last_info_layer, false);
    layer_set_visible(_layer, true);
    last_info_layer = _layer;
});
