shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 deep_color : source_color = vec4(0.025, 0.53, 0.62, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.22, 0.84, 0.81, 1.0);

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y += sin(world_pos.z * 1.4 + TIME * 2.0) * 0.025 + sin(world_pos.x * 2.2 + TIME * 1.7) * 0.018;
}

void fragment() {
	float t = TIME * 0.55;
	vec2 p = world_pos.xz;
	float edge = pow(abs(UV.x * 2.0 - 1.0), 5.0);
	float broad = sin(p.x * 0.65 + p.y * 0.18 + t) * 0.12;
	float wave = sin(p.y * 2.7 + sin(p.x * 1.7 + t) * 1.4 - t * 3.0);
	float crosswave = sin(p.x * 3.1 + sin(p.y * 0.55 - t) * 1.6 + t);
	float caustic = pow(max(0.0, 1.0 - abs(wave + crosswave) * 0.65), 12.0) * 0.09;
	float crest = smoothstep(0.94, 1.0, wave) * smoothstep(0.25, 0.9, crosswave) * 0.12;
	float shore = smoothstep(0.93, 0.995, abs(UV.x * 2.0 - 1.0) + sin(p.y * 2.4 - t * 2.0) * 0.012);
	float shade = clamp(0.30 + edge * 0.50 + broad, 0.0, 1.0);
	vec3 color = mix(deep_color.rgb, shallow_color.rgb, shade);
	color += vec3(0.72, 0.94, 0.86) * (caustic + crest);
	ALBEDO = mix(color, vec3(0.78, 0.96, 0.87), shore * 0.72);
}
