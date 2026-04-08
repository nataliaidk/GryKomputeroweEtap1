extends Node
 
var elapsed: float = 0.0
var running: bool  = false
 
func start() -> void:
	elapsed = 0.0
	running = true
 
func stop() -> void:
	running = false
 
func _process(delta: float) -> void:
	if running:
		elapsed += delta
 
func seconds() -> float:
	return elapsed
