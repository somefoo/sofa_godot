# Note, this was actually made to allow two-point attachment
# but this feature is disabled (as it isn't working as expected)

tool
extends Spatial 
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")



export var object_1 : NodePath
export var object_2 : NodePath

export var line_start : Vector3 = Vector3(0,0,0)
export var line_end : Vector3 = Vector3(10,0,0)

var _two_point_attachment : bool = false
var _relative_attachment_1 : float = 0.5
var _relative_attachment_2 : float = 0.75
#export var attach_distance : float = 0.001

func _get(property):
	if property == "scale":
		return scale
	if property == "rotation_degrees":
		return rotation_degrees
	if property == "translation":
		return translation
	if property == "two_point_attachment":
		return _two_point_attachment
	if property == "relative_attachment_1":
		return _relative_attachment_1
	if property == "relative_attachment_2":
		return _relative_attachment_2
		
func _set(property, value):
	print(property)
	if property == "scale":
		scale = value
	if property == "rotation_degrees":
		rotation_degrees = value
	if property == "translation":
		translation = value
	if property == "two_point_attachment":
		_two_point_attachment = value
		if(value == true):
			_relative_attachment_1 = 0.25
			_relative_attachment_2 = 0.75
		else:
			_relative_attachment_1 = 0.5
		property_list_changed_notify()
	if property == "relative_attachment_1":
		if(!_two_point_attachment):
			_relative_attachment_1 = value
		else:
			if(value <= _relative_attachment_2):
				_relative_attachment_1 = value
			else:
				_relative_attachment_1 = _relative_attachment_2
			#return false
			
	if property == "relative_attachment_2":
		if(value >= _relative_attachment_1):
			_relative_attachment_2 = value
		else:
			_relative_attachment_2 = _relative_attachment_1
			#return false
		
	#if _relative_attachment_2 < _relative_attachment_1:
	#	print("reseeet")
	#	_relative_attachment_2 = _relative_attachment_1
	#	property_list_changed_notify()

func _get_property_list():
	var property_list = []
	
#	property_list.append({
#		"hint": PROPERTY_HINT_NONE,
#		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
#		"name": "two_point_attachment",
#		"type": TYPE_BOOL
#	})
	
	if(_two_point_attachment):
		property_list.append({
			"hint": PROPERTY_HINT_RANGE,
			"hint_string" : "0,1", #Hint that value must be in [0,1]
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
			"name": "relative_attachment_1",
			"type": TYPE_REAL
		})
		property_list.append({
			"hint": PROPERTY_HINT_RANGE,
			"hint_string" : "0,1", #Hint that value must be in [0,1]
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
			"name": "relative_attachment_2",
			"type": TYPE_REAL
		})
	else:
		property_list.append({
			"hint": PROPERTY_HINT_RANGE,
			"hint_string" : "0,1", #Hint that value must be in [0,1]
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
			"name": "relative_attachment_1",
			"type": TYPE_REAL
		})
	return property_list



func _enter_tree():
	pass

