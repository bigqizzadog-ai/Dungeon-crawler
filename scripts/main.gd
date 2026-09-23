extends Node2D
## Prototype v0.2: keyboard and touch controls.
## All three classes have adjacent attacks until ranged combat is implemented.

const GRID := 10
const TILE := 48
const START := Vector2(120, 155)
const CLASSES := [
    {"name": "Fighter", "hp": 14, "attack": 4},
    {"name": "Archer", "hp": 10, "attack": 3},
    {"name": "Mage", "hp": 8, "attack": 5}
]

var chosen := 0
var player := Vector2i(1, 1)
var enemy := Vector2i(7, 7)
var health := 14
var enemy_health := 10
var status := ""
var info: Label
var message: Label

func _ready() -> void:
    info = Label.new()
    info.position = Vector2(24, 8)
    info.add_theme_font_size_override("font_size", 21)
    add_child(info)

    message = Label.new()
    message.position = Vector2(24, 42)
    message.add_theme_font_size_override("font_size", 17)
    add_child(message)

    make_button("Fighter", Vector2(35, 91), Vector2(190, 48), reset.bind(0))
    make_button("Archer", Vector2(265, 91), Vector2(190, 48), reset.bind(1))
    make_button("Mage", Vector2(495, 91), Vector2(190, 48), reset.bind(2))
    make_button("UP", Vector2(143, 657), Vector2(86, 64), move.bind(Vector2i(0, -1)))
    make_button("LEFT", Vector2(47, 728), Vector2(86, 64), move.bind(Vector2i(-1, 0)))
    make_button("DOWN", Vector2(143, 728), Vector2(86, 64), move.bind(Vector2i(0, 1)))
    make_button("RIGHT", Vector2(239, 728), Vector2(86, 64), move.bind(Vector2i(1, 0)))
    make_button("ATTACK", Vector2(456, 696), Vector2(215, 88), attack)
    make_button("RESTART", Vector2(456, 804), Vector2(215, 54), restart)
    reset(0)

func make_button(label: String, pos: Vector2, dimensions: Vector2, callback: Callable) -> void:
    var button := Button.new()
    button.text = label
    button.position = pos
    button.size = dimensions
    button.add_theme_font_size_override("font_size", 21)
    button.pressed.connect(callback)
    add_child(button)

func restart() -> void:
    reset(chosen)

func reset(character: int) -> void:
    chosen = character
    player = Vector2i(1, 1)
    enemy = Vector2i(7, 7)
    health = CLASSES[chosen]["hp"]
    enemy_health = 10
    status = "Find the red enemy. Move next to it, then attack."
    refresh()

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_1: reset(0)
        KEY_2: reset(1)
        KEY_3: reset(2)
        KEY_R: restart()
        KEY_W, KEY_UP: move(Vector2i(0, -1))
        KEY_A, KEY_LEFT: move(Vector2i(-1, 0))
        KEY_S, KEY_DOWN: move(Vector2i(0, 1))
        KEY_D, KEY_RIGHT: move(Vector2i(1, 0))
        KEY_SPACE: attack()

func move(direction: Vector2i) -> void:
    if health <= 0 or enemy_health <= 0:
        return
    var next := player + direction
    if next.x <= 0 or next.x >= GRID - 1 or next.y <= 0 or next.y >= GRID - 1:
        status = "A wall blocks your path."
    elif next == enemy:
        status = "Enemy ahead: press ATTACK."
    else:
        player = next
        status = "Exploring..."
    refresh()

func attack() -> void:
    if health <= 0 or enemy_health <= 0:
        return
    var distance: int = abs(player.x - enemy.x) + abs(player.y - enemy.y)
    if distance != 1:
        status = "Move beside the enemy to attack."
    else:
        enemy_health -= CLASSES[chosen]["attack"]
        if enemy_health <= 0:
            status = "Victory! Tap RESTART to play again."
        else:
            health -= 2
            status = "Enemy hits back for 2 HP." if health > 0 else "Defeated! Tap RESTART."
    refresh()

func refresh() -> void:
    info.text = "%s | HP: %d | Enemy HP: %d" % [
        CLASSES[chosen]["name"], health, max(enemy_health, 0)
    ]
    message.text = status
    queue_redraw()

func _draw() -> void:
    for y in range(GRID):
        for x in range(GRID):
            var corner := START + Vector2(x * TILE, y * TILE)
            var boundary := x == 0 or y == 0 or x == GRID - 1 or y == GRID - 1
            var color := Color(0.18, 0.20, 0.24) if boundary else Color(0.37, 0.39, 0.44)
            draw_rect(Rect2(corner, Vector2(TILE - 2, TILE - 2)), color)
    if enemy_health > 0:
        draw_circle(START + Vector2(enemy * TILE) + Vector2(TILE / 2, TILE / 2), 15, Color(0.95, 0.3, 0.27))
    if health > 0:
        draw_circle(START + Vector2(player * TILE) + Vector2(TILE / 2, TILE / 2), 15, Color(0.29, 0.87, 0.51))
