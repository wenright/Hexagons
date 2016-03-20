--- This is the entry point into the game
-- @module Hex
-- @author Will

require 'scripts.utils'

Timer = require 'lib.hump.timer'
Gamestate = require 'lib.hump.gamestate'
Class = require 'lib.hump.class'
Camera = require 'lib.hump.camera'(0, 0)

Game = require 'states.game'

Entities = require 'scripts.entities'
Hexagon = require 'scripts.hexagon'

--- Called once when LOVE is loaded.  Initializes values and switches to the game state
function love.load()
	io.stdout:setvbuf('no')

	Camera:zoom(2, 2)

	Gamestate.registerEvents()
	Gamestate.switch(Game)
end

--- Called once per frame.  Used to update the Timer object
-- @tparam number dt The time in milliseconds between frame draws
function love.update(dt)
	Timer.update(dt)
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