func get_xml_tree():
	#TODO remove hard coded "dofs" name?
	var o1 = SofaUtility.get_sofa_absolute_name(get_node(object_1))
	#if(!SofaUtility.is_valid_sofa_rigid_object(get_node(object_1))):
	#	assert(false, "Error: object in an sliding constraint must be Rigid Bodies (SOFA limitation)") # because SOFA doesn't like Rigidbodies
	
	
	var xml_tree_constraint = XMLSceneTree.new()
	var roi_root = xml_tree_constraint.get_root()
	roi_root.add_properties({"name":get_name()})
	if(_two_point_attachment):
		var between_point1 = (line_start*(_relative_attachment_1) + line_end * (1-_relative_attachment_1)) - get_node(object_1).translation
		var between_point2 = (line_start*(_relative_attachment_2) + line_end * (1-_relative_attachment_2)) - get_node(object_1).translation
		var position_string : String = ""
		position_string = str(between_point1[0]) + " " + str(between_point1[1]) + " " + str(between_point1[2]) + '&#x09;' + str(between_point2[0]) + " " + str(between_point2[1]) + " " + str(between_point2[2])
		roi_root.add_child("MechanicalObject").add_properties({"name":"points", "template":"Vec3d", "position":position_string})
		roi_root.add_child("RigidMapping")
	else:
		var between_point = (line_start*(_relative_attachment_1) + line_end * (1-_relative_attachment_1))
		roi_root.add_child("MechanicalObject").add_properties({"name":"points", "template":"Vec3d", "position":(between_point - get_node(object_1).translation)})
		roi_root.add_child("RigidMapping")
	
	SofaUtility.add_requirement(get_node(object_1), xml_tree_constraint)
	
	#var o1d = o1 + "/dofs"
	#var o2d = o2 + "/dofs"

	var xml_tree = XMLSceneTree.new()
	var r = xml_tree.get_root()
	r.add_property("name", self.name)
	
	var position_string : String = ""
	position_string = str(line_start[0]) + " " + str(line_start[1]) + " " + str(line_start[2]) + '&#x09;' + str(line_end[0]) + " " + str(line_end[1]) + " " + str(line_end[2])
	
	#TODO the order of the two created objects below is not correct
	
	r.add_child("MechanicalObject").add_properties({
		"name":"points",
		"template":"Vec3d",
		"position":position_string,
		"free_position":position_string,
	})
	
	r.add_child("SlidingConstraint").add_properties({
		"object1":o1 + "/" + self.name + "/points",
		"object2":"@points",
		"template":"Vec3d",
		"sliding_point":"0",
		"axis_1":"0",
		"axis_2":"1",
		#"indices1":"@" + self.name+"np" + ".indices1",
		#"indices2":"@" + self.name+"np" + ".indices2",
		#"twoWay":"true",
	})
	
	

	

	

	
	return xml_tree

func _process(delta):
	if(!object_1.is_empty()):
		if(_two_point_attachment):
			SofaUtility.draw_line(self, (line_start*(_relative_attachment_1) + line_end * (1-_relative_attachment_1)), get_node(object_1).translation, SofaUtility.COLOR_TARGET_OBJECT)
			SofaUtility.draw_line(self, (line_start*(_relative_attachment_2) + line_end * (1-_relative_attachment_2)), get_node(object_1).translation, SofaUtility.COLOR_TARGET_OBJECT)
		else:
			SofaUtility.draw_line(self, (line_start*(_relative_attachment_1) + line_end * (1-_relative_attachment_1)), get_node(object_1).translation, SofaUtility.COLOR_TARGET_OBJECT)
	SofaUtility.draw_cross(self, line_start, SofaUtility.COLOR_PURPLE)
	SofaUtility.draw_cross(self, line_end, SofaUtility.COLOR_PURPLE)
	SofaUtility.draw_line(self, line_start + Vector3(0,0.03,0), line_end + Vector3(0,0.03,0), SofaUtility.COLOR_PURPLE)
	SofaUtility.draw_line(self, line_start - Vector3(0,0.03,0), line_end - Vector3(0,0.03,0), SofaUtility.COLOR_PURPLE)
	
	if(_two_point_attachment):
		SofaUtility.draw_cross(self, (line_start*(_relative_attachment_1) + line_end * (1-_relative_attachment_1)), SofaUtility.COLOR_TURQUOISE)
		SofaUtility.draw_cross(self, (line_start*(_relative_attachment_2) + line_end * (1-_relative_attachment_2)), SofaUtility.COLOR_TURQUOISE)
		pass
	else:
		SofaUtility.draw_cross(self, (line_start*(_relative_attachment_1) + line_end * (1-_relative_attachment_1)), SofaUtility.COLOR_TURQUOISE)
		pass
	
	scale = Vector3(0,0,0)
	#translation = Vector3(0,0,0)
	rotation = Vector3(0,0,0)
