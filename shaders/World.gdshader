shader_type spatial;

uniform sampler2D gradientTex;

varying float height;

void vertex() {
	height = VERTEX.y;
}

void fragment() {
	
	vec3 color = texture(gradientTex, vec2(height/10.0)).rgb;
	
	ALBEDO = color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
