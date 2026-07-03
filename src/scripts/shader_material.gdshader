shader_type spatial;

render_mode unshaded;

uniform vec4 fog_color : source_color = vec4(0.0,0.0,0.0,1.0);
uniform sampler2D visibility_texture;
uniform float map_size = 130.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

// Called for every pixel the material is visible on.
void fragment() {
    ALBEDO = fog_color.rgb;
    ALPHA = fog_color.a;
	
	vec2 uv;

	uv.x = NODE_POSITION_WORLD.x / map_size + 0.5;
	uv.y = NODE_POSITION_WORLD.z / map_size + 0.5;
	
	float visibility = texture(visibility_texture, uv).r;
	
	ALPHA = 1.0 - visibility;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
