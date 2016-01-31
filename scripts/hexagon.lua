local offset = 30
local startMargin = 2
local endMargin = 1.1
local tweenTime = 1

local colors = {
	{85, 98, 112},    -- grey
	{78, 205, 196},   -- blue
	{199, 244, 100},  -- green
	{255, 107, 107},  -- pink
	-- {196, 77, 88}  -- red
}

local Hexagon = Class {
	init = function(self, x, y, z)
		self.x, self.y, self.z = x, y, z

		self.drawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * startMargin
		self.drawY = Game.hexSize * ((y + x) / 2 - z) * startMargin

		Timer.tween(tweenTime, self, {
				drawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * endMargin,
				drawY = Game.hexSize * ((y + x) / 2 - z) * endMargin
			},
			'out-expo')

		-- self.color = {255, 55, 20}
		self.color = colors[love.math.random(#colors)]
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

	directions = {
		NW = {x =  0, y = -1, z =  1},
		W  = {x =  1, y = -1, z =  0},
		SW = {x =  1, y =  0, z = -1},
		SE = {x =  0, y =  1, z = -1},
		E  = {x = -1, y =  1, z =  0},
		NE = {x = -1, y =  0, z =  1}
	},

	type = 'hexagon'
}

function Hexagon:update(dt)

end

function Hexagon:draw()
	love.graphics.push()

	love.graphics.translate(self.drawX, self.drawY)
	love.graphics.setColor(self.color)

	-- This allows for filled polygons while still anti-aliasing without having to use full screen anti-aliasing
	-- 	(Lines are anti-aliased automatically, fills are not)
	love.graphics.polygon('fill', Hexagon.vertices)
	love.graphics.polygon('line', Hexagon.vertices)

	love.graphics.setColor(0, 0, 0)
	love.graphics.print(self.x..' '..self.y..'\n '..self.z)

	love.graphics.pop()
end

function Hexagon:equals(other)
	return self.x == other.x and self.y == other.y and self.z == other.z
end

function Hexagon:isNeighbour(other)
	for _, dir in pairs(Hexagon.directions) do
		if self.x + dir.x == other.x and self.y + dir.y == other.y and self.z + dir.z == other.z then
			return true
		end
	end

	return false
end

function Hexagon:swap(other)
	self.x, other.x = other.x, self.x
	self.y, other.y = other.y, self.y 
	self.z, other.z = other.z, self.z

	local speed = 0.2
	local tweenFunc = 'in-out-quad'

	Timer.tween(speed, self, {drawX = other.drawX, drawY = other.drawY}, tweenFunc)
	Timer.tween(speed, other, {drawX = self.drawX, drawY = self.drawY}, tweenFunc)
end

function Hexagon:move(dir)
	dir = Hexagon.directions[dir]
	assert(dir, 'That direction doesn\'t exist')

	self.x = self.x + dir.x
	self.y = self.y + dir.y
	self.z = self.z + dir.z

	self:setWorldCoordinates(self.x, self.y, self.z, endMargin)
end

function Hexagon:moveTo(x, y, z)
	self.x = x
	self.y = y
	self.z = z

	self:setWorldCoordinates(x, y, z, endMargin)
end

function Hexagon:setWorldCoordinates(x, y, z, margin)
	local newDrawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * margin
	local newDrawY = Game.hexSize * ((y + x) / 2 - z) * margin

	Timer.tween(0.2, self, {
			drawX = newDrawX,
			drawY = newDrawY
		},
		'in-out-quad',
		function() Game.canMove = true end)
end

function Hexagon:checkCollision(x, y)
	return math.sqrt((self.drawX - x)^2 + (self.drawY - y)^2) < Game.hexSize - 5
end

function Hexagon.slideHexagons(axis, inverted)
	local hoverHex = Game.hexagons:getAtPoint(Game.pointerStart.x, Game.pointerStart.y);
	if hoverHex then
		local hexAxis = hoverHex[axis]
		local prevHex = hoverHex

		local hexes = {}

		-- First, collect the hexes we will be modifying
		Game.hexagons:forEach(function(hex)
			if hex[axis] == hexAxis then
				table.insert(hexes, hex)
			end
		end)

		-- Then sort them so that they can lerp in the right order
		table.sort(hexes, function(a, b)
			if inverted then
				if axis == 'y' then
					return a.x < b.x 
				else
					return a.y < b.y
				end
			else
				if axis == 'y' then
					return a.x > b.x 
				else
					return a.y > b.y
				end
			end
		end)

		prevHex = hexes[#hexes]
		for _, hex in pairs(hexes) do
			hex.tx = prevHex.x
			hex.ty = prevHex.y
			hex.tz = prevHex.z

			prevHex = hex
		end

		for _, hex in pairs(hexes) do
			hex:moveTo(hex.tx, hex.ty, hex.tz)
		end
	end
end

return Hexagon