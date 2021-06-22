tool
extends Node
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")


export(String) var scene_name = "SofaScene"
export(Vector3) var gravity = Vector3(0,-9.81,0)
export(String, FILE, GLOBAL) var sofa_binary_path = ""
export(String, FILE, GLOBAL) var gmsh_binary_path = ""
export(String, FILE, GLOBAL) var ctmconv_binary_path = ""
export(bool) var print_sofa_output = false
export(bool) var print_gmsh_output = false
export(bool) var print_xml_output = false
export(float) var time_step = 0.02

func _enter_tree():
	#Fix godot prinout limit:
	if(Engine.is_editor_hint()):
		ProjectSettings.set_setting("network/limits/debugger_stdout/max_chars_per_second", 2048*100)
		ProjectSettings.set_setting("network/limits/debugger_stdout/max_messages_per_frame", 10*100)
		ProjectSettings.save()
	
	
# This function returns the xml root tree (the most top-level xml node)
func get_xml_tree():
	# Use this as a new basis!
	# file:///home/pit/repos/sofa/src/examples/Components/constraint/BilateralInteractionConstraint.scn
	var root_tree = XMLSceneTree.new()
	root_tree.get_root().add_properties({"name":get_name(), "dt":time_step, "gravity":gravity})
	#root_tree.add_property(root_tree.get_root(), "name", "root")
	#root_tree.add_property(root_tree.get_root(), "dt", 0.02)
	
	# TODO Which ones do we really need? We could just load all
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaOpenglVisual")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaBoundaryCondition")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaGeneralSimpleFem")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaMiscCollision")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaLoader")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaConstraint")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaImplicitOdeSolver")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaRigid")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaCarving")
	
	
	root_tree.add_child(root_tree.get_root(), "DefaultPipeline").add_properties({"name":"CollisionPipeline", "verbose":"0", "depth":"6"})
	root_tree.add_child(root_tree.get_root(), "DefaultCollisionGroupManager")
	root_tree.add_child(root_tree.get_root(), "DefaultContactManager").add_properties({"name":"Response", "response":"default"})
	root_tree.add_child(root_tree.get_root(), "NewProximityIntersection").add_properties({"alarmDistance":"1", "contactDistance":"0.5"})
	root_tree.add_child(root_tree.get_root(), "FreeMotionAnimationLoop")
	root_tree.add_child(root_tree.get_root(), "BruteForceDetection").add_properties({"name":"N2"})
	root_tree.add_child(root_tree.get_root(), "GenericConstraintSolver").add_properties({"tolerance":0.001, "maxIterations":1000})
	
	
	
	
	#root_tree.add_child(root_tree.get_root(), "DefaultPipeline").add_properties({"name":"CollisionPipeline", "verbose":"0"})
	#root_tree.add_child(root_tree.get_root(), "BruteForceDetection").add_properties({"name":"N2"})
	#root_tree.add_child(root_tree.get_root(), "DefaultContactManager").add_properties({"name":"collision response", "response":"default"})
	return root_tree

# Returns true, as this is the root object
# TODO This isn't really needed for actual functions
# But is used for asserts (maybe we can remove this)
func is_root():
	return true

# Utility function: Returns true  if an object is a sofa object
#					Returns false if an object is not a sofa object
func is_sofa_node(obj):
	var is_sofa_component = true
	if(obj.get_script() == null):
		is_sofa_component = false
	elif (obj.get_script().get_path().split('/')[-1].find("sofa") != 0):
		is_sofa_component = false
	elif(obj.has_method("is_visible") && obj.is_visible() == false):
		is_sofa_component = false
	return is_sofa_component

