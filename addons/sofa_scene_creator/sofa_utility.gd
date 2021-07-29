extends Reference

const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")

const COLOR_TARGET_OBJECT : Color =	Color(0.5, 0.5, 0.0, 0.3)
const COLOR_TARGET_ROI : Color = 	Color(1.0, 0.0, 0.0, 0.3)
const COLOR_YELLOW : Color = 		Color(1.0, 1.0, 0.0, 0.5)
const COLOR_PURPLE : Color = 		Color(1.0, 0.0, 1.0, 0.5)
const COLOR_TURQUOISE : Color = 	Color(0.0, 1.0, 1.0, 0.5)
const COLOR_BLACK : Color = 		Color(0.0, 0.0, 0.0, 0.5)
const COLOR_WHITE : Color = 		Color(1.0, 1.0, 1.0, 0.5)
const COLOR_RED : Color = 			Color(1.0, 0.0, 0.0, 0.5)
const COLOR_GREEN : Color = 		Color(0.0, 1.0, 0.0, 0.5)
const COLOR_BLUE : Color = 			Color(0.0, 0.0, 1.0, 0.5)
# Utility function: Returns true  if an object is a sofa node
#					Returns false if not
static func is_sofa_node(obj, verbose : bool = false) -> bool:
	if(obj.get_script() == null):
		if (verbose): print("No script attached.")
		return false
	elif (obj.get_script().get_path().split('/')[-1].find("sofa") != 0):
		if (verbose): print('No script containing the word "sofa" attached.')
		return false
	elif(obj.has_method("is_visible") && obj.is_visible() == false):
		if (verbose): print("Not visible.")
		return false
	return true

# Utility function: Returns true if an object is a sofa region of interest
#					Returns false if not
static func is_valid_sofa_ROI(obj, verbose : bool = false) -> bool:
	if(!is_sofa_node(obj)):
		return false
	elif (obj.get_script().get_path().split('/')[-1].find("roi") == -1):
		if (verbose): print('No script containing the word "roi" attached.')
		return false
	return true

# Utility function: Returns true if an object is a sofa soft body object (specific node)
#					Returns false if not
static func is_valid_sofa_softbody_object(obj, verbose : bool = false) -> bool:
	if(!is_sofa_node(obj)):
		return false
	elif (obj.get_script().get_path().split('/')[-1].find("sofa_object") != 0):
		if (verbose): print('No script containing the word "sofa_object" attached.')
		return false
	elif(obj.soft_body == false):
		if (verbose): print('Object is not a soft body.')
		return false
	return true
	
	
# Utility function: Returns true if an object is a sofa rigid body object (specific node)
#					Returns false if not
static func is_valid_sofa_rigid_object(obj, verbose : bool = false) -> bool:
	if(!is_sofa_node(obj)):
		return false
	elif (obj.get_script().get_path().split('/')[-1].find("sofa_object") != 0):
		if (verbose): print('No script containing the word "sofa_object" attached.')
		return false
	elif(obj.soft_body == true):
		if (verbose): print('Object is not a rigid body.')
		return false
	return true

# Utility function: Returns true if an object is a sofa object (specific node)
#					Returns false if not
static func is_valid_sofa_object(obj, verbose : bool = false) -> bool:
	if(!is_sofa_node(obj)):
		return false
	elif (obj.get_script().get_path().split('/')[-1].find("sofa_object") != 0):
		if (verbose): print('No script containing the word "sofa_object" attached.')
		return false
	return true

# Utility function: Returns the SOFA path to the object
static func get_sofa_absolute_name(obj) -> String:
	if(is_sofa_node(obj)):
		return "@/" + str(obj.get_path()).trim_prefix("/root/" + obj.get_tree().root.get_child(0).get_name() + "/")
	else:
		assert(false, "Error, looking up sofa name of non-sofa object.")
		return ""

# Utility function: Adds a requirement to an object
static func add_requirement(obj : Node, requirement : XMLSceneTree):
	obj.get_tree().root.get_child(0).add_requirement_to_node(obj, requirement)

static func draw_line(obj : Node, p0, p1, color : Color = Color(1,0,0,1)):
	if(obj.is_visible()):
		var p = obj
		# Bad, what if the root is not called SofaRoot?
		while(p.name != "SofaRoot"):
			p = p.get_parent()
		
		p.draw_line(p0, p1, color)
	
static func draw_cross(obj : Node, p0, color : Color = Color(1,0,0,1)):
	var s = 1
	draw_line(obj, p0 - Vector3(1,0,0) * s, p0 + Vector3(1,0,0) * s, color)
	draw_line(obj, p0 - Vector3(0,1,0) * s, p0 + Vector3(0,1,0) * s, color)
	draw_line(obj, p0 - Vector3(0,0,1) * s, p0 + Vector3(0,0,1) * s, color)
