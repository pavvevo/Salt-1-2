shader_type spatial;
render_mode cull_disabled;
//render_mode world_vertex_coords;

uniform sampler2D normalmap;
uniform sampler2D noiseTex;
varying vec3 world_pos;

uniform float speed = 0.0;

void vertex() {
	world_pos = NODE_POSITION_WORLD + VERTEX;
	//VERTEX.y += texture(noiseTex, world_pos.xz + TIME / 10.0).r;
}

void fragment() {
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	
	vec3 wave1 = texture(normalmap, world_pos.xz / 10.0 + TIME * speed).xyz;
	vec3 wave2 = texture(normalmap, world_pos.xz / 10.0 + TIME * speed * vec2(2, 0.5)).xyz;
	
	NORMAL_MAP = mix(wave1, wave2, 0.5);
	
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.01, 0.03, 0.05) +  + (0.1 * fresnel);
	//ALBEDO = clamp(world_pos, vec3(0.0), vec3(1.0));
	
}