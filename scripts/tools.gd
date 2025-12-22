extends Object
class_name Tools

static func get_time(_total_seconds:int)->String:
	var t:String
	if get_hours(_total_seconds) > 0:
		t = "{0}:{1}:{2}".format([get_hours_str(_total_seconds), get_minutes_str(_total_seconds), get_seconds_str(_total_seconds)])
	else:
		t = "{0}:{1}".format([get_minutes_str(_total_seconds), get_seconds_str(_total_seconds)])
	return t

static func get_minutes(_total_seconds:int) -> int:
	@warning_ignore("integer_division")
	return (_total_seconds % 3600) / 60

static func get_minutes_str(_total_seconds:int) -> String:
	var m:= get_minutes(_total_seconds)
	if m < 10:
		return "0" + str(m)
	else:
		return str(m)

static func get_hours(_total_seconds:int) -> int:
	@warning_ignore("integer_division")
	return _total_seconds / 3600

static func get_hours_str(_total_seconds:int) -> String:
	var h := get_hours(_total_seconds)
	if h < 10:
		return "0" + str(h)
	else:
		return str(h)

static func get_seconds(_total_seconds:int)->int:
	return _total_seconds % 60

static func get_seconds_str(_total_seconds:int)->String:
	var s:= get_seconds(_total_seconds)
	if s < 10:
		return "0" + str(s)
	else:
		return str(s)
