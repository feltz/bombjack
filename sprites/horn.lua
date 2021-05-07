require "sprites/movingsprite"

Horn = BouncingSprite:extend()

function Horn:new(game, x, y)
  Horn.super.new(self, game, "horn", x, y, 0.25)
  self:enableAnim (quads.horn, 0, 4, .3)
  self.cosvx, self.sinvy = math.cos (math.pi/3), math.sin (math.pi/3)
  self.vx, self.vy = self.hor_speed * self.cosvx, self.vert_speed * self.sinvy
end

function Horn:update(dt, limits, speed_factor)
  Horn.super.update(self, dt, limits, speed_factor)
end
 

function Horn:__tostring()
  return "<Horn: " .. Horn.super.__tostring (self) .. ">"
end