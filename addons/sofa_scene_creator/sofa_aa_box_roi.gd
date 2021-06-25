tool
extends Spatial

const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")

var visual_mesh : Mesh = CubeMesh.new()
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
	var xml_tree_box_roi = XMLSceneTree.new("BoxROI")
	var roi_root = xml_tree_box_roi.get_root()
	
	var s = scale
	var p = translation
	var box = [s.x + p.x, s.y + p.y, s.z + p.z, -s.x + p.x, -s.y + p.y, -s.z + p.z]
	roi_root.add_properties({"name": get_name(), "box":box, "drawBoxes":1})
	return xml_tree_box_roi

func _process(delta):
	#print("lol")
	#set_transform(Transform(Vector3(0,0,0), Vector3(0,0,0)))
	#set_transform(Transform(Quat(0,0,0,0)))
	#if(get_parent() != null):
	#	if("rotation_degrees" in get_parent()):
	#		rotation = Vector3(0,0,0) - get_parent().rotation
	#		transform.origin += get_parent().origin
	#		transform.basis = get_parent().transform.inverse()
	#	else:
	#		rotation = Vector3(0,0,0)
	#else:
	#	rotation= Vector3(0,0,0)
		
	rotation= Vector3(0,0,0)
	#global_transform.origin = Vector3(1,1,1)
	pass
