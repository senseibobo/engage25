shader_type canvas_item;


uniform float alpha = 0.0;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = vec4(0.99,0.01,0.01, alpha*(1.0-step(texture(TEXTURE, UV).a,0.1)));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
