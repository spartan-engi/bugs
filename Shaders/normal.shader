shader_type spatial;

//render_mode blend_mix,depth_draw_opaque,diffuse_burley,specular_schlick_ggx;

uniform vec4 albedo : hint_color;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float specular;



void fragment() {
	
	ALBEDO.rgb = albedo.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	
}