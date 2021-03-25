extends Node

# TODO: Change the defaultkey value (https://heroiclabs.com/docs/authentication/)
var _client: NakamaClient = Nakama.create_client("defaultkey","127.0.0.1",7350,"http")
var _authenticator := Authenticator.new(_client)
var _dev_tools := DevTools.new()


func login_async() -> int:
	var result: int = yield(_authenticator.authenticate_by_id_async(),"completed")
	if result == OK:
		print("Connection stablished with the server")
		_dev_tools.Logger.stamp("Connection stablished with the server")
	return result
