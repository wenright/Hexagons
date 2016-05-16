local startMargin = 1.5
local endMargin = 1.1
local tweenTime = 1
local offset = 30

local HexagonShape = Class {
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
		math.sin(math.rad(60 * 5 + offset)) * Game.hexSize
	},

	--- A table of the possible compass directions and their equivalent 3D locations
	-- @table directions
	-- @field NW x =  0, y = -1, z =  1
	-- @field W  x =  1, y = -1, z =  0
	-- @field SW x =  1, y =  0, z = -1
	-- @field SE x =  0, y =  1, z = -1
	-- @field E  x = -1, y =  1, z =  0
	-- @field NE x = -1, y =  0, z =  1
	directions = {
		NW = {x =  0, y = -1, z =  1},
		W  = {x =  1, y = -1, z =  0},
		SW = {x =  1, y =  0, z = -1},
		SE = {x =  0, y =  1, z = -1},
		E  = {x = -1, y =  1, z =  0},
		NE = {x = -1, y =  0, z =  1}
	}
}

function HexagonShape:init(x, y, z, color)
	self.x, self.y, self.z = x, y, z

	self.drawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * endMargin
	self.drawY = Game.hexSize * ((y + x) / 2 - z) * endMargin

	if color then
		self.color = color
	else
		self.color = Colors[love.math.random(#Colors)]
	end
end

function HexagonShape:draw()
	love.graphics.push()

	love.graphics.translate(self.drawX, self.drawY)
	love.graphics.setColor(self.color)

	-- This allows for filled polygons while still anti-aliasing without having to use full screen anti-aliasing
	-- 	(Lines are anti-aliased automatically, fills are not)
	love.graphics.polygon('fill', HexagonShape.vertices)
	love.graphics.polygon('line', HexagonShape.vertices)

	love.graphics.setColor(self.color2 or {255, 255, 255, 255})
	love.graphics.polygon('line', HexagonShape.vertices)

	love.graphics.pop()
end

return HexagonShape