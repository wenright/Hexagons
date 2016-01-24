Timer = require 'lib.hump.timer'
Gamestate = require 'lib.hump.gamestate'

Game = require 'lib.states.game'

function love.update(dt) Timer.update(dt) end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end