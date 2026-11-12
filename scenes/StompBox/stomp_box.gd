class_name StompBox
extends Area2D

var _hit:bool=false

var _is_hit:bool:
	get: return _hit

func trigger()->void:
	if _hit: return
	_hit = true# Replace with function body.
