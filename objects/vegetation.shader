// My custom shader for implementing dithered alpha
shader_type spatial;
render_mode blend_mix,depth_draw_alpha_prepass,cull_disabled,diffuse_burley,specular_schlick_ggx;

// Texture maps
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D texture_masks : hint_white;
uniform sampler2D texture_normal : hint_normal;
//uniform sampler2D noise;

// Parameters
uniform vec4 modulate : hint_color = vec4(1.0);
uniform float specular = 0.5;
uniform float metallic = 0.0;
uniform float roughness : hint_range(0,1) = 0.5;
uniform float normal_strength : hint_range(0,2) = 1.0;
uniform vec3 uv1_scale = vec3(1.0);
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform float wind_strength = 1.0;
uniform vec3 wind_amplitude = vec3(0.1);
varying vec4 world_pos;
//varying float instance;

void vertex(){
	UV=UV*uv1_scale.xy+uv1_offset.xy;
//	instance = float(INSTANCE_ID);
//	vec4 world_pos = vec4(VERTEX, 1.0) * WORLD_MATRIX;

	world_pos = vec4(VERTEX, 1.0) * WORLD_MATRIX;
	VERTEX.x = VERTEX.x + sin(TIME * wind_strength * sin(world_pos.x)) * wind_amplitude.x * (1.0 - UV.y);
	VERTEX.y = VERTEX.y + cos(TIME * wind_strength * sin(world_pos.y)) * wind_amplitude.y * (1.0 - UV.y);
	VERTEX.z = VERTEX.z + cos(TIME * wind_strength * sin(world_pos.z)) * wind_amplitude.z * (1.0 - UV.y);
}

void fragment() {
    vec4 albedo_tex = texture(texture_albedo, UV);
    vec4 masks_tex = texture(texture_masks, UV);
//    float alpha = albedo_tex.a;

    ALBEDO = modulate.rgb * albedo_tex.rgb;
	ALPHA = albedo_tex.a;
    METALLIC = metallic * masks_tex.r;
    ROUGHNESS = roughness * masks_tex.g;
    NORMALMAP = texture(texture_normal, UV).rgb;
    NORMALMAP_DEPTH = normal_strength;
	TRANSMISSION = vec3(0.8, 0.8, 0.8);

    // Fancy dithered alpha stuff
//    float opacity = albedo_tex.a * modulate.a + 0.055;
//    int x = int(FRAGCOORD.x) % 4;
//    int y = int(FRAGCOORD.y) % 4;
//    int index = x + y * 4;
//    float limit = 0.0;
//
//    if (x < 8) {
//        if (index == 0) limit = 0.0625;
//        if (index == 1) limit = 0.5625;
//        if (index == 2) limit = 0.1875;
//        if (index == 3) limit = 0.6875;
//        if (index == 4) limit = 0.8125;
//        if (index == 5) limit = 0.3125;
//        if (index == 6) limit = 0.9375;
//        if (index == 7) limit = 0.4375;
//        if (index == 8) limit = 0.25;
//        if (index == 9) limit = 0.75;
//        if (index == 10) limit = 0.125;
//        if (index == 11) limit = 0.625;
//        if (index == 12) limit = 1.0;
//        if (index == 13) limit = 0.5;
//        if (index == 14) limit = 0.875;
//        if (index == 15) limit = 0.375;
//    }
//    if (x < 8) {
//        if (index == 0) limit = texture(noise, vec2(0.1, 0.8)).r;
//        if (index == 1) limit = texture(noise, vec2(0.01, 0.28)).r;
//        if (index == 2) limit = texture(noise, vec2(0.713, 0.6)).r;
//        if (index == 3) limit = texture(noise, vec2(0.123, 0.158)).r;
//        if (index == 4) limit = texture(noise, vec2(1.0, 0.879)).r;
//        if (index == 5) limit = texture(noise, vec2(0.719, 0.6327)).r;
//        if (index == 6) limit = texture(noise, vec2(0.112, 0.87)).r;
//        if (index == 7) limit = texture(noise, vec2(0.279, 0.345)).r;
//        if (index == 8) limit = texture(noise, vec2(0.679, 0.654)).r;
//        if (index == 9) limit = texture(noise, vec2(0.444, 0.554)).r;
//        if (index == 10) limit = texture(noise, vec2(0.547, 0.124)).r;
//        if (index == 11) limit = texture(noise, vec2(0.135, 0.234)).r;
//        if (index == 12) limit = texture(noise, vec2(0.556, 0.879)).r;
//        if (index == 13) limit = texture(noise, vec2(0.657, 0.998)).r;
//        if (index == 14) limit = texture(noise, vec2(0.779, 0.0)).r;
//        if (index == 15) limit = texture(noise, vec2(0.986, 0.147)).r;
//    }
    // Is this pixel below the opacity limit? Skip drawing it
//    if (opacity < limit)
//        discard;
}