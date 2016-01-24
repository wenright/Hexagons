local offset = 30
local startMargin = 2
local endMargin = 1.1
local tweenTime = 2

local Hexagon = Class {
	init = function(self, x, y, z)
		self.x, self.y, self.z = x, y, z
		
		self.drawX, self.drawY = Game.hexSize * (y - x) * math.sqrt(3) / 2 * startMargin, Game.hexSize * ((y + x) / 2 - z) * startMargin
		Timer.tween(tweenTime, self, {
			drawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * endMargin,
			drawY = Game.hexSize * ((y + x) / 2 - z) * endMargin
		}, 'out-expo')

		self.color = {255, 55, 20}
		self.selectedColor = {255, 255, 250}
		self.selected = false
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

	direcetions = {
		NW = { 0, -1,  1},
		W  = { 1, -1,  0},
		SW = { 1,  0, -1},
		SE = { 0,  1, -1},
		E  = {-1,  1,  0},
		NE = {-1,  0,  1}
	},

	type = 'hexagon'
}

function Hexagon:update(dt)

end

function Hexagon:draw()
	love.graphics.push()

	love.graphics.translate(self.drawX, self.drawY)

	-- This allows for filled polygons while still anti-aliasing without having to use full screen anti-aliasing
	-- 	(Lines are anti-aliased automatically, fills are not)
	if self.selected then
		love.graphics.setColor(self.selectedColor)
		love.graphics.polygon('line', Hexagon.vertices)
	else
		love.graphics.setColor(self.color)
		love.graphics.polygon('line', Hexagon.vertices)
	end

	-- love.graphics.print(self.key)
	love.graphics.print(self.x..','..self.y..'\n'..self.z, -10, -20)

	-- Fill looks kind of bad because it extends over what it's supposed to 
	-- love.graphics.polygon('fill', Hexagon.vertices)

	love.graphics.pop()
end

function Hexagon:pointermoved(x, y, dx, dy)
	local mx, my = Camera:mousePosition()
	self.selected = math.sqrt((self.drawX - mx)^2 + (self.drawY - my)^2) < Game.hexSize - 5
end

function Hexagon:pointerreleased()
	self.selected = false
end

function Hexagon:equals(other)
	return self.x == other.x and self.y == other.y and self.z == other.z
end

return Hexagon