# A utility function used to print the scene tree
# it is mostly for debugging scenes during development
func explore_subtree(obj, prepends=[""], depth=0):
	var valid_children = []
	for child in obj.get_children():
		if(typeof(child) != TYPE_OBJECT):
			continue
		if(child.get_name().find("@@") == 0):
			continue
		valid_children.append(child)
	
	for child_id in range(0, valid_children.size()):
		var last_child = child_id == valid_children.size() - 1
		if(last_child): prepends[depth] = "  "
		
		var child = valid_children[child_id]
		var is_sofa_component = is_sofa_node(child)
		#print(prepend + child.get_name())
		var prepend = ""
		for p in prepends:
			prepend = prepend + p
		
		if(depth > 0):
			if(last_child):
				prepend[-1] = "╰"
			else:
				prepend[-1] = "├"
		if(is_sofa_component):
			print("[✔] " + prepend + child.get_name() + "")
			get_sofa_absolute_name(child)
			if(child.has_method("get_xml")):
				#child.get_xml()
				pass
		else:
			print("[✘] " + prepend + child.get_name() + " (IGNORE)") 

		var child_prepend = prepends.duplicate(true)
		child_prepend.append(" │")
		explore_subtree(child,child_prepend, depth + 1)

func get_sofa_absolute_name(obj):
	var name = ""
	if(is_sofa_node(obj)):
		return "@/" + str(obj.get_path()).trim_prefix("/root/" + get_name() + "/")
		#while(obj.get_parent() != null):
		#	name = 
	else:
		print("Error, looking up sofa name of non-sofa object.")
		get_tree().quit()
	

# This function creates the actual XML tree out of the
# currently loaded scene. The returned object can then
# be stringified into an XML file.
func construct_xml_tree(obj, depth=0):
	#print(obj.name)
	var xml_tree = obj.get_xml_tree()
	var valid_children = []
	for child in obj.get_children():
		if(typeof(child) != TYPE_OBJECT):
			continue
		if(child.get_name().find("@@") == 0):
			continue
		valid_children.append(child)
	
	for child_id in range(0, valid_children.size()):

		var child = valid_children[child_id]
		var is_sofa_component = is_sofa_node(child)

		if(is_sofa_component):
			var my_tree = xml_tree.get_root()
			var child_tree = construct_xml_tree(child)
			assert(my_tree != null) #I can't be null
			if(child_tree != null): #But my child can be (wants to be ignored)
				xml_tree.get_root().append(child_tree.get_root())
	return xml_tree




#[✔] - U+2714
#[✘] - U+2718
func _ready():
	if not Engine.is_editor_hint():
		print("Checking tree (root)...")
		assert(get_tree().get_root().get_children().size() != 0, "Error, you must have at least one root node.") #This can never happen :P
		assert(get_tree().get_root().get_children().size() == 1, "Error, there are multiple objects in the root, make sure you only have one.") #This may never happen?
		assert(get_tree().get_root().get_children()[0].has_method("is_root"), "Error, the root node does not have a the required Sofa root node script.")
		assert(get_tree().get_root().get_children()[0].is_root() == true, "Error, the root node doesn't believe it is a root node.") #This should never happen.

		print("[✔] Successfully checked the presence of the root node: All OK")
		print("Checking tree (children)...")
		
		explore_subtree(get_tree().get_root())
		

		
		
		
		#my_tree
		#print(my_tree.to_xml())
		var xml_string = construct_xml_tree(self).to_xml()
		if(print_xml_output):
			print(xml_string)
		var file = File.new()
		file.open("/tmp/generated_sofa_scene.scn", File.WRITE)
		file.store_string(xml_string)
		file.close()
		
		
		var sofa_binary = File.new()
		if(sofa_binary.file_exists(sofa_binary_path)):
			var output = []
			#Blocking call:
			var pid = OS.execute(sofa_binary_path, ['/tmp/generated_sofa_scene.scn'], true, output)
			if(print_sofa_output):
				print("########## SOFA OUTPUT BEGIN ##########")
				for line in output:
					print(line)
				print("########## SOFA OUTPUT END   ##########")
			
		else:
			print("Sofa path not set correctly, sofa will not be opened.")
			print("  Set the sofa binary path in the root node.")
		
		get_tree().quit()
