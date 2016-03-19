local Game = {
	gridRadius = 2,
	hexSize = 50,
	pointerStart = {x = 0, y = 0},
	canMove = false,
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
        local tweenInTime = 1
				hex:tweenIn(tweenInTime, 'out-expo')
        Timer.after(tweenInTime, function() Game.canMove = true end)

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

-- TODO this is old code. Use code from mouse*
function Game:touchreleased(id, x, y)

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

		if not Game.hoverHex then
			Game.hoverHex = Game.hexagons:getAtPoint(Game.pointerStart.x, Game.pointerStart.y)
		end

		-- Only perform these actions if the user is over a hexagon
		if Game.hoverHex then
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

			Game.slideAxisValue = Game.hoverHex[Game.slideAxis]
		end

		if Game.canMove and diffDist >= Game.hexSize * 2 and Game.slideDirection then
      if not (Game.consecutiveSlideAxis or Game.consecutiveSlideAxisValue) then
        Game.consecutiveSlideAxis = Game.slideAxis
        Game.consecutiveSlideAxisValue = Game.slideAxisValue
      end

      -- TODO slide direction needs to be updated somehow
			Hexagon.slideHexagons(Game.consecutiveSlideAxis, Game.consecutiveSlideAxisValue, Game.slideDirection,  Game.slideInverted)
			Game.pointerStart.x = x
			Game.pointerStart.y = y

			-- Find a new hexagon to rotate around (The one under mouse pointer)
			Game.hoverHex = Game.hexagons:getAtPoint(Game.pointerStart.x, Game.pointerStart.y)
		end
	end
end

function Game:mousereleased(x, y)
	Game.slideDirection = nil
  Game.consecutiveSlideAxis = nil
  Game.consecutiveSlideAxisValue = nil
	Game.slideAxis = nil
	Game.hoverHex = false
	Game.isDragged = false
end

return Game
