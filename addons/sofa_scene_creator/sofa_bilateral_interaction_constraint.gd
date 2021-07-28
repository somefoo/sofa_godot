tool
extends Spatial 
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")

export var object_1 : NodePath
export var object_2 : NodePath
#export var attach_distance : float = 0.001

func _enter_tree():
	pass

func get_xml_tree():
	#TODO remove hard coded "dofs" name?
	var o1 = SofaUtility.get_sofa_absolute_name(get_node(object_1))
	var o2 = SofaUtility.get_sofa_absolute_name(get_node(object_2))
	if(!SofaUtility.is_valid_sofa_rigid_object(get_node(object_1)) || !SofaUtility.is_valid_sofa_rigid_object(get_node(object_2))):
		assert(false, "Error: both objects in an bilateral interaction constraint must be Rigid Bodies (SOFA limitation)") # because SOFA doesn't like Rigidbodies
	
	
	var xml_tree_constraint = XMLSceneTree.new()
	var roi_root = xml_tree_constraint.get_root()
	roi_root.add_properties({"name":get_name()})
	roi_root.add_child("MechanicalObject").add_properties({"name":"point", "template":"Vec3d", "position":translation})
	roi_root.add_child("RigidMapping")
	
	SofaUtility.add_requirement(get_node(object_1), xml_tree_constraint)
	SofaUtility.add_requirement(get_node(object_2), xml_tree_constraint)
	
	#var o1d = o1 + "/dofs"
	#var o2d = o2 + "/dofs"

	var xml_tree = XMLSceneTree.new()
	var r = xml_tree.get_root()
	r.add_property("name", self.name)
	
	r.add_child("BilateralInteractionConstraint").add_properties({
		"object1":o1 + "/" + self.name + "/point",
		"object2":o2 + "/" + self.name + "/point",
		"template":"Vec3d",
		"first_point":"0",
		"second_point":"0",
		#"indices1":"@" + self.name+"np" + ".indices1",
		#"indices2":"@" + self.name+"np" + ".indices2",
		#"twoWay":"true",
	})
	
	return xml_tree

func _process(delta):
	if(!object_1.is_empty() && !object_2.is_empty()):
		SofaUtility.draw_line(self, translation, get_node(object_1).translation, SofaUtility.COLOR_TARGET_OBJECT)
		SofaUtility.draw_line(self, translation, get_node(object_2).translation, SofaUtility.COLOR_TARGET_OBJECT)
	SofaUtility.draw_cross(self, translation, SofaUtility.COLOR_BLACK)
	scale = Vector3(0,0,0)
	#translation = Vector3(0,0,0)
	rotation = Vector3(0,0,0)
