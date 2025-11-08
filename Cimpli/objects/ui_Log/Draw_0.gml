draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_font(fnt_Log);

for (var i = 0, _count = array_length(logs); i < _count; i++) {
    var _level = logs[i].level;
    var _abbreviation = level_abbreviation[$ _level];
    var _message = logs[i].message;
    
    draw_set_color(level_colors[$ _level]);
    draw_text(x + 10, y + 10 + 20 * i, $"{_abbreviation}  {_message}");
}
