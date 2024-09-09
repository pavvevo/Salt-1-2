shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

uniform float blend = 1.0;
uniform vec3 blend_color : source_color;
uniform sampler2D distortionTex : repeat_enable;

void fragment() {
	vec2 water_uv = SCREEN_UV;
	
	vec3 color = texture(SCREEN_TEXTURE, water_uv).rgb;
	if(blend >= 1.0) {
		float distortion = texture(distortionTex, UV + TIME / 10.0).r;	
		water_uv += distortion * 0.02;
		color = texture(SCREEN_TEXTURE, water_uv).rgb;
		
		color = color * blend_color;
	}
	
	COLOR = vec4(color, 1.0);
}
