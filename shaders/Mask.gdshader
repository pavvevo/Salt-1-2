shader_type spatial;
render_mode unshaded;
render_mode cull_disabled;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void vertex() {

}

void fragment() {
	ALBEDO = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
}