--- A hexagon object
-- @classmod Hexagon

-- A few config variables. Probably should be moved into the hexagon class
-- TODO move these
local startMargin = 1.5
local endMargin = 1.1

-- TODO move this
local hexes = {
  7,
  5,
  4,
  3
}

local Hexagon = Class {
  __includes = HexagonShape,
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
  HexagonShape.init(self, x, y, z, color)
end

--- Tweens a hexagon from its starting position.  Called once at the beginning of the game.
-- Parameters can be adjusted in hexagon.lua
-- @tparam number time Duration of tween animation
-- @tparam string tweenFunction The tween function to use. Ex: 'out-expo'
function Hexagon:tweenIn(time, tweenFunction)
  local x, y, z = self.x, self.y, self.z

  self.drawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * startMargin
  self.drawY = Game.hexSize * ((y + x) / 2 - z) * startMargin

  Timer.tween(time, self, {
    drawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * endMargin,
    drawY = Game.hexSize * ((y + x) / 2 - z) * endMargin
  },
  tweenFunction,
  function()
    Game.started = true
  end)
end

--- Check if the given hexagon is at an adjacent location to self
-- @tparam Hexagon other The other hexagont o compare with self
-- @treturn boolean Wether or not this hexagon is a neighbour of the other
function Hexagon:isNeighbour(other)
  for _, dir in pairs(HexagonShape.directions) do
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
  dir = HexagonShape.directions[dir]
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
-- @tparam boolean remove Whether or not hexagon should be removed when finished moving
-- @tparam boolean skipTween If this hex should not tween after setting its location
function Hexagon:setWorldCoordinates(x, y, z, margin, remove, skipTween)
  local newDrawX = Game.hexSize * (y - x) * math.sqrt(3) / 2 * margin
  local newDrawY = Game.hexSize * ((y + x) / 2 - z) * margin

  if not skipTween then
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
  else
    self.drawX = newDrawX
    self.drawY = newDrawY
  end
end

function Hexagon:returnToPreviousLocation()
  if self.previousSlide then
    local prev = Hexagon.previousSlide
    Hexagon.slideHexagons(prev.axis, prev.axisValue, prev.dir, prev.inverted, function() end)
  else
    print('WAHT')
  end
end

--- Check to see if this hexagon contains the given point.  Used for mouse click detection
-- @tparam number x x coordinate to check
-- @tparam number y y coordinate to check
-- @treturn boolean True if point lies inside this hexagon
function Hexagon:checkCollision(x, y)
  -- TODO use a more accurate collision detection method (Currently circle (distance) based, hex based would be better)
  return math.sqrt((self.drawX - x)^2 + (self.drawY - y)^2) < Game.hexSize - 5
end

--- Recursively counts connected Hexagons using a BFS
-- Do not call this from outside, use Hexagon:getScore instead.
local function getConnected(this, connected)
  this.visited = true

  Game.hexagons:forEach(function(hex)
    if hex:isNeighbour(this) then
      if hex.color == this.color and not hex.visited then
        table.insert(connected, hex)
        getConnected(hex, connected)
      end
    end
  end)
end

--- Counts the score for a given hexagon by traversing all connected similarly colored hexes
-- This is basically a wrapper for the local getConnected, but it also resets the visited field
-- @treturn boolean True if the game is over
function Hexagon:getConnected()
  local connected = {self}
  getConnected(self, connected)
  Game.hexagons:forEach(function(hex)
    hex.visited = false
  end)
  return connected
end

--- Slide hexagons in a certain direction along an axis
-- @tparam string axis The axis to slide hexagon along.  Ex 'y'
-- @tparam number axisValue This is the x, y, or z coordinate of the row to be moved
-- @tparam string dir The compass direction that the hexagons will slide
-- @tparam boolean inverted Used to determine sorting order so that hexagons slide in the right order
-- @tparam function finishedFunction The function that is called once the tweening has finished
function Hexagon.slideHexagons(axis, axisValue, dir, inverted, finishedFunction)
  print('slideringo ' .. axis)
  Game.canMove = false

  local slideTweenTime = 0.2
  local prevHex = hoverHex

  local hexes = {}

  -- Save this method call for if there are no pairs from this slide, but don't use finishedFunction to avoid inf loop
  Hexagon.previousSlide = {axis = axis, axisValue = axisValue, dir = dir, inverted = inverted}

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
      local dirVal = HexagonShape.directions[dir]

      Game.hexagons:add(hex.x, hex.y, hex.z, hex.color):move(dir, true)
      hex:setWorldCoordinates(hex.tx - dirVal.x, hex.ty - dirVal.y, hex.tz - dirVal.z, endMargin, false, true)
      hex:setWorldCoordinates(hex.tx, hex.ty, hex.tz, endMargin, false, false)
    else
      hex:moveTo(hex.tx, hex.ty, hex.tz)
    end
  end

  Timer.after(slideTweenTime * 2, function()
      Game.canMove = true

      if Game.isOver then
        Game:over()
      end

      finishedFunction()
  end)
end

--- Converts an axis and a boolean into a compass direction
-- @tparam string axis The 3D axis to use.  Ex 'y'
-- @tparam boolean isInverted Useful for determing the compass direction that the axis uses
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
function Hexagon.newColor() return Colors[love.math.random(#Colors)] end

return Hexagon
