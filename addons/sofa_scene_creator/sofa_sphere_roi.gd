tool
extends Spatial

const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")

var visual_mesh : Mesh = SphereMesh.new()
var material = SpatialMaterial.new()

func _enter_tree():
	material.flags_transparent = true
	material.albedo_color = Color(1.0,0,0,0.2)
	var preview_visual_mesh = MeshInstance.new()
	visual_mesh.material = material
	preview_visual_mesh.mesh = visual_mesh
	add_child(preview_visual_mesh)

func get_xml_tree():
	return null #Ignore me!

# This is not called by the root, but can be used by custom calls of other nodes
func get_xml_tree_custom():
	var xml_tree_sphere_roi = XMLSceneTree.new("SphereROI")
	var roi_root = xml_tree_sphere_roi.get_root()
	
	roi_root.add_properties({"name": get_name(), "centers":translation,"radii":scale.x, "drawSphere":1})
	return xml_tree_sphere_roi

func _process(delta):
	rotation= Vector3(0,0,0)
	var scale_max = max(scale.x, max(scale.y, scale.z))
	scale=Vector3(scale_max,scale_max,scale_max)
	pass
