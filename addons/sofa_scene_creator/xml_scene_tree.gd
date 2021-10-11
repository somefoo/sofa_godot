extends Reference

class XMLTreeNode:
	var _children = []
	var _type = "Node"
	var _properties = {}
	
	func _init(type = "Node"):
		_type = type
	func add_child(child):
		_children.append(XMLTreeNode.new(child))
		return _children[-1]
	
	func append(subtree : XMLTreeNode):
		if(subtree != null):
			_children.append(subtree)
	
	func add_property(name, value):
		_properties[name] = value
		return self
	func add_properties(properties):
		for p in range(0, properties.size()):
			_properties[properties.keys()[p]] = properties.values()[p]
		return self
	func get_childeren_list():
		return _children
	func get_properties_list():
		return _properties

var _root = null


func _init(type = "Node"):
	_root = XMLTreeNode.new(type)

## property_value: the typed property value, will be converted into
##                 a sensible string
## is_variable_assignment: Indicates if the output should be used for a
##                         direct assignment (like a = [1,2,3])
##                         or if it is a default XML-like assignment
##						   a = "1 2 3".
## We need to differentiate direct assignment from
## other assignments because lines like:
## sofa_root_node.gravity = "0, -9.81 0" 
## are not valid. 
func _value_to_string(property_value, is_variable_assignment = false):
		var delimeter = ', ' if is_variable_assignment else ' '
	
		var property_string = ""
		var iter = [TYPE_INT_ARRAY, TYPE_REAL_ARRAY, TYPE_ARRAY]
		var cnst = [TYPE_INT, TYPE_REAL, TYPE_STRING, TYPE_BOOL]
		var vect = [TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]
		if typeof(property_value) in iter:
			for i in property_value: property_string += str(i) + delimeter
		elif typeof(property_value) == TYPE_VECTOR2:
			property_string = str(property_value.x) + delimeter + str(property_value.y)
		elif typeof(property_value) == TYPE_VECTOR3:
			property_string = str(property_value.x) + delimeter + str(property_value.y) + delimeter + str(property_value.z)
		elif typeof(property_value) == TYPE_COLOR:
			property_string = str(property_value.r) + delimeter + str(property_value.g) + delimeter + str(property_value.b) + delimeter + str(property_value.a)
		elif typeof(property_value) in cnst:
			property_string = str(property_value)
		else:
			assert(false, "This property is currently not handled(" + str(typeof(property_value)) + "): " + str(property_value))
		
		if(typeof(property_value) in cnst && typeof(property_value) != TYPE_STRING):
			return property_string
		else:
			if(is_variable_assignment && typeof(property_value) in iter + vect):
				return "[" + property_string + "]"
			return '"' + property_string + '"'

func clear():
	_root = null

func get_root() -> XMLTreeNode:
	return _root

func add_child(node, type = "Node"):
	return node.add_child(type)
	
func add_property(node, name, value):
	return node.add_property(name, value)

# Creates an XML description of the scene
func to_xml():
	return to_xml_from_node(_root)
func to_xml_from_node(node, depth = 0):
	var properties_string = ""
	for p in range(0, node._properties.size()):
		var property_value = node._properties.values()[p]
		properties_string += node._properties.keys()[p] + '=' + _value_to_string(property_value) + ' '


	var xml_string = ''
	var prefix = '\t'.repeat(depth)
	if(node._children.size() == 0):
		xml_string += prefix + '<' + node._type + ' ' + properties_string + '/>'
	else:
		xml_string += prefix + '<' + node._type + ' ' + properties_string + '>'
		xml_string += '\n'
		for child in node._children:
			xml_string += to_xml_from_node(child, depth + 1)
		xml_string += prefix + '</' + node._type + '>'
	#var xml_string = '<?xml version="1.0" ?>'
	return xml_string + '\n'




# Creates a python3 description of the scene 
func to_python3():
	# Do stuff for root only (like the createScene call)
	var root_content = "def createScene(root_node):\n"
	for p in range(0, _root._properties.size()):
		var property_name = _root._properties.keys()[p]
		var property_value = _value_to_string(_root._properties.values()[p], true)
		root_content += "\troot_node." + property_name + ' = ' + str(property_value) + '\n'
	var sofa_root = "\treturn root_node\n"
	return root_content + to_python3_from_node("root_node",_root) + sofa_root
	
func to_python3_from_node(parent_name,node, depth = 0):
	var properties_string = ""
	for p in range(0, node._properties.size()):
		var property_value = node._properties.values()[p]
		properties_string += node._properties.keys()[p] + '=' + _value_to_string(property_value) + ', '

	var python_string = ''
	var prefix = '\t'.repeat(depth)
	if(node._children.size() == 0):
		python_string += prefix + parent_name + ".addObject(" + '"' + node._type + '", ' + properties_string + ')'
	else:
		# Make sure that the root node is not created as a child 
		if(depth > 0):
			python_string += prefix + node._properties["name"] + " = " + parent_name + ".addChild(" + '"' + node._type + '", ' + properties_string + ')'
			python_string += '\n'
			python_string += prefix + 'def add():\n'
			for child in node._children:
				#TODO Will _properties["name"] always exist?
				python_string += to_python3_from_node(node._properties["name"],child, depth + 1)
			python_string += prefix + 'add()'
		else:
			for child in node._children:
				python_string += to_python3_from_node(parent_name,child, depth + 1)
	return python_string + '\n'
