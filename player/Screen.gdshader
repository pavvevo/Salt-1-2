shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;
varying vec3 world_pos;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
	world_pos = NODE_POSITION_WORLD + VERTEX;
}

void fragment() {
	vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	
	color = mix(color, vec3(0.0, 0.0, 1.0), step(0.0, world_pos.y));
	
	ALBEDO = color;
}
