require "sprites/walkingsprite"
require "colorrotator"

Bonus = WalkingSprite:extend()
Bonus:implement(ColorRotator)

function Bonus:new(game)
  local x = math.random(2) == 1 and 180 or 64
  local y = SCREEN_H / 4
  local curr_platform = game:getPlatformBelow(x)
  if curr_platform ~= nil then
    y = curr_platform.y - curr_platform.h-6
  end
  
  Bonus.super.new(self, game, "bonus", x, y, game.bombjack.hor_speed/3, game.bombjack.vert_speed, 4, 1)
  self.bonus_type = math.random(10) == 10 and "bonus_E" or "bonus_S"
  self:enableAnim (quads[self.bonus_type])
  self.on_the_floor, self.vy, self.direction, self.direction_before_falling = false, 0, {right = true}, {}
  self.color_index = 1
    self.step_color_time, self.rotating_colors = 0, colors.BonusToColors[1]  
end

function Bonus:getScore()
  return self:isNewLife() and 3000 or 1000
end

function Bonus:getLevelScore()
  return self:isNewLife() and 'C' or 'B'
end

function Bonus:isNewLife()
  return self.bonus_type == "bonus_E"
end

function Bonus:update(dt, limits)
  self.step_color_time = self.step_color_time + dt
  if self.step_color_time > 0.1 then
    self.step_color_time = 0
    self.color_index = self.color_index + 1
    if self.color_index > #colors.BonusToColors then
      self.color_index = 1
    end
    self.rotating_colors = colors.BonusToColors[self.color_index]
  end
  if not self.on_the_floor and table.nb_elements (self.direction) > 0 then   
    self.direction_before_falling = table.clone (self.direction) -- On se remémore la direction avant de tomber
    self.direction = {}
  end
  local new_directions = {}
  Bonus.super.update(self, dt, limits, 1, self.direction.left, self.direction.right, false, new_directions, true)

  if new_directions.up then
    TEsound.play (SOUNDS.bonus, "static")
  elseif (self.direction.left and new_directions.right) or (self.direction.right and new_directions.left) then -- change de direction
    TEsound.play (SOUNDS.bonus, "static")
    self.direction = new_directions
  end
  if table.nb_elements (self.direction) == 0 and self.on_the_floor then
    self.direction = self.direction_before_falling
  end
end

function Bonus:draw(sprite_map, sprite_near_map)
  local zeros = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}
  self.game.shader:sendColor("fromColors", colors.BonusFromColor[1], unpack (zeros))
  self.game.shader:sendColor("toColors", self:getColorTable(), unpack (zeros))
  love.graphics.setShader(self.game.shader)
  Bonus.super.draw (self, sprite_near_map)
  love.graphics.setShader()
end

function Bonus:__tostring()
  return "<Bonus: direction="..tostring(self.direction).."\n"..Bonus.super.__tostring (self) .. ">"
end