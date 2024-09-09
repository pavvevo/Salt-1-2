shader_type spatial;
render_mode unshaded;
//render_mode cull_disabled;
render_mode depth_draw_always;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear;
varying mat4 CAMERA;

void vertex() {
	CAMERA = INV_VIEW_MATRIX;
}

uniform float near = 0.15;
uniform float far = 300.0;

float linearize(float c_depth) {
	c_depth = 2.0 * c_depth - 1.0;
	return near * far / (far + c_depth * (near - far));
}

void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	float linear_depth = linearize(depth);
	
	float zpos = linearize(FRAGCOORD.z);
	float depth_diff = linear_depth - zpos;
	
	vec3 color = mix(vec3(0.0), vec3(1.0), step(0.5, depth_diff));
	color = clamp(color, vec3(0.0), vec3(1.0));
	//ALBEDO = color;
	ALPHA = 1.0 - color.x;
}

