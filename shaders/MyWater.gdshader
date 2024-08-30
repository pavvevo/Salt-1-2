shader_type spatial;

uniform vec3 albedo : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 fresnelColor : source_color = vec3(1.0, 1.0, 1.0);

uniform vec3 deepColor : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 shallowColor : source_color = vec3(1.0, 1.0, 1.0);
uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;

uniform float speed : hint_range(0.0, .5, 0.05);
uniform vec2 waveDirecton = vec2(1.5, 0.5);
uniform vec2 waveDirectionTwo = vec2(-0.5, 1.0);
uniform float waveHeight = 1.0;
uniform float waveScale = 1.;
uniform float waveNormalScale = .4;

uniform sampler2D normalTex;
uniform sampler2D waveTex;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float edge_scale = .5;
const float near = 1.0;
const float far = 100.0;
uniform vec3 edge_color : source_color = vec3(1.0, 1.0, 1.0);

varying vec3 world_pos;
varying float height;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

float edge(float depth){
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	//world_pos = VERTEX;
	height = texture(waveTex, world_pos.xz * waveScale + TIME * speed * .1).r;
	VERTEX.y += height * waveHeight;
}

void fragment() {
	float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
	float depth_blend = exp((depth+VERTEX.z) * -beers_law);
	depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);	
	float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);
	
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;
	
	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power * 2.5).rgb;
	vec3 depth_color = mix(shallowColor, deepColor, depth_blend_power);
	depth_color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);
	
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 water_color = mix(albedo, fresnelColor, fresnel);
	
	vec2 wave1 = (TIME * waveDirecton) * speed;
	vec2 wave2 = (TIME * waveDirectionTwo) * speed;
	vec3 normal = mix(texture(normalTex,world_pos.xz * waveNormalScale + wave1).rgb, texture(normalTex,world_pos.xz * waveNormalScale + wave2).rgb, 0.5);
	
	vec3 final_color = water_color * depth_color;
	final_color = mix(edge_color, final_color, step(edge_scale, z_dif));
	final_color = clamp(final_color, vec3(0.0), vec3(1.0));
	
	ALBEDO = final_color;
	RIM = 0.2;
	ROUGHNESS = sqrt(1.0 - dot(NORMAL, VIEW));
	METALLIC = 0.;
	NORMAL_MAP = normal;
}