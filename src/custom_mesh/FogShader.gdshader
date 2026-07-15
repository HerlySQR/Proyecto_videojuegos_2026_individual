shader_type spatial;

render_mode unshaded, blend_mix, cull_disabled;
uniform sampler2D visibility_texture;
uniform sampler2D explored_texture;

void fragment() {
	float visible = texture(visibility_texture, UV).r;
	float explored = texture(explored_texture, UV).r;

	ALBEDO = vec3(0.0);

	if (visible > 0.5) {
		ALPHA = 0.0;
	}
	else if (explored > 0.5) {
		ALPHA = 0.45;
	}
	else {
		ALPHA = 0.90;
	}
}