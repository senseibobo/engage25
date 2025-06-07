shader_type spatial;
render_mode unshaded;

void vertex() {
    // Called for every vertex the material is visible on.
}

float fresnel(float amount, vec3 normal, vec3 view)
{
    return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
    ALBEDO = vec3(0.9,0.3,0.05);
    ALPHA_SCISSOR_THRESHOLD =0.01;
    ALPHA = fresnel(3.0, NORMAL, VIEW);
}
