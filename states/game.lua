local Game = {
	gridRadius = 3,
	hexSize = 20
}

function Game:init()
	print('Game loaded')

	Game.hexagons = Entities(Hexagon)

	for q = -Game.gridRadius, Game.gridRadius do
		local r1, r2 = math.max(-Game.gridRadius, -q - Game.gridRadius), math.min(Game.gridRadius, -q + Game.gridRadius)
		for r = r1, r2  do
			Game.hexagons:add(q-r, -q-r)
		end
	end
end

function Game:update(dt)
	Game.hexagons:draw()
end

function Game:draw()
	Camera:attach()

	Game.hexagons:draw()

	Camera:detach()
end

return Game