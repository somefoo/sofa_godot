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
	
	func append(subtree):
		if(subtree != null):
			_children.append(subtree)
	
	func add_property(name, value):
		_properties[name] = value
		return self
	func add_properties(properties):
		for p in range(0, properties.size()):
			_properties[properties.keys()[p]] = properties.values()[p]
		return self

var _root = null


func _init(type = "Node"):
	_root = XMLTreeNode.new(type)

func clear():
	_root = null

func get_root():
	return _root

func add_child(node, type = "Node"):
	return node.add_child(type)
	
func add_property(node, name, value):
	return node.add_property(name, value)

func to_xml():
	return to_xml_from_node(_root)
func to_xml_from_node(node, depth = 0):
	var properties_string = ""
	for p in range(0, node._properties.size()):
		var property_value = node._properties.values()[p]
		var property_string = ""
		
		var iter = [TYPE_INT_ARRAY, TYPE_REAL_ARRAY]
		var cnst = [TYPE_INT, TYPE_REAL, TYPE_STRING, TYPE_BOOL]
		if typeof(property_value) in iter:
			for i in property_value: property_string += str(i) + " "
		elif typeof(property_value) == TYPE_VECTOR2:
			property_value = str(property_value.x) + " " + str(property_value.y)
		elif typeof(property_value) == TYPE_VECTOR3:
			property_value = str(property_value.x) + " " + str(property_value.y) + " " + str(property_value.z)
		elif typeof(property_value) in cnst:
			property_value = str(property_value)
		else:
			assert(false, "This property is currently not handled: " + str(property_value))
			
		properties_string += node._properties.keys()[p] + '="' + property_value + '" '


	var xml_string = ''
	var prefix = ' '.repeat(depth)
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


#class_name SofaXMLNode

#var _data = {"___type":"Node"}
#
#func set_type(type):
#	_data["___type"] = type
#
#func add_property(name, value):
#	assert(name.find('___') != 0, "Error, ___ is a reserved prefix!")
#
#	_data[name] = value
#
#	#_properties[name] = str(value)
#
#func add_child(type = "Node"):
#	#Godot does not allow recursive type definition, this is a work-around
#	var child = "___child" + str(_data.size())
#	_data[child] = {"___type":"Node"}
#	return _data[child]
#
#func to_xml(depth = 0):
#	return _to_xml(_data)
#
#func _to_xml(data, depth = 0):
#	var properties_string = ""
#	for p in range(0, _data.size()):
#		if(_data.keys()[p].find('___') != 0):
#			properties_string += data.keys()[p] + ' = "' + data.values()[p] + '" '
#
#
#	var xml_string = ''
#	var prefix = ' '.repeat(depth)
#
#	var child_count = 0
#	for c in range(0, data.size()):
#		if(data.keys()[c].find('___child') == 0):
#			child_count += 1
#
#
#	if(child_count == 0):
#		xml_string += prefix + '<' + data['___type'] + ' ' + properties_string + '/>'
#	else:
#		xml_string += prefix + '<' + data['___type'] + ' ' + properties_string + '>'
#		xml_string += '\n'
#		for c in range(0, data.size()):
#			if(data.keys()[c].find('___child') == 0):
#				xml_string += _to_xml(data.keys()[c], depth + 1)
#		xml_string += prefix + '</' + data['___type'] + '>'
#	#var xml_string = '<?xml version="1.0" ?>'
#	return xml_string + '\n'


#class_name SofaXMLNode
#
#var _children = []
#var _type = "Node"
#var _properties = {}
#
#var _info = {}
#
#func set_type(type):
#	_type = type
#
#func add_property(name, value):
#	_properties[name] = str(value)
#
#func add_child(type = "Node"):
#	#_children.append(SofaXMLNode.new())
#	pass
#
#func to_xml(depth = 0):
#	var properties_string = ""
#	for p in range(0, _properties.size()):
#		properties_string += _properties.keys()[p] + ' = "' + _properties.values()[p] + '" '
#
#
#	var xml_string = ''
#	var prefix = ' '.repeat(depth)
#	if(_children.size() == 0):
#		xml_string += prefix + '<' + _type + ' ' + properties_string + '/>'
#	else:
#		xml_string += prefix + '<' + _type + ' ' + properties_string + '>'
#		xml_string += '\n'
#		for child in _children:
#			xml_string += child.to_xml(depth + 1)
#		xml_string += prefix + '</' + _type + '>'
#	#var xml_string = '<?xml version="1.0" ?>'
#	return xml_string + '\n'
