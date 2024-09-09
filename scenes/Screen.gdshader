shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
}