tool
extends Spatial 
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")
#var DebugDraw = preload("res://addons/sofa_scene_creator/debug_draw.gd").new() 

export(Array, NodePath) var targets

export(float) var distance_min = 0
export(float) var distance_max = 1
export(float) var visualisation_size = 50
export(bool) var visualisation_lines = true

var visual_mesh : Mesh = CubeMesh.new()
var material_red = SpatialMaterial.new()

func _enter_tree():
	visual_mesh.size = Vector3(1,1,1)
	material_red.flags_transparent = true
	material_red.albedo_color = Color(1.0,0,0,0.2)
	var preview_visual_mesh = MeshInstance.new()
	visual_mesh.material = material_red
	preview_visual_mesh.mesh = visual_mesh
	add_child(preview_visual_mesh)

func get_xml_tree():
	var m3 = get_basis()
	
	for t in targets:
		if t == "": continue
		if(!SofaUtility.is_valid_sofa_softbody_object(get_node(t))):
			assert(false, "Error: objects in a box constraint must be Soft Bodies (PLUGIN limitation)") # because SOFA doesn't like Rigidbodies
		
		var tree = XMLSceneTree.new("FixedPlaneConstraint")
		tree.get_root().add_properties({"name":get_name(),"direction":m3.y,"dmin":distance_min,"dmax":distance_max})
		SofaUtility.add_requirement(get_node(t), tree)
	# No return here, the requirments are post-attached/add_requirement to the target nodes
	return null

func get_basis() -> Basis:
	var m3 = Basis()
	
	m3 = m3.rotated( Vector3(0,0,1), rotation.z )
	m3 = m3.rotated( Vector3(1,0,0), rotation.x )
	m3 = m3.rotated( Vector3(0,1,0), rotation.y )
	return m3

func _process(delta):
	for t in targets:
		if t == "": continue
		SofaUtility.draw_line(self, translation, get_node(t).translation, SofaUtility.COLOR_TARGET_OBJECT)

	var m3 = get_basis()
	
	if distance_min >= distance_max:
		distance_max = distance_min + 1

	var thickness = distance_max - distance_min
	if(visualisation_lines):
		SofaUtility.draw_line(self, translation + (m3.y * thickness/2), translation + m3.y * 10000, SofaUtility.COLOR_WHITE)
		SofaUtility.draw_line(self, translation - (m3.x * 10000) + (m3.y * thickness), translation + (m3.x * 10000), SofaUtility.COLOR_PURPLE)
		SofaUtility.draw_line(self, translation - (m3.x * 10000) - (m3.y * thickness), translation + (m3.x * 10000), SofaUtility.COLOR_PURPLE)
		SofaUtility.draw_line(self, translation - (m3.z * 10000) + (m3.y * thickness), translation + (m3.z * 10000), SofaUtility.COLOR_PURPLE)
		SofaUtility.draw_line(self, translation - (m3.z * 10000) - (m3.y * thickness), translation + (m3.z * 10000), SofaUtility.COLOR_PURPLE)
	
	scale = Vector3(visualisation_size,thickness,visualisation_size)
	translation = Vector3(0,0,0) + m3.y * (distance_min + (thickness / 2))
