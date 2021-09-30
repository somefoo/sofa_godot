extends Reference


class ExternalBinary:
	var _name = ""
	var _path = ""
	
	func _init(path : String):
		_path = path
		
		
	func execute(arguments, is_blocking : bool = true, print_output : bool = false):
		var output = []
		var pid = OS.execute(_path, arguments, is_blocking, output)
		if(print_output):
			print("OUTPUT: " + _path)
			for line in output:
				print('\t' + line)
		return false
		


enum BINARY{
	sofa,
	ctmconv,
	gmsh,
}

var binary_dictionary = {
	"sofa" : "",
	"ctmconv" : "/usr/bin/ctmconv",
	"gmsh" : "/usr/bin/gmsh",
	
}


static func get_terminal_emulator():
	
	var output = []
	var terminal_options = [
		"gnome-terminal",
		"xterm",
		"test",
	]
	
	
	OS.execute("which", ["gnome-terminal"], true, output)
	if(output[0] != ""):
		print("Found gnome-terminal")
		return ExternalBinary.new(output[0])
	
	OS.execute("which", ["xterm"], true, output)
	if(output[0] != ""):
		print("Found xterm")
		return ExternalBinary.new(output[0])
		
	



static func find_required_binary(binary : String, distribution_package_name : String = "", wget_location : String = ""):
	var project_path = ProjectSettings.globalize_path("res://")
	var local_binary_path = project_path + "LocalBinary/"+ binary +".run"
	
	var local_binary = File.new()
	var output = []
	
	
	if(local_binary.file_exists(local_binary_path)):
		return ExternalBinary.new(local_binary_path)
	elif(OS.execute("which", [binary], true, output) == 0):
		return ExternalBinary.new(output[0])
	else:
		#Not installed
		if distribution_package_name != "":
			
			OS.shell_open("apt:" + distribution_package_name)
		elif wget_location != "":
			var exit_code = OS.execute("zenity", 
			["--title", "Install Sofa?",
			 "--ok-label", "Yes",
			 '--cancel-label', "No, I want to select it manually",
			 '--question',
			 "--text", binary.capitalize() + " was not found, would you like to install a local version?",
			 '--ellipsize'],
			true, output)
			
			if(exit_code == 0):
				#Download local
				
				var dir = Directory.new()
				dir.open(project_path)
				dir.make_dir("LocalBinary")
				var tmp_binary_path = project_path + "LocalBinary/tmp_" + binary + ".run"
				
				var url = wget_location
				var wget = "wget " + "-q --show-progress --output-document " + tmp_binary_path + ' "' + url + '"' + " 2>&1 "
				var sed = "sed -u 's/%.*//' | sed -u 's/.*K//' | sed -u 's/[^0-9]*//g'"
				var zenity = 'zenity --text="' + binary.capitalize() + '" --title="Downloading..." --progress --auto-close --auto-kill'
				var check = 'mv ' + tmp_binary_path + " " + local_binary_path
				
				var eval_string =  wget + " | " + sed + " | " + zenity + " && " + check
				OS.execute("eval", [eval_string], true)
				return ExternalBinary.new(local_binary_path)
				
		#Select locally
		var file_selection_exit_code = OS.execute("eval", ['zenity --title ' + binary.capitalize() + ' --file-selection 2> /dev/null'], true, output)
		if(file_selection_exit_code == 0):
			return ExternalBinary.new(output[0])
			
	return 
#	assert(binary_dictionary.has(binary), "Error, wanted binary is unkown.")
#
#	var path = binary_dictionary[binary]
#	var file = File.new()
#
#	if(file.file_exists(path)):
#		file.close()
#		return ExternalBinary.new(path)
#	else:
#		file.close()
#		print("Warning, binary not found.")

func install_ctmconv():
	return ""
