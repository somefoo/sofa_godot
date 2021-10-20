tool
extends OmniLight

const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")


	
func _enter_tree():
	omni_range = 4096


func _set(property, value):
	var not_supported = ["omni_range", "omni_shadow_mode", "omni_shadow_detail", "light_energy", "light_indirect_energy", "light_negative", "light_specular", "light_bake_mode", "light_cull_mask", "shadow_enabled", "shadow_color", "shadow_bias", "shadow_contact", "shadow_reverse_cull_face", "editor_only"]
	if(property in not_supported):
		push_warning("This value does not have a SOFA equivalent: Ignored.")
		return true


func get_xml_tree():
	#<PositionalLight name="light1" color="1 0 0" attenuation="0.4" position="0.5 0.7 2" />
	var xml_light = XMLSceneTree.new("PositionalLight")
	var light_root = xml_light.get_root()
	var scaled_attenuation_inv = 10000.0/omni_attenuation
	var scaled_attenuation = 1.0/scaled_attenuation_inv
	light_root.add_properties({"name":get_name(), "position":translation, "attenuation":scaled_attenuation, "color":light_color})
	return xml_light

func _process(delta):
	#VisualServer.background_color = Color(0,0,0,0)
	#VisualServer.set_default_clear_color(Color(1,1,0,1))
	pass
