extends Node

var singletons = {}

func _get(property: StringName) -> Variant:
	return singletons.get(property)
	
func _set(property: StringName, value: Variant) -> bool:
	if singletons.has(property):
		push_warning("Singleton %s already registered in SingletonManager" % property)
		return false
	else:
		singletons.set(property, value)
		return true
