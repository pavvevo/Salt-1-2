shader_type spatial;
render_mode cull_disabled;

uniform float bounce : hint_range(0.0, 1.0, 0.1);

void vertex() {
	vec2 center_uv = UV * 2.0 - 1.0;
	float offset = abs(center_uv.x) * abs(center_uv.x);
	offset += sin(TIME * 10.0 + VERTEX.x * 10.0) / 10.0 * offset;
	VERTEX.z -= offset;
	VERTEX.z *= bounce;
	VERTEX.x *= bounce;
	VERTEX.y += sin(TIME * 10.0 + VERTEX.x * 2.0) / 10.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
}