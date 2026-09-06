extends RefCounted
class_name ResolveEntryCollection

const ResolveEntry := preload("resolve_entry.gd")

var _entries: Dictionary[StringName, ResolveEntry] = {}


## 指定したキーの登録が存在するか調べます。
func has(key: StringName) -> bool:
	return _entries.has(key)


## 指定したキーで解決エントリを登録します。
func register(key: StringName, entry: ResolveEntry) -> void:
	_entries[key] = entry


## 指定したキーに対応する解決エントリを返します。
func find(key: StringName) -> ResolveEntry:
	return _entries.get(key)


## 全エントリの参照を解放し、登録を空にします。
func clear() -> void:
	for entry: ResolveEntry in _entries.values():
		entry.clear()
	_entries.clear()
