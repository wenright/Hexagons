local Input = {}

function Input:pointerpressed(x, y)
  Game.isDragged = true
  Game.hasMoved = false
  Game.pointerStart = {x = x, y = y}
end

function Input:pointermoved(x, y, dx, dy)
  -- TODO moving is still inaccurate at times
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
      if math.between(v1, 0, 1) and math.between(v2, 0.5, 1) then
        Game.slideDirection = 'SW'
        Game.slideAxis = 'y'
        Game.slideInverted = false
      elseif math.between(v1, 0, 1) and math.between(v2, -0.5, 0.5) then
        Game.slideDirection = 'W'
        Game.slideAxis = 'z'
        Game.slideInverted = true
      elseif math.between(v1, 0, 1) and math.between(v2, -0.5, -1) then
        Game.slideDirection = 'NW'
        Game.slideAxis = 'x'
        Game.slideInverted = true
      elseif math.between(v1, 0, -1) and math.between(v2, -0.5, -1) then
        Game.slideDirection = 'NE'
        Game.slideAxis = 'y'
        Game.slideInverted = true
      elseif math.between(v1, 0, -1) and math.between(v2, -0.5, 0.5) then
        Game.slideDirection = 'E'
        Game.slideAxis = 'z'
        Game.slideInverted = false
      elseif math.between(v1, 0, -1) and math.between(v2, 0.5, 1) then
        Game.slideDirection = 'SE'
        Game.slideAxis = 'x'
        Game.slideInverted = false
      end

      Game.slideAxisValue = Game.hoverHex[Game.slideAxis]
    end

    if Game.canMove and diffDist >= Game.hexSize * 2 and Game.slideDirection then
      Game.hasMoved = true

      if not (Game.consecutiveSlideAxis or Game.consecutiveSlideAxisValue) then
        Game.consecutiveSlideAxis = Game.slideAxis
        Game.consecutiveSlideAxisValue = Game.slideAxisValue
      end

      local direction = Hexagon.getDirection(Game.consecutiveSlideAxis, Game.slideInverted)
      Hexagon.slideHexagons(Game.consecutiveSlideAxis, Game.consecutiveSlideAxisValue, direction, Game.slideInverted)
      Game.pointerStart.x = x
      Game.pointerStart.y = y

      -- Find a new hexagon to rotate around (The one under mouse pointer)
      Game.hoverHex = Game.hexagons:getAtPoint(Game.pointerStart.x, Game.pointerStart.y)
    end
  end
end

function Input:pointerreleased(x, y)
  Game.hoverHex = Game.hexagons:getAtPoint(x, y)

  local diffX, diffY = Game.pointerStart.x - x, Game.pointerStart.y - y
  local diffDist = math.sqrt(diffX^2 + diffY^2)

  -- TODO check if anything has moved also.  Don't destroy if it has
  if Game.hoverHex and not Game.hasMoved and diffDist < Game.hexSize then 
    -- User just tapped, so count score for hoverHex
    local connected = Game.hoverHex:getConnected()
    print('You got ' .. #connected)

    for _, hex in pairs(connected) do
      Game.stencilHexagons:forEach(function(other)
        if hex:equals(other) then
          Game.stencilHexagons:remove(other)
        end
      end)

      Game.hexagons:remove(hex)
    end
  end

  Game.slideDirection = nil
  Game.consecutiveSlideAxis = nil
  Game.consecutiveSlideAxisValue = nil
  Game.slideAxis = nil
  Game.hoverHex = false
  Game.isDragged = false
  Game.hasMoved = false
end

--- Called when the player completes a hexagon and the game is over
function Input:over()
  -- TODO gameover code
end

return Input