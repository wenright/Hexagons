local Input = {}

function Input:pointerpressed(x, y)
  Game.isDragged = true
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
  Game.slideDirection = nil
  Game.consecutiveSlideAxis = nil
  Game.consecutiveSlideAxisValue = nil
  Game.slideAxis = nil
  Game.hoverHex = false
  Game.isDragged = false
end

--- Called when the player completes a hexagon and the game is over
function Input:over()
  Game.canMove = false
  Game.started = false

  Game.hexagons:forEach(function(hex)
    local outMargin = 1.5
    Timer.tween(1, hex, {
        drawX = Game.hexSize * (hex.y - hex.x) * math.sqrt(3) / 2 * outMargin,
        drawY = Game.hexSize * ((hex.y + hex.x) / 2 - hex.z) * outMargin
      },
      'out-expo')
  end)

  Timer.after(1, function ()
    Timer.tween(0.5, Camera, {x = love.graphics.getWidth()/2}, 'in-quad', function()
      Camera.x = -love.graphics.getWidth()/2

      Game.hexagons:forEach(function(hex)
        hex.color = Hexagon.newColor()
      end)

      Timer.tween(0.5, Camera, {x = 0}, 'out-quad', function()
        Game.hexagons:forEach(function(hex)
          hex:tweenIn(1, 'out-expo')
        end)

        Timer.after(1, function()
          Game.canMove = true
          Game.isOver = false
        end)
      end)
    end)
  end)
end

return Input