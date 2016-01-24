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
			},
			'out-expo',
			function()
				self.ready = true
			end)

		-- self.color = {255, 55, 20}
		self.color = {
			love.math.random() * 255,
			love.math.random() * 255,
			love.math.random() * 255
		}
		self.selectedColor = {
			self.color[1] + 100,
			self.color[2] + 100,
			self.color[3] + 100
		}

		self.selected = false
		self.ready = false
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

	if self.selected or Game.selectedHexagon == self then
		love.graphics.setColor(self.selectedColor)
	else
		love.graphics.setColor(self.color)
	end

	-- This allows for filled polygons while still anti-aliasing without having to use full screen anti-aliasing
	-- 	(Lines are anti-aliased automatically, fills are not)
	love.graphics.polygon('fill', Hexagon.vertices)
	love.graphics.polygon('line', Hexagon.vertices)

	love.graphics.pop()
end

function Hexagon:pointerdown(x, y)
	if self.ready and not Game.selectedHexagon and self:checkCollision(x, y) then
		Game.selectedHexagon = self
		self.selected = true
	end
end

function Hexagon:pointermoved(x, y, dx, dy)
	-- Check if user has dragged pointer
	if self.ready and Game.selectedHexagon and self:checkCollision(x, y) and self:isNeighbour(Game.selectedHexagon) then
		self.selected = true
	else
		self.selected = false
	end
end

function Hexagon:pointerreleased(x, y)
	if self.ready and self.selected and Game.selectedHexagon and self ~= Game.selectedHexagon then
		self:swap(Game.selectedHexagon)
	end

	self.selected = false
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
	self.ready, other.ready = false, false

	self.x, other.x = other.x, self.x
	self.y, other.y = other.y, self.y 
	self.z, other.z = other.z, self.z

	-- TODO what happens when user tries to move during tween? currently we wait til done tweening, but feels laggy
	-- 		Could just rememberr user wants to move a hex, then move once done tweening
	local speed = 0.2
	local tweenFunc = 'in-out-quad'

	Timer.tween(speed, self, {drawX = other.drawX, drawY = other.drawY}, tweenFunc, function() self.ready = true end)
	Timer.tween(speed, other, {drawX = self.drawX, drawY = self.drawY}, tweenFunc, function() other.ready = true end)
end

function Hexagon:checkCollision(x, y)
	return math.sqrt((self.drawX - x)^2 + (self.drawY - y)^2) < Game.hexSize - 5
end

return Hexagon