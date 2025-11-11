if (!is_enabled)
    image_blend = c_gray;
else if (is_hovered)
    image_blend = hover_color;
else
    image_blend = base_color;

draw_self();

draw_set_color(c_black);
draw_set_alpha(1);
draw_set_font(fnt_Title);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x + sprite_width div 2, y + sprite_height div 2, text);

draw_set_color(c_white);
draw_set_alpha(1);
