#class_name SofaXMLNode

var _data = {"___type":"Node"}

func set_type(type):
	_data["___type"] = type

func add_property(name, value):
	assert(name.find('___') != 0, "Error, ___ is a reserved prefix!")
		
	_data[name] = value
	
	#_properties[name] = str(value)

func add_child(type = "Node"):
	#Godot does not allow recursive type definition, this is a work-around
	var child = "___child" + str(_data.size())
	_data[child] = {"___type":"Node"}
	return _data[child]
	
func to_xml(depth = 0):
	return _to_xml(_data)
	
func _to_xml(data, depth = 0):
	var properties_string = ""
	for p in range(0, _data.size()):
		if(_data.keys()[p].find('___') != 0):
			properties_string += data.keys()[p] + ' = "' + data.values()[p] + '" '
	
	
	var xml_string = ''
	var prefix = ' '.repeat(depth)
	
	var child_count = 0
	for c in range(0, data.size()):
		if(data.keys()[c].find('___child') == 0):
			child_count += 1
	
	
	if(child_count == 0):
		xml_string += prefix + '<' + data['___type'] + ' ' + properties_string + '/>'
	else:
		xml_string += prefix + '<' + data['___type'] + ' ' + properties_string + '>'
		xml_string += '\n'
		for c in range(0, data.size()):
			if(data.keys()[c].find('___child') == 0):
				xml_string += _to_xml(data.keys()[c], depth + 1)
		xml_string += prefix + '</' + data['___type'] + '>'
	#var xml_string = '<?xml version="1.0" ?>'
	return xml_string + '\n'


##class_name SofaXMLNode
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
