extends Reference
# Utility function: Returns true  if an object is a sofa object
#					Returns false if an object is not a sofa object
static func is_sofa_node(obj) -> bool:
	if(obj.get_script() == null):
		return false
	elif (obj.get_script().get_path().split('/')[-1].find("sofa") != 0):
		return false
	elif(obj.has_method("is_visible") && obj.is_visible() == false):
		return false
	return true

static func is_valid_sofa_ROI(obj) -> bool:
	if(!is_sofa_node(obj)):
		return false
	elif (obj.get_script().get_path().split('/')[-1].find("ROI") == -1):
		return false
	return true


static func is_valid_sofa_object(obj) -> bool:
	if(!is_sofa_node(obj)):
		return false
	elif (obj.get_script().get_path().split('/')[-1].find("sofa_object") != 0):
		return false
	elif(obj.soft_body == false):
		return false
	return true

static func get_sofa_absolute_name(obj) -> String:
	if(is_sofa_node(obj)):
		return "@/" + str(obj.get_path()).trim_prefix("/root/" + obj.get_tree().root.get_child(0).get_name() + "/")
		#while(obj.get_parent() != null):
		#	name = 
	else:
		assert(false, "Error, looking up sofa name of non-sofa object.")
		return ""
