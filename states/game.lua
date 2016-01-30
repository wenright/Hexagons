local Game = {
	gridRadius = 3,
	hexSize = 50,
	selectedHexagon = nil,
	pointerStart = {x = 0, y = 0}
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
	Game.hexagons:update(dt)
end

function Game:draw()
	Camera:attach()

	Game.hexagons:draw()

	Camera:detach()

	-- love.graphics.setColor(255, 255, 255, 100)
	-- love.graphics.circle('line', Game.pointerStart.x, Game.pointerStart.y, 10, 50)
end

function Game:touchpressed(id, x, y)
	Game.pointerStart = {x = x, y = y}
end

function Game:touchreleased(id, x, y)

end

function Game:mousepressed(x, y)
	Game.pointerStart = {x = x, y = y}
end

function Game:mousereleased(x, y)
	local dx, dy = Game.pointerStart.x - x, Game.pointerStart.y - y
	local dist = math.sqrt(dx^2 + dy^2)

	if dist > 30 then
		local v1, v2 = -dx/dist, dy/dist

		if between(v1, 0, 1) and between(v2, 0.5, 1) then
			-- Slide hexagons starting a pointerStart up and to the right

			print('NE')
		elseif between(v1, 0, 1) and between(v2, -0.5, 0.5) then
			print('E')
		elseif between(v1, 0, 1) and between(v2, -0.5, -1) then
			print('SE')
		elseif between(v1, 0, -1) and between(v2, -0.5, -1) then
			print('SW')
		elseif between(v1, 0, -1) and between(v2, -0.5, 0.5) then
			print('W')
		elseif between(v1, 0, -1) and between(v2, 0.5, 1) then
			print('NW')
		end

		print(v1, v2)
	end
end

function between(x, first, second)

	return x >= first and x <= second or x <= first and x >= second
end

return Game