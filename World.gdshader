shader_type spatial;
render_mode cull_disabled;

uniform sampler2D noiseTex;

void vertex() {
}

void fragment() {
	float noise = texture(noiseTex, UV).r;
	ALBEDO = vec3(noise);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
