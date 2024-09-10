shader_type spatial;

uniform sampler2D noiseTex : source_color;
uniform sampler2D floorTex : source_color, filter_nearest;
uniform sampler2D sandTex : source_color, filter_nearest;
uniform sampler2D grassTex : source_color, filter_nearest;
uniform float noise_scale = 1.0;

void fragment() {
	
	float height = texture(noiseTex, UV).r;
	
	vec3 sea_floor = texture(floorTex, UV * 500.0 * noise_scale).rgb;
	vec3 sand = texture(sandTex, UV * 500.0 * noise_scale).rgb;
	vec3 grass = texture(grassTex, UV * 500.0 * noise_scale).rgb;
	
	vec3 final_color = sea_floor;
	final_color = mix(final_color, sand, smoothstep(0.35, 0.4, height));
	final_color = mix(final_color, grass, smoothstep(0.5, 0.8, height));
	
	ALBEDO = final_color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
