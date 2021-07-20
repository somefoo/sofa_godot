extends Reference
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
