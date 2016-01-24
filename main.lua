Timer = require 'lib.hump.timer'
Gamestate = require 'lib.hump.gamestate'
Class = require 'lib.hump.class'
Camera = require 'lib.hump.camera'(0, 0)

Game = require 'states.game'

Entities = require 'scripts.entities'
Hexagon = require 'scripts.hexagon'

function love.load()
	io.stdout:setvbuf('no')

	Camera:zoom(2)

	Gamestate.registerEvents()
	Gamestate.switch(Game)
end

function love.update(dt)
	Timer.update(dt)
end

function love.draw()
	love.graphics.setColor(0, 200, 25)
	love.graphics.print(love.timer.getFPS())
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end