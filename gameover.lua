Gameover = Object:extend()

function Gameover:new (x, y, game)
  self.DESTINATION = {x = 112, y = 116}
  self.game = game
  TEsound.play (SOUNDS.gameover, "static", "gameover")
  self.gameover_time = 5
  self.dx = self.DESTINATION.x < x and -1 or 1
  self.dy = self.DESTINATION.y < y and -1 or 1
  self.delta = { x = math.abs (self.DESTINATION.x - x), y = math.abs (self.DESTINATION.y - y)}
end

function Gameover:draw (gui)
  local x = self.DESTINATION.x - self.dx*self.delta.x
  local y = self.DESTINATION.y - self.dy*self.delta.y
  gui:writeText ("GAME", x, y, gui:getColorFromCycle3())
  gui:writeText ("OVER", x, y + 16, gui:getColorFromCycle3())
end

function Gameover:update (dt)
  self.gameover_time = self.gameover_time - dt
  if self.gameover_time < 0 then
    self.gameover_time = 0
    menu:startEnteringScore(self.game.score.score, self.game.curr_level)
  end
  if self.delta.x > 0 then
    self.delta.x = self.delta.x - HOR_SPEED * dt
  elseif self.delta.y > 0 then
    self.delta.y = self.delta.y - HOR_SPEED * dt
  end
end