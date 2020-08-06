require "tilemap"
require "entities"
local heart = love.graphics.newImage("sprites/heart.png")
local bar = love.graphics.newImage("sprites/bar2.png")
local money = love.graphics.newImage("sprites/money.png")
local skull = love.graphics.newImage("sprites/skull.png")
local player = {}
local state = "menu"
local buttons = {}
local attacks = {}
local enemy = {}
local GUI_HEIGHT = 60
local font = love.graphics.newFont(20)
local shop_cards = {}
local shop_buttons = {}
local message = nil
local timer = nil

function love.load()
	love.window.setTitle("DungeonRush")
	player.health = 1
	local cards = require("tables/cards")
	table.insert(buttons, newButton(
		"Start Game",
		function()
			shop_cards = {}
			map = loadTiledMap("tables/fmap0")
			timer = 18000
			font = love.graphics.newFont("sprites/SDS_8x8.ttf", 10)
			love.window.setMode(map.width*map.tilewidth, map.height*map.tileheight + GUI_HEIGHT * 2)
			player.sprite = get_entity("player")
			player.pos = {1, 1}
			player.speed = 3
			player.cooldown = 0
			player.health = 10
			player.max_health = 10
			player.level = 1
			player.xp = 0
			player.xp_req = 10
			player.deck = {"Slap"}
			player.attacks = {"Slap"}
			player.coins = 0
			player.last = false
			player.now = false
			enemy.chance = 0
			enemy.flat = 80
			state = "map"
			local cards = require("tables/cards")
			for i, card in ipairs(cards) do
				card.cooldown = 0
			end
			for i=1, 4 do
				table.insert(shop_cards, love.math.random(1, #cards))
			end
		end))
	table.insert(buttons, newButton(
		"Exit",
		function()
			love.event.quit()
		end))

	table.insert(attacks, newButton(
		"Attack",
		function()
			enemy.health = enemy.health - 1
		end))

	table.insert(shop_buttons, newButton(
		"Refresh Shop",
		function()
			if player.coins >= 10 then
				count = #shop_cards
				for i = 1, count do
					shop_cards[i] = love.math.random(1, #cards)
				end
				player.coins = player.coins - 10
			else
				message = "You do not have enough coins."
			end
		end))
	table.insert(shop_buttons, newButton(
		"Sell Cards",
		function()
			state = "sell"
		end))
	table.insert(shop_buttons, newButton(
		"Exit",
		function()
			state = "map"
		end))
	table.insert(shop_buttons, newButton(
		"Buy Health",
		function()
			if player.health == player.max_health then
				message = "You are at max health."
				return
			end
			if player.coins >= 2 then
				player.health = player.health + 1
				player.coins = player.coins - 2
			else
				message = "You do not have enough coins."
			end
		end))

	character_list = {
		["player"] = 2,
		["boss"] = 120,
		["pirate"] = 4,
		["orc"] = 97,
		["ninja"] = 35,
		["archer"] = 27,
		["knight"] = 26,
		["viking"] = 90}

	characters = loadSprites("tables/characters")
end

function love.update(dt)
	if state == "map" then
		move_player()
		if love.keyboard.isDown("e") then
			state = "deck"
		end
		if enemy.chance > math.random(60, 100) then
			local enemies = require("tables/enemies")
			local possible = {}
			for i, unit in ipairs(enemies) do
				if map.level == unit.level then
					table.insert(possible, i)
				end
			end
			enemy = enemies[possible[love.math.random(1, #possible)]]
			enemy["health"] = enemy.max_health
			enemy.chance = 0
			state = "combat"
		end

	elseif state == "menu" then

	elseif state == "combat" then
		update_enemy()
		if enemy.health <= 0 then
			local cards = require("tables/cards")
			state = "map"
			for i, card in ipairs(cards) do
				card.cooldown = 0
			end
			player.xp = player.xp + enemy.xp
			player.coins = player.coins + enemy.coins
			if player.xp >= player.xp_req then
				player.health = player.health + player.level
				player.max_health = player.max_health + player.level
				player.level = player.level + 1
				player.xp = player.xp - player.xp_req
				player.xp_req = player.level * 10
				enemy = {}
				enemy.chance = 0
			end
		end
	elseif state == "shop" then
	elseif state == "boss" then
		update_enemy()
		if enemy.health <= 0 then
			state = "menu"
			font = love.graphics.newFont(20)
			message = "You Win!"
		end
	end
	if state ~= "menu" then
		if timer > 0 then
			timer = timer - 1
		elseif timer == 0 and state ~= "boss"then
			local enemies = require("tables/enemies")
			for i, unit in ipairs(enemies) do
				if unit.name == "boss" then
					enemy = unit
				end
			end
			enemy["health"] = enemy.max_health
			enemy.chance = 0
			state = "boss"
		end
		if love.keyboard.isDown("escape") then
			state = "menu"
			font = love.graphics.newFont(20)
		end
		if player.health <= 0 then
			state = "menu"
			player.health = 1
			font = love.graphics.newFont(20)
			message = "You died at the hands of "..enemy.name.."."
		end
	end
end

function love.draw()
	if message ~= nil then
		draw_message()
	elseif state == "menu" then
		draw_menu()
	elseif state == "map" then
		draw_bar()
		map:draw_map()
		characters:draw_sprite(player.pos, get_entity(player.sprite))
	elseif state == "combat" then
		draw_combat()
	elseif state == "shop" then
		draw_shop()
		draw_bar()
	elseif state == "sell" or state == "deck" then
		draw_deck()
	elseif state == "boss" then
		draw_combat()
	end
end


function check_collision(entity, pos)
	local x = pos[1] + entity.pos[1]
	local y = pos[2] + entity.pos[2]
	local passable = false
	for i, layer in ipairs(map.layers) do
		if layer.type == "tilelayer" then
			local tile = map.layers[i].data[(x + y * map.width) + 1]
			for i, tileset in ipairs(map.tilesets) do
				if tile < map.first[i] then
					if not tileset.properties["Passable"] then
						return false
					else
						passable = true
						break
					end
				end
			end
		end
	end
	return passable
end


function check_interation(entity)
	local objects = nil
	for i, layer in next, map.layers do
		if layer.type == "objectgroup" then
			objects = layer.objects
		end
	end
	for i, object in next, objects do
		if entity.pos[1] == object.x/object.width and entity.pos[2] == object.y/object.height - 1 then
			return object.properties
		end
	end
end


function newButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false
	}
end


function get_entity(name)
	if character_list[name] ~= nil then 
		return character_list[name]
	end
	return 1
end


function get_card(name)
	local cards = require("tables/cards")
	for i, card in ipairs(cards) do
		if card.name == name then
			return i
		end
	end
end


function move_player()
	if player.cooldown == 0 then
		local temp = {0, 0}
		if love.keyboard.isDown("w") then
			temp[2] = temp[2] - 1
		elseif love.keyboard.isDown("s") then
			temp[2] = temp[2] + 1
		end
		if love.keyboard.isDown("a") then
			temp[1] = temp[1] - 1
		elseif love.keyboard.isDown("d") then
			temp[1] = temp[1] + 1
		end
		if temp[1] ~= 0 or temp[2] ~= 0 then
			if check_collision(player, temp) then
				enemy.chance = enemy.chance + 1
				player.pos[1], player.pos[2] = player.pos[1] + temp[1], player.pos[2] + temp[2]
				player.cooldown = player.speed
				interaction = check_interation(player)
				if interaction ~= nil then
					interact(interaction)
				end
			end
		end
	else
		player.cooldown = player.cooldown - 1
	end
end


function update_enemy()
	if enemy.cooldown == enemy.speed then
		player.health = player.health - enemy.damage
		enemy.cooldown = 0
	else
		enemy.cooldown = enemy.cooldown + 1
	end
end


function interact(interaction)
	local action = (interaction["action"])
	if action == "teleport" then
		map = loadTiledMap(interaction["map"])
		player.pos = {interaction["x"], interaction["y"]-1}
		love.window.setMode(map.width*map.tilewidth, map.height*map.tileheight + GUI_HEIGHT * 2)
	elseif action == "combat" then
		local enemies = require("tables/enemies")
		enemy = enemies[love.math.random(1, 2)]
		enemy["health"] = enemy.max_health
		state = "combat"
	elseif action == "shop" then

		state = "shop"
	end
end


function draw_menu()
	local BUTTON_HEIGHT = 50
	local ww = love.graphics.getWidth()
	local wh = love.graphics.getHeight()
	local button_width = ww * (1/3)
	local margin = 16
	local total_height = (BUTTON_HEIGHT + margin) * #buttons

	for i, button in ipairs(buttons) do
		button.last = button.now
		local bx = (ww * 0.5) - (button_width * 0.5)
		local by = (wh * 0.5) - (total_height * 0.5) + (BUTTON_HEIGHT + margin) * (i - 1)

		local mx, my = love.mouse.getPosition()
		local hot = mx > bx and mx < bx + button_width and 
					my > by and my < by + BUTTON_HEIGHT

		love.graphics.setColor(1, 1, 1, .6)
		if hot then
			love.graphics.setColor(1, 1, 1, 1)
		end
		button.now = love.mouse.isDown(1)
		if button.now and not button.last and hot then
			button.fn()
			break
		end

		love.graphics.rectangle(
			"fill",
			bx,
			by,
			button_width,
			BUTTON_HEIGHT)

		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf(
			button.text,
			font,
			bx,
			by,
			button_width,
			"center")
	end
end


function draw_bar()
	local ww = love.graphics.getWidth()
	local y = love.graphics.getHeight()-GUI_HEIGHT
	local text = love.graphics.newText(font, "EXP")
	local health = love.graphics.newText(font, player.health.."/"..player.max_health)
	local xp = love.graphics.newText(font, player.xp.."/"..player.xp_req)
	font = love.graphics.newFont("sprites/SDS_8x8.ttf", 15)
	local coins = love.graphics.newText(font, player.coins)
	local level = love.graphics.newText(font, map.level)
	font = love.graphics.newFont("sprites/SDS_8x8.ttf", 10)



	local text_height = text:getHeight()
	local text_width = text:getWidth()

	local bar_length = (love.graphics.getWidth() - GUI_HEIGHT - text_width) / 2

	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.rectangle("fill", 
							GUI_HEIGHT, 
							y + (GUI_HEIGHT/3), 
							player.health/player.max_health * bar_length, 
							GUI_HEIGHT / 3)


	love.graphics.setColor(0, 1, 0, 0.8)
	love.graphics.rectangle("fill", 
							bar_length + GUI_HEIGHT + text_width, 
							y + (GUI_HEIGHT/3), 
							player.xp / player.xp_req * bar_length, 
							GUI_HEIGHT / 3)

	love.graphics.setColor(1, 1, 1, 1)

	local quad = love.graphics.newQuad(0, 0, GUI_HEIGHT, GUI_HEIGHT, GUI_HEIGHT, GUI_HEIGHT)
	love.graphics.draw(heart, quad, 0, y)
	love.graphics.draw(money, quad, 0, y - GUI_HEIGHT)
	love.graphics.draw(skull, quad, ww - GUI_HEIGHT - level:getWidth() * 2, y - GUI_HEIGHT)

	local quad = love.graphics.newQuad(0, 0, bar_length, GUI_HEIGHT, bar_length, GUI_HEIGHT)
	love.graphics.draw(bar, quad, GUI_HEIGHT, y)
	love.graphics.draw(bar, quad, bar_length + GUI_HEIGHT + text_width, y)

	love.graphics.draw(text, 
					   bar_length + GUI_HEIGHT, 
					   y + (GUI_HEIGHT - text_height) / 2)

	love.graphics.draw(health, 
					   GUI_HEIGHT + bar_length / 2 - health:getWidth() / 2, 
					   y + (GUI_HEIGHT - text_height) / 2)

	love.graphics.draw(xp, 
					   GUI_HEIGHT + bar_length * 3 / 2 - xp:getWidth() / 2 + text_width, 
					   y + (GUI_HEIGHT - text_height) / 2)
	love.graphics.draw(coins, 
					   GUI_HEIGHT, 
					   y - GUI_HEIGHT + (GUI_HEIGHT - text_height) / 2)
	love.graphics.draw(level, 
					   ww - level:getWidth() * 2, 
					   y - GUI_HEIGHT + (GUI_HEIGHT - text_height) / 2)
	local time_font = love.graphics.newFont("sprites/SDS_8x8.ttf", 20)
	local raw_time = timer / 3600
	local minutes = math.floor(raw_time)
	local seconds = math.floor(60 * (raw_time - minutes))
	local time = nil
	if seconds > 9 then
		time = minutes..":"..seconds
	else
		time = minutes..":0"..seconds
	end
		
	local box = 100
	love.graphics.printf(time, time_font, ww / 2 - box / 2, y - GUI_HEIGHT + 20, box, "center")
end


function draw_combat()
	local BUTTON_HEIGHT = 50
	local player_heart = heart
	local player_health = love.graphics.newText(font, player.health.."/"..player.max_health)
	local enemy_health = love.graphics.newText(font, enemy.health.."/"..enemy.max_health)

	local ww = love.graphics.getWidth()
	local wh = love.graphics.getHeight()
	local scale = 5
	local x_offset = (ww - 2 * scale * characters.tilewidth) / 4
	local y = 10
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(characters.images[1], 
					   characters.quads[player.sprite],
					   ww / 2 - x_offset,
					   y,
					   0,
					   -scale,
					   scale)
	love.graphics.draw(characters.images[1], 
					   characters.quads[get_entity(enemy.name)],
					   ww / 2 + x_offset,
					   y,
					   0,
					   scale,
					   scale)

	y = y + scale * characters.tilewidth 
	local bar_length = scale * characters.tilewidth


	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.rectangle("fill", 
							x_offset, 
							y + (GUI_HEIGHT/3), 
							player.health/player.max_health * bar_length, 
							GUI_HEIGHT / 3)

	love.graphics.rectangle("fill", 
							ww / 2 + x_offset, 
							y + (GUI_HEIGHT/3), 
							enemy.health / enemy.max_health * bar_length, 
							GUI_HEIGHT / 3)

	text_height = player_health:getHeight()
	love.graphics.setColor(1, 1, 1, 1)


	local quad = love.graphics.newQuad(0, 0, bar_length, GUI_HEIGHT, bar_length, GUI_HEIGHT)
	love.graphics.draw(bar, quad, x_offset, y)
	love.graphics.draw(bar, quad, ww / 2 + x_offset, y)

	love.graphics.draw(player_health, 
					   x_offset + bar_length / 2 - player_health:getWidth() / 2, 
					   y + (GUI_HEIGHT - text_height) / 2)

	love.graphics.draw(enemy_health, 
					   ww / 2 + x_offset + bar_length / 2 - enemy_health:getWidth() / 2, 
					   y + (GUI_HEIGHT - text_height) / 2)


	local cards = require("tables/cards")

	local card = nil
	player.last = player.now
	for i, attack in ipairs(player.attacks) do

		for j, k in ipairs(cards) do
			if tostring(k.name) == tostring(attack) then
				card = k
				break
			end
		end


		love.graphics.setColor(1, 1, 1, .6)

		local mx, my = love.mouse.getPosition()
		local increase = 0

		if i <= 2 then
			y = cards.margin + wh / 3
		else
			y = cards.margin * 2 + cards.height + wh / 3
		end
		if i % 2 == 0 then
			x = ww - cards.margin - cards.width
		else
			x = cards.margin
		end

		local hot = mx > x and mx < x + cards.width and
					my > y and my < y + cards.height

		if card.cooldown ~= 0 then
			hot = false
			card.cooldown = card.cooldown - 1
			love.graphics.setColor(1, 1, 1, 1)
			local new_height = cards.height * card.cooldown / card.speed
			love.graphics.rectangle("fill", x, y + (cards.height - new_height), cards.width, new_height)
			love.graphics.setColor(1, 1, 1, .6)
		end

		if hot then
			increase = 5
		end

		love.graphics.rectangle("fill", x - increase, y - increase, cards.width + increase * 2, cards.height + increase * 2)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf(card.name, font, x, y + 1, cards.width, "center")
		love.graphics.printf(card.text, font, x, y + cards.margin, cards.width, "center")

		player.now = love.mouse.isDown(1)

		if hot and player.now and not player.last then
			enemy.health = enemy.health - card.damage
			card.cooldown = card.speed
		end
		
	end
end


function draw_shop()
	local cards = require("tables/cards")
	local ww = love.graphics.getWidth()
	local wh = love.graphics.getHeight()
	player.last = player.now
	for i, card in ipairs(shop_cards) do
		if card ~= 0 then
			love.graphics.setColor(1, 1, 1, .6)
			local increase = 0
			local mx, my = love.mouse.getPosition()

			local y = nil
			local x = nil
			if i <= 2 then
				y = cards.margin
			else
				y = cards.margin * 2 + cards.height
			end
			if i % 2 == 0 then
				x = ww - cards.margin - cards.width
			else
				x = cards.margin
			end
			local hot = mx > x and mx < x + cards.width and
						my > y and my < y + cards.height
			if hot then
				increase = 5
			end
			

			love.graphics.rectangle("fill", x - increase, y - increase, cards.width + increase * 2, cards.height + increase * 2)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf(cards[card].name, font, x, y + 10, cards.width, "center")
			love.graphics.printf(cards[card].text, font, x, y + cards.margin, cards.width, "center")
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.printf(cards[card].cost.." Coins", font, x, y + cards.height + 10, cards.width, "center")

			player.now = love.mouse.isDown(1)

			if player.now and not player.last and hot then
				for i, pcard in ipairs(player.deck) do
					if pcard == cards[card].name then
						message = "You may only have one of each card."
						return
					end
				end
				if player.coins < cards[card].cost then
					message = "You do not have enough coins to purchase this."
					return
				end
				shop_cards[i] = 0
				player.coins = player.coins - cards[card].cost
				table.insert(player.deck, cards[card].name)
			end
		end
	end

	local BUTTON_HEIGHT = 60
	local button_width = ww * (1 / (#shop_buttons))
	local margin = 16
	local y = wh - GUI_HEIGHT * 2 - BUTTON_HEIGHT

	for i, button in ipairs(shop_buttons) do
		button.last = button.now
		local bx = button_width * (i - 1)
		local by = y

		local mx, my = love.mouse.getPosition()
		local hot = mx > bx and mx < bx + button_width and 
					my > by and my < by + BUTTON_HEIGHT

		love.graphics.setColor(1, 1, 1, .6)
		if hot then
			love.graphics.setColor(1, 1, 1, 1)
		end
		button.now = love.mouse.isDown(1)
		if button.now and not button.last and hot then
			button.fn()
			break
		end

		love.graphics.rectangle(
			"fill",
			bx,
			by,
			button_width,
			BUTTON_HEIGHT)

		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf(
			button.text,
			font,
			bx,
			by + BUTTON_HEIGHT / 2,
			button_width,
			"center")
	end
	love.graphics.print("10 Coins", font, 20, wh - GUI_HEIGHT * 2 - 10)
	love.graphics.print("2 Coins", font, ww - 100, wh - GUI_HEIGHT * 2 - 10)
end


function draw_deck()
	local cards = require("tables/cards")
	local place = nil
	local ww = love.graphics.getWidth()
	local wh = love.graphics.getHeight()
	local y = nil
	local x = nil

	player.last = player.now
	for i, card in ipairs(player.deck) do
		local selected = false
		local index = nil

		love.graphics.setColor(1, 1, 1, 0.6)
		place = i % 3
		if place == 0 then
			x = ww - cards.width - cards.margin
		elseif place == 1 then 
			x = cards.margin
			y = (cards.height * ((i - 1) / 3)) + (cards.margin * (i / 3))
		elseif place == 2 then 
			x = (ww / 2) - (cards.width / 2)
		end
		for i, attack in ipairs(player.attacks) do
			if attack == card then
				love.graphics.setColor(1, 1, 1, 1)
				index = i
				selected = true
			end
		end

		local mx, my = love.mouse.getPosition()
		local increase = 0
		local hot = mx > x and mx < x + cards.width and
					my > y and my < y + cards.height
		if hot then
			increase = 5
		end
		
		local number = get_card(card)

		love.graphics.rectangle("fill", x - increase, y - increase, cards.width + increase * 2, cards.height + increase * 2)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf(cards[number].name, font, x, y + 10, cards.width, "center")
		love.graphics.printf(cards[number].text, font, x, y + cards.margin, cards.width, "center")


		player.now = love.mouse.isDown(1)

		if player.now and hot and not player.last then
			player.last = true
			player.coins = player.coins + cards[number].value
			if state == "sell" then
				table.remove(player.deck, i)
				if selected then
					table.remove(player.attacks, index)
				end
			else
				if selected then
					table.remove(player.attacks, index)
				elseif #player.attacks == 4 then 
					message = "You can only select 4 attacks."
					return
				else
					table.insert(player.attacks, card)
				end
			end
		end
	end

	love.graphics.setColor(1, 1, 1, 0.6)
	local width = 100
	local height = 50
	local x = (ww / 2) - (width / 2)
	local y = wh - height - 10

	
	local mx, my = love.mouse.getPosition()
	player.last = false

	local hot = mx > x and mx < x + width and
				my > y and my < y + height

	if hot then
		love.graphics.setColor(1, 1, 1, 1)
	end
	love.graphics.rectangle("fill", 
							x,
							y,
							width,
							height)

	player.now = love.mouse.isDown(1)
	if player.now and not player.last and hot then
		if state == "sell" then
			state = "shop"
		else
			state = "map"
		end
	end
	love.graphics.setColor(0, 0 , 0, 1)
	love.graphics.printf("Back", font, x, y + height / 2, width, "center")
end


function draw_message()
	local ww = love.graphics.getWidth()
	local wh = love.graphics.getHeight()
	local width = 300
	local height = 200
	local x = (ww / 2) - (width / 2)
	local y = (wh / 2) - height

	love.graphics.setColor(0.8, 0.8, 1, 0.7)
	love.graphics.rectangle("fill", x, y, width, height)

	local font = love.graphics.newFont("sprites/SDS_8x8.ttf", 25)
	love.graphics.setColor(0, 0 , 0, 1)
	love.graphics.printf(message, font, x, y + height / 2 - string.len(message), width, "center")
	love.graphics.setColor(1, 1, 1, 0.6)

	width = 100
	height = 30
	x = (ww / 2) - (width / 2)
	y = wh - height * 2
	local mx, my = love.mouse.getPosition()
	player.last = player.now

	local hot = mx > x and mx < x + width and
				my > y and my < y + height

	if hot then
		love.graphics.setColor(1, 1, 1, 1)
	end

	player.now = love.mouse.isDown(1)
	if player.now and not player.last and hot then
		message = nil
	end

	local font = love.graphics.newFont("sprites/SDS_8x8.ttf", 15)
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor(0, 0 , 0, 1)
	love.graphics.printf("Clear", font, x, y + height / 2, width, "center")
end

