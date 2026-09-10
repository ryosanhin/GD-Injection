extends Node

const DerivedService := preload("res://tests/fixtures/services/derived_service.gd")

var injection_count := 0
var received_service: TestBaseService


func get_inject_type_overrides() -> Dictionary[StringName, Script]:
	return {&"overridden_service": DerivedService}


func inject_dependency(overridden_service: TestBaseService) -> void:
	injection_count += 1
	received_service = overridden_service
