require "sprites/bouncingsprite"
require "common"

Power = BouncingSprite:extend()
Power:implement(ColorRotator)

SCORES = {100, 200, 300, 500, 800, 1200, 2000}

function Power:new(game)
  Power.super.new(self, game, "power", SCREEN_W / 2,  SCREEN_H / 2 - 8, 0.75)
  self:enableIdle (quads.power)
  self.cosvx, self.sinvy = math.cos (math.pi/3), math.sin (math.pi/3)
  self.vx, self.vy = self.hor_speed * self.cosvx, self.vert_speed * self.sinvy 
  self:initColorRotator(colors.PowerToColors[1])
  self.color_index = 1
end

function Power:changeColor()
  if self.color_index < #colors.PowerToColors then
    self.color_index = self.color_index + 1
  else
    self.color_index = 1
  end
  self:startColorRotation (colors.PowerToColors[self.color_index])
end

function Power:getCurrentColors()
  return colors.PowerToColors[self.color_index]
end

function Power:getScore()
  return SCORES[self.color_index]
end

function Power:update(dt, limits)
  self:rotateColorTable (dt)
  Power.super.update(self, dt, limits)
end

function Power:draw(sprite_map, sprite_near_map)
  self.game.shader:sendColor("fromColors", unpack (colors.PowerFromColors))
  self.game.shader:sendColor("toColors", unpack (self:getColorTable()))
  love.graphics.setShader(self.game.shader)
  Power.super.draw (self, sprite_near_map)
  love.graphics.setShader()
end

function Power:__tostring()
  return "<PowerSprite: " .. Power.super.__tostring (self) .. ">"
end