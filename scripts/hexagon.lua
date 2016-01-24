local offset = 30

local Hexagon = Class {
	init = function(self, x, y)
		self.color = {255, 55, 20}
		self.x, self.y = x * Game.hexSize, y * Game.hexSize * 2
	end,

	vertices = {
		math.cos(math.rad(60 * 0 + offset)) * Game.hexSize,
		math.sin(math.rad(60 * 0 + offset)) * Game.hexSize,

		math.cos(math.rad(60 * 1 + offset)) * Game.hexSize,
		math.sin(math.rad(60 * 1 + offset)) * Game.hexSize,

		math.cos(math.rad(60 * 2 + offset)) * Game.hexSize,
		math.sin(math.rad(60 * 2 + offset)) * Game.hexSize,

		math.cos(math.rad(60 * 3 + offset)) * Game.hexSize,
		math.sin(math.rad(60 * 3 + offset)) * Game.hexSize,

		math.cos(math.rad(60 * 4 + offset)) * Game.hexSize,
		math.sin(math.rad(60 * 4 + offset)) * Game.hexSize,

		math.cos(math.rad(60 * 5 + offset)) * Game.hexSize,
		math.sin(math.rad(60 * 5 + offset)) * Game.hexSize,
	},

	type = 'hexagon'
}

function Hexagon:update(dt)

end

function Hexagon:draw()
	love.graphics.push()

	love.graphics.translate(self.x, self.y)
	love.graphics.setColor(self.color)

	-- This allows for filled polygons while still anti-aliasing without having to use full screen anti-aliasing
	-- 	(Lines are anti-aliased automatically, fills are not)
	love.graphics.polygon('line', Hexagon.vertices)

	-- Fill looks kind of bad because it extends over what it's supposed to 
	-- love.graphics.polygon('fill', Hexagon.vertices)

	love.graphics.pop()
end

return Hexagon