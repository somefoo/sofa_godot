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
		
		get_tree().root.get_child(0).add_requirement_to_node(get_node(t), roi.get_xml_tree_custom())
		get_tree().root.get_child(0).add_requirement_to_node(get_node(t), xml_tree_constraint)
	
	return null
#	pass
#	if !is_valid_sofa_ROI(get_node(region_of_interst)):
#		print("Error, the ROI select is not a valid ROI.")
#		print("  This error did not cause a pre-mature closing as GODOT seems to have a bug.")
#		get_tree().quit()
#
#	for t in targets:
#		var o2 = SofaUtility.get_sofa_absolute_name(get_node(t))
#		if(!is_valid_sofa_object(get_node(t))):
#			print("Error, objects constrained are not Sofa Objects.")
#			print("  This error did not cause a pre-mature closing as GODOT seems to have a bug.")
#			get_tree().quit()
#			#TODO Exit here, but that isn't working somehow...
#			return null
#
#
#	#TODO:
#	# BOXRoi does not have a target, it has to be a child... stupid SOFA!
#
#	var xml_tree = XMLSceneTree.new()
#	var r = xml_tree.get_root()
#	r.add_property("name", self.name)
#
#	#var o1 = get_tree().root.get_child(0).get_sofa_absolute_name(get_node(ROI))
#	#for t in targets:
#	#	var o2 = get_tree().root.get_child(0).get_sofa_absolute_name(get_node(t))
#	#	r.add_child("BoxROI").add_properties({
#	#		"target":
#	#	})
#
#	#r.add_property("name", self.name)
#	return xml_tree

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
