local ScoreText = Class {}

function ScoreText:init(score, x, y, color)
  self.score = score
  self.x, self.y = x + love.math.random() * 25, y + love.math.random() * 25

  self.scale = 0
  Timer.tween(love.math.random() / 4 + 0.1, self, {scale = 1}, 'out-quad')

  self.r = (love.math.random() - 0.5) * (math.pi/4)

  Timer.after(1, function()
    Game.scoreTexts:remove(self)
  end)

  self.color = color
end

function ScoreText:draw()
  -- TODO should color be based on What color the destroyed hex was?
  love.graphics.setColor(self.color)
  love.graphics.print(self.score, self.x, self.y, self.r, self.scale)
end

return ScoreText
