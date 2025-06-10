shader_type spatial;
render_mode unshaded;

uniform sampler2D tex;
uniform vec4 color: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 newUV = vec2(UV.x*1.0+TIME,UV.y);
	    //ALBEDO.x = UV.x;//vec3(0.51,0.5,0.01);
	vec4 cola = texture(tex,newUV).rgba;
    ALBEDO = cola.rgb;
	ALBEDO *= color.rgb;
	//ALBEDO.xyz *= mod(UV.x+TIME*1.5,1.8)/(3.6/2.0);
	//ALPHA_SCISSOR_THRESHOLD =0.01;
    ALPHA = cola.a * color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
