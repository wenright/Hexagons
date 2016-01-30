local Game = {
	gridRadius = 3,
	hexSize = 50,
	selectedHexagon = nil
}

function Game:init()
	print('Creating hexagons...')
	Game.hexagons = Entities(Hexagon)

	for x = -Game.gridRadius, Game.gridRadius do
		for y = -Game.gridRadius, Game.gridRadius  do
			local z = -x + -y
			if math.abs(x) <= Game.gridRadius and math.abs(y) <= Game.gridRadius and math.abs(z) <= Game.gridRadius then
				Game.hexagons:add(x, y, z)
			end
		end
	end

	love.graphics.setBackgroundColor(52,56,62)

	print('Game loaded')
end

function Game:update(dt)
	Game.hexagons:update(dtZZ)
end

function Game:draw()
	Camera:attach()

	Game.hexagons:draw()

	Camera:detach()
end

function Game:touchpressed(id, x, y)
	Game.hexagons:pointerdown(x, y)
end

function Game:mousepressed(x, y)
	Game.hexagons:pointerdown(x, y)
end

function Game:touchmoved(id, x, y, dx, dy)
	Game.hexagons:pointermoved(x, y, dx, dy)
end

function Game:mousemoved(x, y, dx, dy)
	if love.mouse.isDown(1) then
		Game.hexagons:pointermoved(x, y, dx, dy)
	end
end

function Game:touchreleased(id, x, y)
	Game.hexagons:pointerreleased(x, y)
	Game.selectedHexagon = nil
end

function Game:mousereleased(x, y)
	Game.hexagons:pointerreleased(x, y)
	Game.selectedHexagon = nil
end

return Game