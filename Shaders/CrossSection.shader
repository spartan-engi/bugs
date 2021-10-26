shader_type spatial;

render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic : hint_range(0,1);
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform vec3 portal_pos = vec3(0,0,0);
uniform float slice_anim = 0.0;
uniform float slice_side = 0.0;
uniform vec3 slice_normal = vec3(0,0,0);

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	}



void fragment() {
	
//	vec3 portal_to_vertex = VERTEX.xyz - (slice_pos+portal_pos);
	vec3 portal_to_vertex = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz - portal_pos
	- (slice_anim*slice_normal); //ignore this is a animation thing
	float doting = dot(slice_normal*slice_side, portal_to_vertex);
	
	if (
		doting < 0.
	)
	{discard;}
	
	
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO.rgb = albedo.rgb * albedo_tex.rgb;
//	ALBEDO.rgb = vec3(albedo.r * albedo_tex.r, doting, albedo.b * albedo_tex.b);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
}
