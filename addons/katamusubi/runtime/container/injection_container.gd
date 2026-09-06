extends RefCounted
class_name InjectionContainer

const ResolveEntry := preload("resolve_entry.gd")
const ResolveEntryCollection := preload("resolve_entry_collection.gd")

## 親スコープのコンテナです。ローカルで見つからない依存を親へ問い合わせ
var _parent: InjectionContainer

## 公開型ごとのローカル登録コレクション
var _entries: Dictionary[Script, ResolveEntryCollection] = {}

## 任意の親コンテナを指定してスコープを生成
func _init(parent: InjectionContainer) -> void:
	_parent = parent


## 登録情報をローカルスコープへ追加
func register(registration: ServiceRegistration) -> void:
	var validation_errors := registration.validate()
	if not validation_errors.is_empty():
		var errors := "\n".join(validation_errors)
		push_error("登録情報が不正です:\n%s" % errors)
		return

	if not _entries.has(registration.service_type):
		_entries[registration.service_type] = ResolveEntryCollection.new()

	var entries: ResolveEntryCollection = _entries[registration.service_type]

	if entries.has(registration.key):
		push_error(
			"登録が重複しています: 型=%s, id=%s" % [
				registration.service_name,
				_display_id(registration.key),
			]
		)
		return

	entries.register(registration.key, ResolveEntry.new(registration))


func resolve(
	service_type: Script,
	key: StringName,
) -> Variant:
	var entry: ResolveEntry = null

	if not key.is_empty():
		entry = find_resolve_entry(service_type, key)
	
	if entry == null:
		entry = find_resolve_entry(service_type, &"")

	if entry != null:
		return entry.resolve()

	push_error(
		"登録が見つかりません: 型=%s, id=%s" % [
			service_type.get_global_name(),
			_display_id(key),
		]
	)
	return null


func find_resolve_entry(
	service_type: Script,
	key: StringName,
) -> ResolveEntry:
	var extracted_entries: ResolveEntryCollection = _entries.get(service_type)

	if extracted_entries != null and extracted_entries.has(key):
		return extracted_entries.find(key)

	if _parent != null:
		return _parent.find_resolve_entry(service_type, key)

	return null


## Singleton参照とローカル登録を解放します。
func clear() -> void:
	for entries: ResolveEntryCollection in _entries.values():
		entries.clear()
	_entries.clear()
	_parent = null


## 空IDをログ上で判別しやすい文字列に変換
static func _display_id(id: StringName) -> String:
	return "<none>" if id.is_empty() else String(id)
