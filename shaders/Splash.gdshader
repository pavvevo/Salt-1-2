shader_type spatial;
render_mode cull_disabled;

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

varying float time;

void vertex() {
	time = INSTANCE_CUSTOM.y;
}

void fragment() {
	vec2 center_uv = UV * 2.0 - 1.0;
	float circle = sdCircle(center_uv, fract(time));
	circle = abs(circle) - (1.0 - fract(time)) * 0.1;
	circle = smoothstep(0.0, 0.01, circle);
	circle = 1.0 - circle;
	circle = clamp(circle, 0.0, 1.0);
	ALBEDO = vec3(circle);
	ALPHA = circle;
}

