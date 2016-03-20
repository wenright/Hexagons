--- A hexagon object
-- @classmod Hexagon

-- A few config variables. Probably should be moved into the hexagon class
local offset = 30
local startMargin = 2.5
local endMargin = 1.1
local tweenTime = 1

--- A table of the default colors to draw hexagons with
-- @table colors
-- @field 1 grey
-- @field 2 blue
-- @field 3 green
-- @field 4 pink
local colors = {
	{85, 98, 112},    -- grey
	{78, 205, 196},   -- blue
	{199, 244, 100},  -- green
	{255, 107, 107},  -- pink
}

local Hexagon = Class {
  -- A table of vertices that make up a hexagon
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
	},

	type = 'hexagon'
}


--- Initialize a new hexagon object
-- Note that coordinates are 3 dimensional, but will be drawn on a 2D plane
-- @tparam number x x-coordinate to draw hexagon
-- @tparam number y y-coordinate to draw hexagon
-- @tparam number z z-coordinate to draw hexagon
-- @tparam number color Color that hexagon will draw as. Also used to determine win condition
-- @treturn Hexagon a new hexagon object
function Hexagon:init(x, y, z, color)
    self.x, self.y, self.z = x, y, z

    self.drawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * endMargin
    self.drawY = Game.hexSize * ((y + x) / 2 - z) * endMargin

    -- self.color = {255, 55, 20}
    self.color = color or colors[love.math.random(#colors)]
  end

--- Updates the hex object
-- @tparam number dt Time between frame draws
function Hexagon:update(dt)

end

--- Draws a hexagon object
function Hexagon:draw()
	love.graphics.push()

	love.graphics.translate(self.drawX, self.drawY)
	love.graphics.setColor(self.color)

	-- This allows for filled polygons while still anti-aliasing without having to use full screen anti-aliasing
	-- 	(Lines are anti-aliased automatically, fills are not)
	love.graphics.polygon('fill', Hexagon.vertices)
	love.graphics.polygon('line', Hexagon.vertices)

	love.graphics.pop()
end

--- Tweens a hexagon from its starting position.  Called once at the beginning of the game.
-- Parameters can be adjusted in hexagon.lua
-- @tparam number time Duration of tween animation
-- @tparam string func The tween function to use. Ex: 'out-expo' 
function Hexagon:tweenIn(time, func)
	local x, y, z = self.x, self.y, self.z

	self.drawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * startMargin
	self.drawY = Game.hexSize * ((y + x) / 2 - z) * startMargin

	Timer.tween(time, self, {
		drawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * endMargin,
		drawY = Game.hexSize * ((y + x) / 2 - z) * endMargin
	},
	func,
	function()
		Game.started = true
	end)
end

--- Compare a hexagon with another to see if they occupy the same space
-- @tparam Hexagon other The other hexagon to compare with self
-- @treturn boolean Wether or not this hexagon is at the same location as the other
function Hexagon:equals(other)
	return self.x == other.x and self.y == other.y and self.z == other.z
end

--- Check if the given hexagon is at an adjacent location to self
-- @tparam Hexagon other The other hexagont o compare with self
-- @treturn boolean Wether or not this hexagon is a neighbour of the other
function Hexagon:isNeighbour(other)
	for _, dir in pairs(Hexagon.directions) do
		if self.x + dir.x == other.x and self.y + dir.y == other.y and self.z + dir.z == other.z then
			return true
		end
	end

	return false
end

--- Swap the location of one hexagon with another
-- @tparam Hexagon other The other hexagon to swap with self
function Hexagon:swap(other)
	self.x, other.x = other.x, self.x
	self.y, other.y = other.y, self.y
	self.z, other.z = other.z, self.z

	local speed = 0.2
	local tweenFunc = 'in-out-quad'

	Timer.tween(speed, self, {drawX = other.drawX, drawY = other.drawY}, tweenFunc)
	Timer.tween(speed, other, {drawX = self.drawX, drawY = self.drawY}, tweenFunc)
end

--- Move a hexagon in a certain direction (using a tween animation)
-- @tparam string dir The compass direction to move the hexagon. Ex 'NE'
-- @tparam boolean remove Wether or not to remove this hexagon after moving it. This is used for moving hexes off the map
function Hexagon:move(dir, remove)
	dir = Hexagon.directions[dir]
	assert(dir, 'That direction doesn\'t exist')

	self.x = self.x + dir.x
	self.y = self.y + dir.y
	self.z = self.z + dir.z

	self:setWorldCoordinates(self.x, self.y, self.z, endMargin, remove)
end

--- Move a hexagon to a location
-- @tparam number x x-coordinate to move hexagon to
-- @tparam number y y-coordinate to move hexagon to
-- @tparam number z z-coordinate to move hexagon to
function Hexagon:moveTo(x, y, z)
	self.x = x
	self.y = y
	self.z = z

	self:setWorldCoordinates(x, y, z, endMargin)
end

--- Set the world coordinates for a hexagon, and tween to that loccation
-- @tparam number x x-coordinate to move hexagon to
-- @tparam number y y-coordinate to move hexagon to
-- @tparam number z z-coordinate to move hexagon to
-- @tparam number margin How far apart the hexagons should be
-- @tparam boolean remove Wether or not hexagon should be removed when finished moving
function Hexagon:setWorldCoordinates(x, y, z, margin, remove)
	local newDrawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * margin
	local newDrawY = Game.hexSize * ((y + x) / 2 - z) * margin

	Timer.tween(0.2, self, {
			drawX = newDrawX,
			drawY = newDrawY
		},
		'in-out-quad',
		function()
			Game.canMove = true

			if remove then
				Game.hexagons:remove(self)
			end
		end)
end

--- Check to see if this hexagon contains the given point.  Used for mouse click detection
-- @tparam number x x coordinate to check
-- @tparam number y y coordinate to check
-- @treturn boolean True if point lies inside this hexagon
function Hexagon:checkCollision(x, y)
	-- TODO use a more accurate collision detection method (Currently circle based)
	return math.sqrt((self.drawX - x)^2 + (self.drawY - y)^2) < Game.hexSize - 5
end

--- Check the hexagons for a win condition
-- @treturn boolean True if the game is over
function Hexagon:checkForWin()
	local won = true
	local c = 0

	Game.hexagons:forEach(function(hex)

		if hex:isNeighbour(self) then
			c = c + 1
			if hex.color ~= self.color then
				won = false
			end
		end
	end)

	return won and c == 6
end

--- Slide hexagons in a certain direction along an axis
-- @tparam string axis The axis to slide hexagon along.  Ex 'y'
-- @tparam number axisValue This is the x, y, or z coordinate of the row to be moved
-- @tparam string dir The compass direction that the hexagons will slide
-- @tparam boolean inverted Used to determine sorting order so that hexagons slide in the right order
function Hexagon.slideHexagons(axis, axisValue, dir, inverted)
	Game.canMove = false

	local slideTweenTime = 0.2
	local prevHex = hoverHex

	local hexes = {}

	-- First, collect the hexes we will be modifying
	Game.hexagons:forEach(function(hex)
		if hex[axis] == axisValue then
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
		-- Find the one that has to move around the map, and duplicate/teleport it
		if math.abs(hex.x - hex.tx) > 1 or math.abs(hex.y - hex.ty) > 1 or math.abs(hex.z - hex.tz) > 1 then
			local dirVal = Hexagon.directions[dir]
			assert(dirVal, 'dirVal is null')

			local newHex = Game.hexagons:add(hex.tx - dirVal.x, hex.ty - dirVal.y, hex.tz - dirVal.z, hex.color)
			newHex:moveTo(hex.tx, hex.ty, hex.tz)

			-- Move this new hex up a little, then remove it when done
			hex:move(dir, true)
		else
			hex:moveTo(hex.tx, hex.ty, hex.tz)
		end
	end

	Timer.after(slideTweenTime, function()
    Game.canMove = true

		Game.hexagons:forEach(function(hex)
			if hex:checkForWin() then
				print('You won!')
				Game.over = true
			end
		end)

    if Game.over then
      Game:over()
    end
	end)
end

--- Converts an axis and a boolean into a compass direction
-- @tparam string axis The 3D axis to use.  Ex 'y'
-- @tparam boolean isInverted Usefule for determing the compass direction that the axis uses
-- @treturn string The compass direction the the axis and iversion imply
function Hexagon.getDirection(axis, isInverted)
  if isInverted then
    if axis == 'z' then return 'W'
    elseif axis == 'x' then return 'NW'
    elseif axis == 'y' then return 'NE' end
  else
    if axis == 'z' then return 'E'
    elseif axis == 'x' then return 'SE'
    elseif axis == 'y' then return 'SW' end
  end
end

--- Finds a new random color from the table of colors
-- @treturn table a random color from the color table
function Hexagon.newColor() return colors[love.math.random(#colors)] end

return Hexagon
