local Game = {
	gridRadius = 2,
	hexSize = 50,
	pointerStart = {x = 0, y = 0},
	canMove = true,
	started = false,
	over = false,
	slideDirection = nil,
	slideAxis = nil,
	isDragged = false,
	stencilFunction = function()
		Game.stencilHexagons:draw()

		love.graphics.push()

		love.graphics.rotate(math.rad(30))

		local scale = 4.4
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

-- TODO for mobile
function Game:touchmoved(id, x, y, dx, dy)

end

function Game:touchreleased(id, x, y)
	local dx, dy = Game.pointerStart.x - x, Game.pointerStart.y - y
	local dist = math.sqrt(dx^2 + dy^2)

	if dist > 30 and Game.canMove then
		local v1, v2 = -dx/dist, dy/dist

		-- Slide hexagons based on the direction that the user swiped
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

function Game:mousepressed(x, y)
	Game.isDragged = true
	Game.pointerStart = {x = x, y = y}
end

function Game:mousemoved(x, y, dx, dy)
	if Game.isDragged then
		local diffX, diffY = Game.pointerStart.x - x, Game.pointerStart.y - y
		local diffDist = math.sqrt(diffX^2 + diffY^2)

		local dist = math.sqrt(dx^2 + dy^2)

		if not Game.slideDirection then
			local hoverHex = Game.hexagons:getAtPoint(Game.pointerStart.x, Game.pointerStart.y)

			-- Only perform these actions if the user is over a hexagon
			if hoverHex then
				local v1, v2 = -dx/dist, dy/dist

				-- Slide hexagons based on the direction that the user swiped
				if between(v1, 0, 1) and between(v2, 0.5, 1) then
					Game.slideDirection = 'SW'
					Game.slideAxis = 'y'
					Game.slideInverted = false
				elseif between(v1, 0, 1) and between(v2, -0.5, 0.5) then
					Game.slideDirection = 'W'
					Game.slideAxis = 'z'
					Game.slideInverted = true
				elseif between(v1, 0, 1) and between(v2, -0.5, -1) then
					Game.slideDirection = 'NW'
					Game.slideAxis = 'x'
					Game.slideInverted = true
				elseif between(v1, 0, -1) and between(v2, -0.5, -1) then
					Game.slideDirection = 'NE'
					Game.slideAxis = 'y'
					Game.slideInverted = true
				elseif between(v1, 0, -1) and between(v2, -0.5, 0.5) then
					Game.slideDirection = 'E'
					Game.slideAxis = 'z'
					Game.slideInverted = false
				elseif between(v1, 0, -1) and between(v2, 0.5, 1) then
					Game.slideDirection = 'SE'
					Game.slideAxis = 'x'
					Game.slideInverted = false
				end

				Game.slideAxisValue = hoverHex[Game.slideAxis]
			end
		elseif Game.canMove and diffDist >= Game.hexSize * 2 then
			if Game.lastDxSign ~= math.sign(dx) or Game.dlastDySign ~= math.sign(dy) then
				Game.slideInverted = not Game.slideInverted
			end

			Hexagon.slideHexagons(Game.slideAxis, Game.slideAxisValue, Game.slideDirection,  Game.slideInverted)
			Game.pointerStart.x = x
			Game.pointerStart.y = y
		end

		Game.lastDxSign, Game.dlastDySign = math.sign(dx), math.sign(dy)
	end
end

function Game:mousereleased(x, y)
	Game.slideDirection = nil
	Game.slideAxis = nil
	Game.isDragged = false
end

-- TODO move these 2 functions to util.lua
function between(x, first, second)
	return x >= first and x <= second or x <= first and x >= second
end

function math.sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end

return Game
