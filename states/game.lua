local Game = {
	gridRadius = 2,
	hexSize = 50,
	pointerStart = {x = 0, y = 0},
	canMove = true,
	started = false,
	over = false,
	stencilFunction = function()
		Game.stencilHexagons:draw()

		love.graphics.push()

		love.graphics.rotate(math.rad(30))

		local scale = 4
		love.graphics.scale(scale)

		love.graphics.polygon('fill', Hexagon.vertices)
		love.graphics.pop()
	end
}

function Game:init()
	print('Creating hexagons...')
	Game.hexagons = Entities(Hexagon)
	Game.stencilHexagons = Entities(Hexagon)

	for x = -Game.gridRadius, Game.gridRadius do
		for y = -Game.gridRadius, Game.gridRadius  do
			local z = -x + -y
			if math.abs(x) <= Game.gridRadius and math.abs(y) <= Game.gridRadius and math.abs(z) <= Game.gridRadius then
				local hex = Game.hexagons:add(x, y, z)
				hex:tweenIn(1, 'out-expo')

				-- HACK: maybe just draw hexagons manually. Maintaining a second list of hexes could break things
				local fakeHex = Game.stencilHexagons:add(x, y, z)
				local margin = 1.1
				fakeHex.drawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * margin
				fakeHex.drawY = Game.hexSize * ((y + x) / 2 - z) * margin
			end
		end
	end

	love.graphics.setBackgroundColor(52, 56, 62)

	print('Game loaded')
end

function Game:update(dt)
	Game.hexagons:update(dt)
end

function Game:draw()
	Camera:attach()

	if Game.started then
		love.graphics.stencil(Game.stencilFunction, 'replace', 1)
		love.graphics.setStencilTest('greater', 0)
	end

	-- This shows where the stencil is cutting off
	-- love.graphics.setColor(28, 130, 124)
	-- love.graphics.rectangle('fill', -1000, -1000, 2000, 2000)

	Game.hexagons:draw()

	love.graphics.setStencilTest()

	Camera:detach()

	if Game.over then
		love.graphics.setColor(255, 255, 255)
		love.graphics.print('You won!', love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
	end
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
			Hexagon.slideHexagons('y', 'NE', true)
		elseif between(v1, 0, 1) and between(v2, -0.5, 0.5) then
			Hexagon.slideHexagons('z', 'E',  false)
		elseif between(v1, 0, 1) and between(v2, -0.5, -1) then
			Hexagon.slideHexagons('x', 'SE', false)
		elseif between(v1, 0, -1) and between(v2, -0.5, -1) then
			Hexagon.slideHexagons('y', 'SW', false)
		elseif between(v1, 0, -1) and between(v2, -0.5, 0.5) then
			Hexagon.slideHexagons('z', 'W', true)
		elseif between(v1, 0, -1) and between(v2, 0.5, 1) then
			Hexagon.slideHexagons('x', 'NW', true)
		else
			-- The user must have missed all hexagons, so allow moving again
		end
	end
end

function between(x, first, second)
	return x >= first and x <= second or x <= first and x >= second
end

return Game
