shader_type spatial;
render_mode cull_front, unshaded;

uniform float thickness = 0.002;

void vertex() {
	VERTEX += NORMAL*thickness;
}

void fragment() {
	ALBEDO = vec3(1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
