tool
extends Spatial 
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")

export(Array, NodePath) var targets

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
	var s = scale
	var p = translation
	var box = [s.x + p.x, s.y + p.y, s.z + p.z, -s.x + p.x, -s.y + p.y, -s.z + p.z]
	
	for t in targets:
		if t == "": continue
		if(!SofaUtility.is_valid_sofa_softbody_object(get_node(t))):
			assert(false, "Error: objects in a box constraint must be Soft Bodies (PLUGIN limitation)") # because SOFA doesn't like Rigidbodies
		
		var tree = XMLSceneTree.new("BoxConstraint")
		tree.get_root().add_properties({"name":get_name(),"box":box})
		SofaUtility.add_requirement(get_node(t), tree)
	# No return here, the requirments are post-attached/add_requirement to the target nodes
	return null

func _process(delta):
	rotation = Vector3(0,0,0)
