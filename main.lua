--- This is the entry point into the game
-- @module Hex
-- @author Will

require 'scripts.utils'

Timer = require 'lib.hump.timer'
Gamestate = require 'lib.hump.gamestate'
Class = require 'lib.hump.class'
Camera = require 'lib.hump.camera'(0, 0)

Game = require 'states.game'

Input = require 'scripts.input'
Entities = require 'scripts.entities'
Colors = require 'scripts.colors'
HexagonShape = require 'scripts.hexagonshape'
Hexagon = require 'scripts.hexagon'
ScoreText = require 'scripts.scoretext'

DEBUG = true

--- Called once when LOVE is loaded.  Initializes values and switches to the game state
function love.load()
  io.stdout:setvbuf('no')

  Camera:zoom(1.25, 1.25)

  Gamestate.registerEvents()
  Gamestate.switch(Game)

  love.graphics.setFont(love.graphics.newFont('font/kenpixel_high.ttf', 48))
end

--- Called once per frame.  Used to update the Timer object
-- @tparam number dt The time in milliseconds between frame draws
function love.update(dt)
  Timer.update(dt)

  if DEBUG then
    require 'lib.bird.lovebird':update(dt)
  end
end

--- Draws the frames per second indicator
function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(love.timer.getFPS())
end

--- Exits the game when the escape key is pressed
-- @tparam string key The key pressed
function love.keypressed(key)
  if key == 'escape' then love.event.quit() end
end

local old_print = print
function print(...)
  old_print(...)
end
