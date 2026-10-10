last_info_layer = "Info_Intro";
info_layer_signal = new CimpliSignal("Info_Intro");
info_layer_signal.when_value_changed_subject().add_handler(function(_layer) {
    layer_set_visible(last_info_layer, false);
    layer_set_visible(_layer, true);
    last_info_layer = _layer;
});
