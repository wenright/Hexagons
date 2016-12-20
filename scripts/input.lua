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

    -- Determine the direction that the hexagons will slide in
    -- Only perform these actions if the users pointer is over a hexagon
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

    if not Game.hasMoved and Game.canMove and diffDist >= Game.hexSize * 2 and Game.slideDirection then
      Game.hasMoved = true

      if not (Game.consecutiveSlideAxis or Game.consecutiveSlideAxisValue) then
        Game.consecutiveSlideAxis = Game.slideAxis
        Game.consecutiveSlideAxisValue = Game.slideAxisValue
      end

      local direction = Hexagon.getDirection(Game.consecutiveSlideAxis, Game.slideInverted)
      Hexagon.slideHexagons(Game.consecutiveSlideAxis, Game.consecutiveSlideAxisValue, direction, Game.slideInverted, Game.checkForPairs)
      Game.pointerStart.x = x
      Game.pointerStart.y = y
    end
  end
end

function Input:pointerreleased(x, y)
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
  -- TODO gameover code. Display 'tap to continue' or something
end

return Input
