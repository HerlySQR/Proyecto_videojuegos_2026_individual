shader_type spatial;

render_mode unshaded, blend_mix, cull_disabled;
uniform sampler2D visibility_texture;

void fragment() {
	vec2 uv = UV;
	float visibility = texture(visibility_texture, uv).r;
	ALBEDO = vec3(0.0);
	ALPHA = smoothstep(1.0, 0.2, visibility) * 0.85;
}