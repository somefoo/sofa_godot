tool
extends Camera

const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")

var visual_mesh : Mesh = CubeMesh.new()
var material = SpatialMaterial.new()
export(float) var field_of_view = 0



func _get_property_list():
	var property_list = []
	return property_list

func _enter_tree():
	# This creates a red box, which is slightly transparent
	material.flags_transparent = true
	material.albedo_color = Color(1.0,0,0,0.2)
	var preview_visual_mesh = MeshInstance.new()
	visual_mesh.material = material
	preview_visual_mesh.mesh = visual_mesh
	add_child(preview_visual_mesh)

func get_xml_tree():
	var xml_tree_camera = XMLSceneTree.new("OglViewport")
	var camera_root = xml_tree_camera.get_root()
	camera_root.add_properties({"name":get_name(), "screenPosition":"0 0", "screenSize":"250 250",
	"cameraPosition":translation, "cameraOrientation":Quat(rotation),
	"zFar":far, "zNear":near, "fovy":fov})
	return xml_tree_camera

func _process(delta):
	pass
	#rotation= Vector3(0,0,0)
