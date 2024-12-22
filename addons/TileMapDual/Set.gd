## Real sets don't exist yet
## https://github.com/godotengine/godot/pull/94399
class_name Set
extends Resource

var data: Dictionary = {}

func _init(initial_data: Variant = []) -> void:
	union_in_place(initial_data)

func has(item: Variant) -> bool:
	return item in data

## Returns true if the item was not previously in the Set.
func insert(item: Variant) -> bool:
	var out := not has(item)
	data[item] = null
	return out

## Returns true if the item was previously in the Set.
func remove(item: Variant) -> bool:
	return data.erase(item)

func clear() -> void:
	data = {}

## Merges an Array's items or Dict's keys into the Set.
func union_in_place(other: Variant):
	for item in other:
		insert(item)

func union(other: Set) -> Set:
	var out = self.duplicate()
	out.union_in_place(other.data)
	return out

## Removes an Array's items or Dict's keys from the Set.
func diff_in_place(other: Variant):
	for item in other:
		remove(item)

func diff(other: Set) -> Set:
	var out = self.duplicate()
	out.diff_in_place(other.data)
	return out

## Given an Array or Dict, <read the code>
func xor_in_place(other: Variant):
	for item in other:
		if has(item):
			remove(item)
		else:
			insert(item)

func xor(other: Set) -> Set:
	var out = self.duplicate()
	out.xor_in_place(other.data)
	return out
