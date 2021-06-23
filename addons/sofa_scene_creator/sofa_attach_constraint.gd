tool
extends Spatial 
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")

export var object_1 : NodePath
export var object_2 : NodePath
export var attach_distance : float = 0.001

func _enter_tree():
	pass



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
	var o1 = get_tree().root.get_child(0).get_sofa_absolute_name(get_node(object_1))
	var o2 = get_tree().root.get_child(0).get_sofa_absolute_name(get_node(object_2))
	if(!is_valid_sofa_object(get_node(object_1)) || !is_valid_sofa_object(get_node(object_2))):
		print("Error, objects constrained are not Sofa Objects.")
		print("  Both objects must be Soft Bodies because SOFA doesn't like Rigidbodies.")
		print("  This error did not cause a pre-mature closing as GODOT seems to have a bug.")
		get_tree().quit()
		#TODO Exit here, but that isn't working somehow...
		return null
		

	
	var o1d = o1 + "/dofs"
	var o2d = o2 + "/dofs"
	#var xml_tree = XMLSceneTree.new("AttachConstraint")
	#var r = xml_tree.get_root()
	#r.add_properties({})

	#root_node.addObject("NearestPointROI", template="Vec3d", name="np1", object1="@Scene/Gallbladder/dofs", object2="@Scene/ConnectiveTissue/dofs", radius="0.1")
	var xml_tree = XMLSceneTree.new()
	var r = xml_tree.get_root()
	r.add_property("name", self.name)
	r.add_child("NearestPointROI").add_properties({
		"template":"Vec3d",
		"name":self.name+"np",
		"object1":o1d,
		"object2":o2d,
		"radius":attach_distance,
	})
	
	 #   root_node.addObject("AttachConstraint",
	 #       object1="@/Gallbladder",
	 #       object2="@Scene/ConnectiveTissue",
	 #       indices1 =  "@np1.indices1",
	 #       indices2 =  "@np1.indices2",
	 #       twoWay= "true"
	 #       )
	
	
	r.add_child("AttachConstraint").add_properties({
		"object1":o1,
		"object2":o2,
		"indices1":"@" + self.name+"np" + ".indices1",
		"indices2":"@" + self.name+"np" + ".indices2",
		"twoWay":"true",
	})
	
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
