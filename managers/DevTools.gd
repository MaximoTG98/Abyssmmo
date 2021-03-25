class_name DevTools
extends Reference

	# Que en cada inicio del juego, el logger cree un .txt con todos los prints solo en modo dev.
	# Habilitar un modo de añadir tags a cada print y que en los archivos esten ordenados por tags
	# Opcion de abrir el archivo cada vez que se cierre el juego.
	
class Logger:
	# STARTUP: Limpiar el log diario?
	# Borra el archivo del último log. No sé si es útil
	static func clear_log() -> void:
		var LOG_PATH:String = _get_path()
		var dir = Directory.new()
		dir.remove(ProjectSettings.globalize_path(LOG_PATH))
	
	# TODO: Hacer que lo haga en idle time y no de golpe | Necesita rendimiento
	# Funcion print, a traves de un mensaje y unos parametros.
	static func stamp(message:String, stamp_type:int = 0, add_time:bool = true,keep_log:bool = true) -> void:
		
		#TODO: Analizar esto
		yield(Engine.get_main_loop(), "idle_frame")
		
		# TODO: Darle sentido a esto
		if OS.is_debug_build() or keep_log == false:
			pass
		
		
		var LOG_PATH:String = _get_path()
		var prefix: String = ""
		var stamp_prefix: String = ""
		
		#Añade el tiempo al prefijo
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
				stamp_prefix = " [ERROR CODE NOT FOUND] "
		
		# Lo que estaba guardado + lo que se tiene que guardar
		var to_log:String = prefix + stamp_prefix + " " + message
		var last_log:String
		
		var log_file := File.new()
		
		# Se encarga de poner a last_log el texto que tenia anteriormente
		var file_Err_read := log_file.open(LOG_PATH,File.READ)
		if file_Err_read != OK:
			push_error("NO SE HA PODIDO ENVIAR UN STAMP, ARCHIVO IMPOSIBLE DE LEER:" + str(file_Err_read))
		else:
			last_log = log_file.get_as_text()
			log_file.close()
		
		# Se encarga de escribir la nueva linea del stamp solicitado
		var file_Err_write := log_file.open(LOG_PATH,File.WRITE)
		if file_Err_write != OK:
			push_error("NO SE HA PODIDO ENVIAR UN STAMP, ARCHIVO IMPOSIBLE DE ESCRIBIR" + str(file_Err_write))
		else:
			log_file.seek_end()
			log_file.store_line(last_log + to_log)
			log_file.close()
	
	# Devuelve la fecha actual, de siguiendo el modelo 2020-03-25 como String
	static func _get_path() -> String:
		return "user://logs/" + str(OS.get_date().year) +"-"+ str(OS.get_date().month) +"-"+ str(OS.get_date().day) + ".log"
	# Devuelve la hora actual, siguiendo el modelo [14:44:5] como String
	static func _get_time() -> String:
		return "[" + str(OS.get_time().hour) + ":" + str(OS.get_time().minute) + ":" + str(OS.get_time().second) + "]"
		

	
