shader_type spatial;

render_mode unshaded, blend_mix, cull_disabled;

uniform sampler2D visibility_texture : filter_nearest, repeat_disable;
uniform sampler2D explored_texture  : filter_nearest, repeat_disable;

uniform vec2 world_min;
uniform vec2 world_max;

uniform float edge_size = 0.08;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv;

	uv.x = (world_pos.x - world_min.x) / (world_max.x - world_min.x);
	uv.y = (world_pos.z - world_min.y) / (world_max.y - world_min.y);

	uv = clamp(uv, vec2(0.0), vec2(1.0));

	float visible = texture(visibility_texture, uv).r;
	float explored = texture(explored_texture, uv).r;

	// 0 = completamente visible
	// 1 = completamente oculto
	float fog = 1.0 - smoothstep(0.5 - edge_size, 0.5 + edge_size, visible);

	float alpha;

	if (explored > 0.5) {
		alpha = mix(0.45, 0.0, 1.0 - fog);
	}
	else {
		alpha = mix(0.90, 0.0, 1.0 - fog);
	}

	ALBEDO = vec3(0.0);
	ALPHA = alpha;
}