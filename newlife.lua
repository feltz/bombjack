Newlife = Object:extend()

function Newlife:new (game, delay)
  self.x, self.y, self.game, self.delay = game.bombjack.x, game.bombjack.y, game, delay
  self.destinations = {{SCREEN_W/2, self.y}, {SCREEN_W/2, SCREEN_H-BORDER}, {game.gui:getLifeCoords (game.bombjack.lifes + 1)}}
  self.curr_dest, self.dx, self.dy, self.delta, self.is_done, self.end_delay = 1, 0, 0, 0, false, 0.5
  self.color_index, self.color_time = 1, WHITE_COLOR_TIME
  self:calcDxDy()
  self:calcDelta()
end

function Newlife:calcDxDy()
  self.dx = self.destinations[self.curr_dest][1] < self.x and -1 or self.destinations[self.curr_dest][1] == self.x and 0 or 1
  self.dy = self.destinations[self.curr_dest][2] < self.y and -1 or self.destinations[self.curr_dest][2] == self.y and 0 or 1
end  

function Newlife:calcDelta()
  self.delta = { x = math.abs (self.destinations[self.curr_dest][1] - self.x)
               , y = math.abs (self.destinations[self.curr_dest][2] - self.y)
               }
end  

function Newlife:draw (sprite_map)
  if not self:isDone() and self.delay < 0 then
    self.game.shader:sendColor("fromColors", colors.NewLifeFromColors[self.color_index])
    self.game.shader:sendColor("toColors", {255, 255, 255, 255})
    love.graphics.setShader(self.game.shader)
    love.graphics.draw (sprite_map, self.game.quads.bj_new_life, self.x, self.y)
    love.graphics.setShader()
  end
end

function Newlife:isDone()
  if not self.is_done then
    if self.end_delay < 0 then
      self.is_done = true
      self.game.bombjack.lifes = self.game.bombjack.lifes + 1
    end
  end
  return self.is_done
end

function Newlife:updateWhiteCycle (dt)
  self.color_time = self.color_time - dt
  if self.color_time < 0 then
    self.color_time = self.color_time + WHITE_COLOR_TIME
    self.color_index = self.color_index + 1
    if self.color_index > #colors.NewLifeFromColors then
      self.color_index = 1
    end
  end
end

function Newlife:update (dt)
  self:updateWhiteCycle(dt)
  self.delay = self.delay - dt
  if self.delay < 0 then
    if self.curr_dest > 3 then
      self.end_delay = self.end_delay - dt
    else
      if self.delta.x > 0 then
        self.delta.x = self.delta.x - HOR_SPEED * dt
        self.x = self.destinations[self.curr_dest][1] - self.dx*self.delta.x
      elseif self.delta.y > 0 then
        self.delta.y = self.delta.y - HOR_SPEED * dt
        self.y = self.destinations[self.curr_dest][2] - self.dy*self.delta.y
      end
      if self.delta.x <= 0 and self.delta.y <= 0 then
        self.curr_dest = self.curr_dest + 1
        if self.curr_dest <= 3 then
          self:calcDxDy()
          self:calcDelta()
        end
      end
    end
  end
end