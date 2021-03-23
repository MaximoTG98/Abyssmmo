class_name DevTools
extends Reference

class Logger:
	
	const LOG_PATH:String = "user://Logs/log.txt"
	
	# WAITING: Añadir que se limpie el log.
	static func clear_log() -> void:
		var dir = Directory.new()
		dir.remove(ProjectSettings.globalize_path(LOG_PATH))
	
	# TODO: Hacer que lo haga en idle time y no de golpe
	# Funcion print, a traves de un mensaje y unos parametros.
	static func stamp(message:String, stamp_type:int = 0, add_time:bool = true,keep_log:bool = true) -> void:
		
		if OS.is_debug_build() or keep_log == false:
			pass
		
		var prefix: String = ""
		var stamp_prefix: String = ""
		
		if add_time == true:
			prefix = _get_time() + prefix
		
		# Selecciona el prefijo siguiendo @GlobalScope
		match stamp_type:
			0:
				stamp_prefix = "[OK]"
			1:
				stamp_prefix = "[FAILED]"
			45:
				stamp_prefix = "[SKIPPED]"
			46:
				stamp_prefix = "[HELP]"
			47:
				stamp_prefix = "[BUG]"
			_:
				stamp_prefix = " · "
		
		var to_log:String = prefix + stamp_prefix + " " + message
		
		var log_file := File.new()
		log_file.open(LOG_PATH,File.READ)
		var last_log:String = log_file.get_as_text()
		log_file.close()
		
		log_file.open(LOG_PATH,File.WRITE)
		log_file.seek_end()
		log_file.store_line(last_log + to_log)
		log_file.close()
		
	
	static func _get_time() -> String:
		return "[" + str(OS.get_time().hour) + ":" + str(OS.get_time().minute) + ":" + str(OS.get_time().second) + "]"
		
	# Que en cada inicio del juego, el logger cree un .txt con todos los prints solo en modo dev.
	# Habilitar un modo de añadir tags a cada print y que en los archivos esten ordenados por tags
	# Opcion de abrir el archivo cada vez que se cierre el juego.
	
