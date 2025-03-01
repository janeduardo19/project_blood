extends Node


# Battle-related events
signal battle_won

# Map-related events
signal map_exited(room: Room)

# Shop-related events
signal shop_exited

# Campfire-related events
signal campfire_exited

# Battle reward-related events
signal battle_reward_exited

# Treasure room-related events
signal treasure_room_exited
