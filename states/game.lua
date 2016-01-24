local Game = {
	gridRadius = 3,
	hexSize = 40
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

end

function Game:touchmoved(id, x, y, dx, dy)
	Game.hexagons:pointermoved(x, y, dx, dy)
end

function Game:mousemoved(x, y, dx, dy)
	if love.mouse.isDown(1) then
		Game.hexagons:pointermoved(x, y, dx, dy)
	end
end

function Game:mousereleased()
	Game.hexagons:pointerreleased()
end

return Game