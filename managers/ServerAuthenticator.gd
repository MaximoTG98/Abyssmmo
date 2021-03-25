# Sub-Manager encargado de iniciar sesion y guardar/leer el token
class_name Authenticator
extends Reference

var session : NakamaSession
var _client : NakamaClient
var _dev_tools := DevTools.new()


# Funcion constructora, cuando se instancia este script, es OBLIGATORIO dar una sesion y un client
func _init(client:NakamaClient) -> void:
	_client = client


# Inicia sesion a traves del ID del dispositivo.
# Intenta primero restaurar con el token guardado. Y en el caso de que no valga
# Creará una nueva sesion y guardará el token
func authenticate_by_id_async() -> int:
	var device_id = OS.get_unique_id()
	
	# Leer el token y verificar que existe, que es valido y que no haya expirado
	var token := TokenFileWorker.token_read_local()
	
	# Restaura la sesion a partir del token(si existe)
	if token != "":
		var new_session:NakamaSession = _client.restore_session(token)
		if new_session.valid and not new_session.expired:
				session = new_session
				yield(Engine.get_main_loop(), "idle_frame") # Si lo quito no funciona, no sé.
				print("Succesfully authenticated with TOKEN:\n %s" % new_session)
				_dev_tools.Logger.stamp("Succesfully authenticated with TOKEN:\n %s" % new_session,OK)
				return OK
	
# Si la sesion anterior no esta disponible, ha expirado o es invalida
	var new_session:NakamaSession = yield(_client.authenticate_device_async(device_id),"completed")
	if new_session.is_exception():
					print("Unable to auth:\n %s" % new_session.get_exception())
					_dev_tools.Logger.stamp("Unable to auth:\n %s" % new_session.get_exception(),FAILED)
					return FAILED
	else:
			session = new_session
			TokenFileWorker.token_save_local(session.token)
			print("Succesfully authenticated without TOKEN:\n %s" % new_session)
			_dev_tools.Logger.stamp("Succesfully authenticated with TOKEN")
			return OK


# Clase ayudante para guardar y leer el token con contraseña
class TokenFileWorker:
	const AUTH_PATH:String = "user://saves.dat"
	var _dev_tools: DevTools
	
	# Abre el archivo utilizando una contraseña que es especifica de cada dispositivo
	# Guarda el token en auth_path
	static func token_save_local(token:String)-> void:
		var device_id := OS.get_unique_id()
		var token_file := File.new()

		var err = token_file.open_encrypted_with_pass(AUTH_PATH,File.WRITE,device_id)
		if err == OK:
			token_file.store_line(token)
			token_file.close()
			print("Succesfully saved TOKEN in path")
		else:
			print("Unable to find/read and save TOKEN")
	
	# Abre el token localmente con contraseña y lo devuelve
	static func token_read_local()-> String:
		var device_id := OS.get_unique_id()
		var token_file := File.new()
		var err := token_file.open_encrypted_with_pass(AUTH_PATH,File.READ,device_id)
	
		if err == OK:
			var saved_token := token_file.get_line()
			token_file.close()
			print("Succesful read TOKEN")
			return saved_token
		return ""
