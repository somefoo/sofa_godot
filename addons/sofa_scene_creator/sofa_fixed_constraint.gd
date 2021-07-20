tool
extends Spatial 
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")

export var region_of_interest : NodePath
export(Array, NodePath) var targets

func _enter_tree():
	pass

func get_xml_tree():
	#TODO remove hard coded "dofs" name?
	#TODO impl this correctly now and remove the is_valid stuff above
	
	var roi = get_node(region_of_interest)
	assert(SofaUtility.is_valid_sofa_ROI(roi, true), "Error, the ROI select is not a valid ROI.")

	
	for t in targets:
		var xml_tree_constraint = XMLSceneTree.new("FixedConstraint")
		var roi_root = xml_tree_constraint.get_root()
		roi_root.add_properties({"name":get_name(), "indices":SofaUtility.get_sofa_absolute_name(get_node(t)) + "/" + roi.get_name() + ".indices"})
		if(!SofaUtility.is_valid_sofa_softbody_object(get_node(t))):
			assert(false, "Error: objects in an fixed constraint must be Rigid Body (PLUGIN limitation)") # because SOFA doesn't like Rigidbodies
			
		get_tree().root.get_child(0).add_requirement_to_node(get_node(t), roi.get_xml_tree_custom())
		get_tree().root.get_child(0).add_requirement_to_node(get_node(t), xml_tree_constraint)
	
	
	# No return here, the requirments are post-attached to the target nodes
	return null

func _process(delta):
	scale = Vector3(0,0,0)
	translation = Vector3(0,0,0)
	rotation = Vector3(0,0,0)
	pass
