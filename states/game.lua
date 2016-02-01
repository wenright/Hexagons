local Game = {
	gridRadius = 3,
	hexSize = 50,
	selectedHexagon = nil,
	pointerStart = {x = 0, y = 0},
	canMove = true
}

function Game:init()
	print('Creating hexagons...')
	Game.hexagons = Entities(Hexagon)
	Game.hexagonReference = {}

	for x = -Game.gridRadius, Game.gridRadius do
		Game.hexagonReference[x] = {}
		for y = -Game.gridRadius, Game.gridRadius  do
			Game.hexagonReference[x][y] = {}
			local z = -x + -y
			if math.abs(x) <= Game.gridRadius and math.abs(y) <= Game.gridRadius and math.abs(z) <= Game.gridRadius then
				Game.hexagonReference[x][y][z] = Game.hexagons:add(x, y, z)
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

	if dist > 30 and Game.canMove then
		local v1, v2 = -dx/dist, dy/dist

		-- Slide hexagons based on the direction that the user swiped
		-- TODO: lerp the one that moves around by create a new one then destroying the old one,
		-- 			So that it looks like a new one came from the other side 
		if between(v1, 0, 1) and between(v2, 0.5, 1) then
			Hexagon.slideHexagons('y', true)
		elseif between(v1, 0, 1) and between(v2, -0.5, 0.5) then
			Hexagon.slideHexagons('z', false)
		elseif between(v1, 0, 1) and between(v2, -0.5, -1) then
			Hexagon.slideHexagons('x', false)
		elseif between(v1, 0, -1) and between(v2, -0.5, -1) then
			Hexagon.slideHexagons('y', false)
		elseif between(v1, 0, -1) and between(v2, -0.5, 0.5) then
			Hexagon.slideHexagons('z', true)
		elseif between(v1, 0, -1) and between(v2, 0.5, 1) then
			Hexagon.slideHexagons('x', true)
		else
			-- The user must have missed all hexagons, so allow moving again
		end
	end
end

function between(x, first, second)
	return x >= first and x <= second or x <= first and x >= second
end

return Game