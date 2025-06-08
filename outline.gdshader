shader_type spatial;
render_mode cull_front, unshaded;

void vertex() {
	VERTEX += NORMAL*0.002;
}

void fragment() {
	ALBEDO = vec3(1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
