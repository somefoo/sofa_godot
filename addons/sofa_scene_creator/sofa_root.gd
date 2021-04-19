tool
extends Node
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")


export(String) var scene_name = "SofaScene"
export(Vector3) var gravity = Vector3(0,-9.81,0)
export(float) var time_step = 0.02

func _enter_tree():
	pass

func is_root():
	return true

func is_sofa_node(obj):
	var is_sofa_component = true
	if(obj.get_script() == null):
		is_sofa_component = false
	elif (obj.get_script().get_path().split('/')[-1].find("sofa") != 0):
		is_sofa_component = false
	return is_sofa_component

#http://shapecatcher.com/unicode/block/Box_Drawing
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
		else:
			print("[✘] " + prepend + child.get_name() + " (IGNORE)") 

		var child_prepend = prepends.duplicate(true)
		child_prepend.append(" │")
		explore_subtree(child,child_prepend, depth + 1)

#[✔] - U+2714
#[✘] - U+2718
func _ready():
	assert(get_tree().get_root().get_children().size() != 0, "Error, you must have at least one root node.") #This can never happen :P
	assert(get_tree().get_root().get_children().size() == 1, "Error, there are multiple objects in the root, make sure you only have one.") #This may never happen?
	print(typeof(get_tree().get_root().get_children()[0]))
	assert(get_tree().get_root().get_children()[0].has_method("is_root"), "Error, the root node does not have a the required Sofa root node script.")
	assert(get_tree().get_root().get_children()[0].is_root() == true, "Error, the root node doesn't believe it is a root node.") #This should never happen.
	print("Checking tree (root)...")
	print("[✔] Successfully checked the presence of the root node: All OK")
	print("Checking tree (children)...")
	
	explore_subtree(get_tree().get_root())
	var my_tree = XMLSceneTree.new()
	my_tree.add_property("name", "my_doodle")
	my_tree.add_child()
	#my_tree
	print(my_tree.to_xml())
	
	print("I am a super cool thing!")
