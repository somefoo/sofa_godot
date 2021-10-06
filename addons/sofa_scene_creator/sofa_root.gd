tool
extends Node
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")
const SofaExternalBinary = preload("res://addons/sofa_scene_creator/sofa_external_binary_interface.gd")
var DebugDraw = preload("res://addons/sofa_scene_creator/debug_draw.gd").new() 
#enum UNIT {KILOGRAM_METER, KILOGRAM_MILIMETER}
#export(UNIT) var unit = UNIT.KILOGRAM_MILIMETER

export(String) var scene_name = "SofaScene"
export(Vector3) var gravity = Vector3(0,-9.81,0)


export(float) var collision_distance = 0.5
export(float) var time_step = 0.02
#export(String, FILE, GLOBAL) var sofa_binary_path = ""
#export(String, FILE, GLOBAL) var gmsh_binary_path = ""
#export(String, FILE, GLOBAL) var ctmconv_binary_path = ""
export(bool) var print_sofa_output = false
export(bool) var print_gmsh_output = false
export(bool) var print_xml_output = false


func _enter_tree():
	add_child(DebugDraw)
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
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaMiscCollision")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaGeneralEngine")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaGeneralDeformable")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaBoundaryCondition")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaGeneralObjectInteraction")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaConstraint")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaLoader")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaImplicitOdeSolver")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaMeshCollision")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaSimpleFem")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaRigid")
	
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaCarving")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaGeneralSimpleFem")
	root_tree.add_child(root_tree.get_root(), "RequiredPlugin").add_property("name", "SofaTopologyMapping")
	
	
	
	
	
	
	root_tree.add_child(root_tree.get_root(), "DefaultPipeline").add_properties({"name":"CollisionPipeline", "verbose":"0", "depth":"6"})
	root_tree.add_child(root_tree.get_root(), "DefaultCollisionGroupManager")
	root_tree.add_child(root_tree.get_root(), "DefaultContactManager").add_properties({"name":"Response", "response":"default"})
	root_tree.add_child(root_tree.get_root(), "NewProximityIntersection").add_properties({"alarmDistance":collision_distance*2, "contactDistance":collision_distance})
	root_tree.add_child(root_tree.get_root(), "FreeMotionAnimationLoop")
	root_tree.add_child(root_tree.get_root(), "BVHNarrowPhase")
	root_tree.add_child(root_tree.get_root(), "BruteForceBroadPhase")
	root_tree.add_child(root_tree.get_root(), "GenericConstraintSolver").add_properties({"tolerance":0.001, "maxIterations":1000})
	root_tree.add_child(root_tree.get_root(), "CarvingManager").add_properties({"active":true, "carvingDistance":collision_distance*1.2})
	
	return root_tree

# Returns true, as this is the root object
# TODO This isn't really needed for actual functions
# But is used for asserts (maybe we can remove this)
func is_root():
	return true

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
		var is_sofa_component = SofaUtility.is_sofa_node(child)
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
			SofaUtility.get_sofa_absolute_name(child)
			if(child.has_method("get_xml")):
				#child.get_xml()
				pass
		else:
			print("[✘] " + prepend + child.get_name() + " (IGNORE)") 

		var child_prepend = prepends.duplicate(true)
		child_prepend.append(" │")
		explore_subtree(child,child_prepend, depth + 1)
	

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
		var is_sofa_component = SofaUtility.is_sofa_node(child)

		if(is_sofa_component):
			var my_tree = xml_tree.get_root()
			var child_tree = construct_xml_tree(child)
			assert(my_tree != null) #I can't be null
			if(child_tree != null): #But my child can be (wants to be ignored)
				xml_tree.get_root().append(child_tree.get_root())
	return xml_tree


# Variable needed for post-attach of requirements to nodes
var _post_construction_attachments_paths = []
# Variable needed for post-attach of requirements to nodes
var _post_construction_attachments_trees = []

# This function will cause addition trees to be attached to the tree constructed
# from the scene. Can be used to add required nodes to objects.
func add_requirement_to_node(node, tree : XMLSceneTree):
	assert(SofaUtility.is_sofa_node(node), "Error, trying to attach to non-sofa node.")
	_post_construction_attachments_paths.push_back(SofaUtility.get_sofa_absolute_name(node))
	_post_construction_attachments_trees.push_back(tree)

# Returns an XMLTreeNode from path (SOFA path)
func find_xml_node_by_path(root : XMLSceneTree.XMLTreeNode, path : String) -> XMLSceneTree.XMLTreeNode:
	var name_list = path.split('/')
	if(path == "@"):
		#Todo does this work?
		return root
	#name_list[0] = get_name()
	name_list.remove(0)
	
	var current_node = root
	
	while !name_list.empty():
		var found = null
		for c in current_node.get_childeren_list():
			#print("Check: " + str(c.get_properties_list().get("name")) + " == " + name_list[0])
			if c.get_properties_list().get("name") == name_list[0]:
				#print("Found: " + c.get_properties_list().get("name"))
				found = c
				break
				
		if found != null:
			name_list.remove(0)
			if(name_list.empty()):
				return found
			else:
				current_node = found
		else:
			return null
		
		return null
	
	while current_node.get_childeren_list()[0].get(name) == name_list[0]:
		current_node = current_node.get_childeren_list()[name]
		name_list.pop_front()
		if(name_list.empty()):
			return current_node
	return null

#[✔] - U+2714
#[✘] - U+2718
func _ready():
	if not Engine.is_editor_hint():
		###########################
		#SofaExternalBinary.get_terminal_emulator()
		var sofa_bin = SofaExternalBinary.find_required_binary("sofa",
		 "", 
		"https://github.com/sofa-framework/sofa/releases/download/v21.06.00/SOFA_v21.06.00_Linux.zip",
		true,
		"SOFA_v21.06.00_Linux/bin/runSofa-21.06.00")
		SofaExternalBinary.install_distro_package("libopengl0")
		###########################
		
		print("Checking tree (root)...")
		assert(get_tree().get_root().get_children().size() != 0, "Error, you must have at least one root node.") #This can never happen :P
		assert(get_tree().get_root().get_children().size() == 1, "Error, there are multiple objects in the root, make sure you only have one.") #This may never happen?
		assert(get_tree().get_root().get_children()[0].has_method("is_root"), "Error, the root node does not have a the required Sofa root node script.")
		assert(get_tree().get_root().get_children()[0].is_root() == true, "Error, the root node doesn't believe it is a root node.") #This should never happen.

		print("[✔] Successfully checked the presence of the root node: All OK")
		print("Checking tree (children)...")
		
		explore_subtree(get_tree().get_root())
		
		#print(my_tree.to_xml())
		var xml_tree = construct_xml_tree(self)
		
		while(!_post_construction_attachments_paths.empty()):
			var n = find_xml_node_by_path(xml_tree.get_root(), _post_construction_attachments_paths[0])
			assert(n != null, "Internal Error, trying to post-attach to node which doesn't exist.")
			n.append(_post_construction_attachments_trees[0].get_root())
			_post_construction_attachments_paths.pop_front()
			_post_construction_attachments_trees.pop_front()
			
		
		var xml_string = xml_tree.to_xml()
		if(print_xml_output):
			print(xml_string)
		var file = File.new()
		file.open("/tmp/generated_sofa_scene.scn", File.WRITE)
		file.store_string(xml_string)
		file.close()

		sofa_bin.execute(['/tmp/generated_sofa_scene.scn'], true, print_sofa_output)

		
		get_tree().quit()

func draw_line(p0, p1, color : Color = Color(1,0,0,1)):
	DebugDraw.draw_line(p0, p1, color)

