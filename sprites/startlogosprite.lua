require "sprites/animatedsprite"

StartLogoSprite = AnimatedSprite:extend()

function StartLogoSprite:new(direction)
  StartLogoSprite.super.new (self, 0, SCREEN_H/2, 0, 0, quads.start_level[direction == "left" and 1 or 2])
  self.dx = direction == "left" and 1 or -1
  if direction == "left" then
    self.x = -self.w
  else
    self.x = SCREEN_W
  end
  self.start_time = 0
  self.time_limit = 2
  self.goto_black = 0.3
  self.center_reached = false
end

function StartLogoSprite:update(dt)
  self.start_time = self.start_time + dt
  if math.abs (self.x+self.w/2 - SCREEN_W / 2) > 0.1 then
    self.x = self.x + HOR_SPEED * 1.7 * self.dx  * dt
  else
    self.center_reached = true
  end
  if self.center_reached then
    self.goto_black = self.goto_black -dt
  end
  if self.start_time > self.time_limit then
    self.quad = nil
  end
end

function StartLogoSprite:draw(shader, gui, sprite_map)
  if not self.center_reached then
    shader:sendColor("fromColors", {0, 0, 0, 1}, {1, 1, 0, 1})
    local index = math.ceil (1 + #colors.StartLogoColors * self.start_time / self.time_limit)
    if index <= #colors.StartLogoColors then
      shader:sendColor("toColors", colors.StartLogoColors[index], {0, 0, 0, 1})  
    end
  elseif self.goto_black >= 0 then
    shader:sendColor("fromColors", {0, 0, 0, 1}, {1, 1, 0, 1})
    shader:sendColor("toColors", {self.goto_black/0.3, self.goto_black/0.3, 0, 1}, gui:getColorFromCycle3())
  else
    shader:sendColor("fromColors", {0, 0, 0, 1}, {1, 1, 0, 1})
    shader:sendColor("toColors", {0, 0, 0, 1}, gui:getColorFromCycle3())      
  end
  love.graphics.setShader(shader)
  StartLogoSprite.super.draw(self, sprite_map)
  love.graphics.setShader()
end
