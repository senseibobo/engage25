shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

// Varyings
varying vec3 WorldPos;

uniform sampler2D colorGradient1;
uniform sampler2D colorGradent2;
uniform sampler2D noise_texture;

void vertex() {
	
}

void fragment() {
	//ALBEDO = base_color;
	//ALPHA = transparency.x;
	//SPECULAR = specular.x;
}
