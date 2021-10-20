tool
extends Camera

const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")

export(int, 0, 16384) var frame_width = 320 setget set_width
export(int, 0, 16384) var frame_height = 320 setget set_height
export(int, 0, 16384) var frame_x_center = 0
export(int, 0, 16384) var frame_y_center = 0

func set_width(value):
	frame_width = value
	ProjectSettings.set_setting("display/window/size/width", value)
func set_height(value):
	frame_height = value
	ProjectSettings.set_setting("display/window/size/height", value)
	



func _set(property, value):
	var not_supported = ["h_offset", "v_offset", "environment", "cull_mask", "current", "doppler_tracking", "projection", "keep_aspect"]
	if(property in not_supported):
		push_warning("This value does not have a SOFA equivalent: Ignored.")
		return true


func get_xml_tree():
	var xml_tree_camera = XMLSceneTree.new("OglViewport")
	var camera_root = xml_tree_camera.get_root()
	camera_root.add_properties({"name":get_name(), "screenPosition":[frame_x_center, frame_y_center], "screenSize":[frame_width, frame_height],
	"cameraPosition":translation, "cameraOrientation":Quat(rotation),
	"zFar":far, "zNear":near, "fovy":fov})
	return xml_tree_camera

func _process(delta):
	var setting_width = ProjectSettings.get_setting("display/window/size/width")
	var setting_height = ProjectSettings.get_setting("display/window/size/height")
	
	frame_width = setting_width
	frame_height = setting_height
