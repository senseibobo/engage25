shader_type spatial;
render_mode unshaded;


instance uniform float body_alpha: hint_range(0.0, 1.0) = 1.0;


void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    ALBEDO = vec3(0.9,0.3,0.05);
	ALPHA = body_alpha;
}

//void light() {
    // Called for every pixel for every light affecting the material.
    // Uncomment to replace the default light processing function with this one.
//}
