tool
extends Spatial 
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")

export var ROI : NodePath
export(Array, NodePath) var targets

func _enter_tree():
	pass



func is_valid_sofa_ROI(obj):
	var is_sofa_object = true
	if(obj.get_script() == null):
		is_sofa_object = false
	elif (obj.get_script().get_path().split('/')[-1].find("ROI") == -1):
		is_sofa_object = false
	elif(obj.has_method("is_visible") && obj.is_visible() == false):
		is_sofa_object = false
	return is_sofa_object


func is_valid_sofa_object(obj):
	var is_sofa_object = true
	if(obj.get_script() == null):
		is_sofa_object = false
	elif (obj.get_script().get_path().split('/')[-1].find("sofa_object") != 0):
		is_sofa_object = false
	elif(obj.has_method("is_visible") && obj.is_visible() == false):
		is_sofa_object = false
	elif(obj.soft_body == false):
		is_sofa_object = false
	return is_sofa_object


func get_xml_tree():
	#TODO remove hard coded "dofs" name?
	
	var xml_treee = XMLSceneTree.new()
	var rr = xml_treee.get_root()
	rr.add_property("name", self.name)
	
	for t in targets:
		get_tree().root.get_child(0).add_requirement_to_node(get_node(t),xml_treee)
	
	return null
	pass
	if !is_valid_sofa_ROI(get_node(ROI)):
		print("Error, the ROI select is not a valid ROI.")
		print("  This error did not cause a pre-mature closing as GODOT seems to have a bug.")
		get_tree().quit()
	
	for t in targets:
		var o2 = SofaUtility.get_sofa_absolute_name(get_node(t))
		if(!is_valid_sofa_object(get_node(t))):
			print("Error, objects constrained are not Sofa Objects.")
			print("  This error did not cause a pre-mature closing as GODOT seems to have a bug.")
			get_tree().quit()
			#TODO Exit here, but that isn't working somehow...
			return null
		
	
	#TODO:
	# BOXRoi does not have a target, it has to be a child... stupid SOFA!
	
	var xml_tree = XMLSceneTree.new()
	var r = xml_tree.get_root()
	r.add_property("name", self.name)
	
	#var o1 = get_tree().root.get_child(0).get_sofa_absolute_name(get_node(ROI))
	#for t in targets:
	#	var o2 = get_tree().root.get_child(0).get_sofa_absolute_name(get_node(t))
	#	r.add_child("BoxROI").add_properties({
	#		"target":
	#	})
	
	#r.add_property("name", self.name)
	return xml_tree

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
