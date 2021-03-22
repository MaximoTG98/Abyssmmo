extends Node

func _ready() -> void:
	var test = ServerConnection.login_async()
	print(test)
