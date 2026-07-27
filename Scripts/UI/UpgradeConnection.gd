extends Line2D

class_name UpgradeConnection

static func create(from: Vector2, to: Vector2) -> UpgradeConnection:
	var conn = UpgradeConnection.new()
	conn.name = "Connection"
	conn.width = 4
	conn.default_color = Color(0.35, 0.25, 0.15, 0.7)
	var mid := Vector2(from.x, (from.y + to.y) * 0.5)
	conn.points = [from, mid, Vector2(to.x, mid.y), to]
	return conn
