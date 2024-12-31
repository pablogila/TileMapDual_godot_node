// Based on jess::codes https://www.youtube.com/watch?v=eYlBociPwdw and https://www.youtube.com/watch?v=QB2o5Dys6Tc

shader_type canvas_item;

uniform sampler2D overlay: repeat_enable, filter_nearest;
uniform vec4 fg_color : source_color;
uniform vec4 bg_color : source_color;
uniform float tolerance : hint_range(0,1);

uniform float scale = 0.0078125; // calculated by 1/texture size e.g. 1/128
uniform float tile_size = 32.0;
varying vec2 world_position;

void vertex(){
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, tile_size)).xy;
}

void fragment() {
    vec4 curr_color = texture(TEXTURE, UV);
    float dist_bg = distance(curr_color.rgb, bg_color.rgb);

    if (dist_bg < tolerance) {
        discard;
    }

    vec2 local_position = mod(world_position, tile_size);

    vec4 overlay_color = texture(overlay, fract(local_position * scale));

    float dist_fg = distance(curr_color.rgb, fg_color.rgb);

    if (dist_fg < tolerance) {
        COLOR = overlay_color;
    }
}