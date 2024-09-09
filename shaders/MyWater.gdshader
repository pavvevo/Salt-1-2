shader_type spatial;
//render_mode cull_disabled;
//render_mode depth_prepass_alpha;

global uniform vec3 ocean_pos; // Global shader value for the player position

uniform vec3 albedo : source_color = vec3(0.0,0.32,0.43);
uniform vec3 albedo2 : source_color = vec3(0.0,0.47,0.76);
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform sampler2D wave; // Noise wave texture
uniform sampler2D wave_bump; // Normal bump map version of the noise wave texture
uniform sampler2D texture_normal; // Additional normal noise
uniform sampler2D texture_normal2; // Additional normal noise
uniform vec2 wave_direction = vec2(0.5,-0.2); // Direction of wave 1
uniform vec2 wave_direction2 = vec2(-0.5,0.5); // Direction of wave 2
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.1;
uniform float noise_scale = 20.0;
uniform float height_scale = 2.0;
uniform float time = 0.0;

// Depth color
uniform vec3 color_deep : source_color = vec3(0.11,0.29,0.33); // Deep depth color
uniform vec3 color_shallow : source_color = vec3(0.0,0.47,0.76); // Shallow depth color
uniform float beers_law = 2.0; // Beer's law application
uniform float depth_offset = 1.5; // Offset

// Varying variables
varying float height;
varying vec3 world_pos;
varying float vertex_distance;
varying float vertex_distance_clamped;
varying vec2 vertex_pos;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

uniform float near = 0.15;
uniform float far = 300.0;
uniform float edge_scale = 0.3;
uniform vec3 edge_color : source_color = vec3(1.0,1.0,1.0);

float linearize(float c_depth) {
	c_depth = 2.0 * c_depth - 1.0;
	return near * far / (far + c_depth * (near - far));
}

float waveheight() {
	float h1 = texture(wave, world_pos.xz / noise_scale + (time * wave_direction) * time_scale).r;
	float h2 = texture(wave, world_pos.xz / noise_scale + (time * wave_direction2) * time_scale).r;
	return mix(h1, h2, 0.5);
}

void vertex() {
	world_pos = floor(NODE_POSITION_WORLD) + VERTEX;
	
	vertex_distance = distance(world_pos,NODE_POSITION_WORLD);
	vertex_distance = clamp(vertex_distance, 0.0, 100.0);
	vertex_distance_clamped = vertex_distance / 100.0;
	float height_mix = waveheight();
	
	VERTEX.y += height_mix * height_scale * (1.0 - vertex_distance_clamped);
	
	VERTEX.y *= 1.0 - step(0.49, abs(NODE_POSITION_WORLD.x - world_pos.x) / 100.0);
	VERTEX.y *= 1.0 - step(0.49, abs(NODE_POSITION_WORLD.z - world_pos.z) / 100.0);
	
	VERTEX.x -= NODE_POSITION_WORLD.x - floor(NODE_POSITION_WORLD.x);
	VERTEX.z -= NODE_POSITION_WORLD.z - floor(NODE_POSITION_WORLD.z);
}

void fragment() {
	vec2 w_time = (time * wave_direction) * time_scale;
	vec2 w_time2 = (time * wave_direction2) * time_scale;
	
	vec3 wave_normal_1 = texture(texture_normal,world_pos.xz / 10.0 + w_time / 10.0).rgb;
	vec3 wave_normal_2 = texture(texture_normal2,world_pos.xz / 10.0 + w_time2 / 10.0).rgb;
	vec3 normal_blend = mix(wave_normal_1, wave_normal_2, 0.5);
	
	vec3 wave_bump_1 = texture(wave_bump, world_pos.xz / noise_scale + w_time).xyz;
	vec3 wave_bump_2 = texture(wave_bump, world_pos.xz / noise_scale + w_time2).xyz;
	vec3 wave_normal_blend = mix(wave_bump_1,wave_bump_2,0.3);
	
	vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	screen_color = mix(screen_color, vec3(1.0), 0.75);

	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, albedo2, fresnel);
	
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	float linear_depth = linearize(depth);
	
	float zpos = linearize(FRAGCOORD.z);
	float depth_diff = linear_depth - zpos;
	vec3 final_color = mix(edge_color, surface_color * screen_color, step(edge_scale, depth_diff));
	
	ALBEDO = clamp(final_color,vec3(0.0),vec3(1.0));
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = mix(wave_normal_blend, normal_blend, 0.5);
	SPECULAR = wave_normal_blend.r;
}