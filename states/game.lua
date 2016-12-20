--- A state for when the game is being played
-- @submodule Hex

--- Holds current game information
-- @table Game
-- @field gridRadius How many hexagons should be drawn
-- @field hexSize The draw size for a hexagon
-- @field slideTweenTime Time it takes for a hex to slide when the player drags
-- @field tweenInTime Time it takes for a hex to slide when it is spawned
-- @field pointerStart Where the user has first clicked the screen
-- @field canMove Determines if the user can slide.  False while tween animation is playing
-- @field started True once the initial tweenIn animation has finished
-- @field over True when the player has won the game
-- @field slideDirection The direction the player has started sliding
-- @field slideAxis The axis the player has started sliding on
-- @field isDragged True if the player is currently clicking the screen
-- @field stencilFunction Used to prevent certain areas from drawing
local Game = {
  gridRadius = 2,
  hexSize = 50,
  slideTweenTime = 0.2,
  tweenInTime = 1,
  pointerStart = {x = 0, y = 0},
  canMove = false,
  started = false,
  isOver = false,
  slideDirection = nil,
  slideAxis = nil,
  isDragged = false,
  stencilFunction = function()
    -- TODO re-add stencil hexagons that are removed from game
    -- Game.stencilHexagons:draw()

    love.graphics.push()

    love.graphics.rotate(math.rad(30))

    love.graphics.scale(4.4)

    love.graphics.polygon('fill', Hexagon.vertices)
    love.graphics.pop()
  end
}

--- Initialize the game
function Game:init()
  print('Creating hexagons...')
  Game.score = 0
  Game.hexagons = Entities(Hexagon)
  Game.stencilHexagons = Entities(HexagonShape)
  local tweenInTime = 1

  for x = -Game.gridRadius, Game.gridRadius do
    for y = -Game.gridRadius, Game.gridRadius  do
      local z = -x + -y
      if math.abs(x) <= Game.gridRadius and math.abs(y) <= Game.gridRadius and math.abs(z) <= Game.gridRadius then
        -- Generate the actual hexagons
        local hex = Game.hexagons:add(x, y, z, nil, true)
        hex:tweenIn(tweenInTime, 'out-expo')
        Timer.after(tweenInTime, function()
          Game.started = true
        end)

        -- Generate the stencil hexagons
        local fakeHex = Game.stencilHexagons:add(x, y, z)
      end
    end
  end

  Timer.after(tweenInTime, function()
    Game.checkForPairs(false)
  end)

  love.graphics.setBackgroundColor(52, 56, 62)

  print('Game loaded')
end

--- Draw the current frame
function Game:draw()
  Camera:attach()

  -- if Game.started then
    love.graphics.stencil(Game.stencilFunction, 'replace', 1)
    love.graphics.setStencilTest('greater', 0)
  -- end

  -- This shows where the stencil is cutting off
  -- love.graphics.setColor(28, 130, 124)
  -- love.graphics.rectangle('fill', -1000, -1000, 2000, 2000)

  Game.hexagons:draw()

  love.graphics.setStencilTest()

  Camera:detach()

  love.graphics.setColor(255, 255, 255)
  love.graphics.print(Game.score, 0, 15)
end

function Game.checkForPairs(fromPlayerMove)
  Game.canMove = false

  local atLeastOnePairMatched = false
  Game.hexagons:forEach(function (hex)
    if not hex.checkedForPairs then
      hex.checkedForPairs = true

      local connected = hex:getConnected()

      if #connected > 3 then
        atLeastOnePairMatched = true

        local score = ((#connected)^2) * 100
        Game.score = Game.score + score
        Game.scoreTexts:add(score, hex.drawX, hex.drawY)

        for _, connectedHex in pairs(connected) do
          connectedHex.checkedForPairs = true

          Timer.tween(0.5, connectedHex, {scale = 0}, 'out-expo', function()
            Game.hexagons:remove(connectedHex)

            Game.stencilHexagons:forEach(function(other)
              if connectedHex:equals(other) then
                Game.stencilHexagons:remove(other)
              end
            end)

            -- Now that this hex been removed, let's have one spawn in and take its place
            local newHex = Game.hexagons:add(connectedHex.x * 2, connectedHex.y * 2, connectedHex.z * 2, Hexagon.randomColor())
            newHex:moveTo(connectedHex.x, connectedHex.y, connectedHex.z)
          end)
        end
      end
    end
  end)

  Game.hexagons:forEach(function (hex)
    hex.checkedForPairs = false
  end)

  if atLeastOnePairMatched then
    Timer.after(Game.tweenInTime, function()
      Game.checkForPairs(false)
    end)
  else
    Timer.after(Game.slideTweenTime, function()
      if fromPlayerMove then
        Hexagon.undoSlideHexagons()
      end

      Timer.after(Game.slideTweenTime, function()
        Game.canMove = true
      end)
    end)
  end
end

function Game:touchpressed(id, x, y) Input:pointerpressed(x, y) end
function Game:touchmoved(id, x, y, dx, dy) Input:pointermoved(x, y, dx, dy) end
function Game:touchreleased(id, x, y) Input:pointerreleased(x, y) end
function Game:mousepressed(x, y) Input:pointerpressed(x, y) end
function Game:mousemoved(x, y, dx, dy) Input:pointermoved(x, y, dx, dy) end
function Game:mousereleased(x, y) Input:pointerreleased(x, y) end

return Game
