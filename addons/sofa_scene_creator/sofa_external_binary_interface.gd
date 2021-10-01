extends Reference


class ExternalBinary:
	var _name = ""
	var _path = ""
	
	func _init(path : String):
		_path = path
		
	# Executes the binary
	func execute(arguments, is_blocking : bool = true, print_output : bool = false):
		var output = []
		var pid = OS.execute(_path, arguments, is_blocking, output)
		if(print_output):
			print("OUTPUT: " + _path)
			for line in output:
				print('\t' + line)
		return false

static func _get_local_binary_folder():
	var project_path = ProjectSettings.globalize_path("res://")
	var folder_name = "LocalBinary"
	var absolute_path = project_path + folder_name +"/"
	
	# Create folder if it doesn't already exist
	var dir = Directory.new()
	if dir.dir_exists(absolute_path):
		return absolute_path
	else:
		dir.open(project_path)
		dir.make_dir("folder_name")
	
		# Ensure Godot ignores the content
		var file = File.new()
		file.open(absolute_path + ".gdignore", File.WRITE)
		file.store_string("")
		file.close()

	return absolute_path

static func _get_local_binary_path(binary : String):
	return _get_local_binary_folder() + binary
	
static func _local_binary_available(binary : String):
	var local_binary = File.new()
	if(local_binary.file_exists(_get_local_binary_path(binary))):
		return true

static func _wget_binary(binary : String, wget_location : String = "", zip : bool = false, relative_run_path : String = ""):
	var project_path = ProjectSettings.globalize_path("res://")
	var local_binary_path = _get_local_binary_path(binary)
	
	var local_binary = File.new()
	var output = []
		

	
	var tmp_binary_path = local_binary_path + ".tmp"
	var binary_path_unzipped = local_binary_path + "_unzipped"
	
	var url = wget_location
	var wget = "wget " + "-q --show-progress --output-document " + tmp_binary_path + ' "' + url + '"' + " 2>&1 "
	var sed = "sed -u 's/%.*//' | sed -u 's/.*K//' | sed -u 's/[^0-9]*//g'"
	var zenity = 'zenity --text="' + binary.capitalize() + '" --title="Downloading..." --progress --auto-close --auto-kill'
	
	if (!zip):
		var check = 'mv ' + tmp_binary_path + " " + local_binary_path
		var eval_string =  wget + " | " + sed + " | " + zenity + " && " + check
		OS.execute("eval", [eval_string], true)
	else:
		# Remove old files, these sometimes cause issues
		var remove = 'rm -r ' + tmp_binary_path + ' ' + binary_path_unzipped
		var unzip = 'unzip ' + tmp_binary_path + ' -d ' + binary_path_unzipped
		var ln = 'ln -sf ' + binary_path_unzipped + '/' + relative_run_path + ' ' + local_binary_path
		var eval_string =  wget + " | " + sed + " | " + zenity + " && " + unzip + " && " + ln
		
		OS.execute("eval", [remove], true)
		OS.execute("eval", [eval_string], true)
	
	
	return ExternalBinary.new(local_binary_path)

# Tries to find a required binary, or install it if it isn't found
# binary: the name of the binary
# distribution_package_name: if not found, install using this package name
# wget_location: if distribution_package_name is empty, install using wget
# zip: true if the the wget downloaded file needs to be unzipped
# relative_run_path: the path to the executable (relative to zip file extraction)
static func find_required_binary(binary : String, distribution_package_name : String = "", wget_location : String = "", zip : bool = false, relative_run_path : String = ""):
	var project_path = ProjectSettings.globalize_path("res://")
	var local_binary_path = _get_local_binary_path(binary)
	
	var local_binary = File.new()
	var output = []
	
	
	if(local_binary.file_exists(local_binary_path)):
		# Was installed locally
		return ExternalBinary.new(local_binary_path)
	elif(OS.execute("which", [binary], true, output) == 0):
		# Was installed via distro package manager
		return ExternalBinary.new(output[0])
	else:
		#Not installed yet
		if distribution_package_name != "":
			
			#shell_open is non-blocking :(
			OS.execute("apturl", ["apt:" + distribution_package_name], true)
			#OS.shell_open("apt:" + distribution_package_name)
			assert(OS.execute("which", [binary], true, output) == 0, "Error, could not install required package: " + distribution_package_name)
			return ExternalBinary.new(output[0])
				
		elif wget_location != "":
			var exit_code = OS.execute("zenity", 
			["--title", "Install " + binary.capitalize() + "?",
			 "--ok-label", "Yes",
			 '--cancel-label', "No, I want to select it manually",
			 '--question',
			 "--text", binary.capitalize() + " was not found, would you like to install a local version?",
			 '--ellipsize'],
			true, output)
			
			if(exit_code == 0):
				#Download local
				return _wget_binary(binary, wget_location, zip, relative_run_path)
				
				
		# Select locally
		var file_selection_exit_code = OS.execute("eval", ['zenity --title ' + binary.capitalize() + ' --file-selection 2> /dev/null'], true, output)
		if(file_selection_exit_code == 0):
			OS.execute('ln', ['-sf', output[0].strip_edges(true,true), _get_local_binary_path(binary)], true)
			return ExternalBinary.new(_get_local_binary_path(binary))
			
	return
