require "sprites/bouncingsprite"

Sphere = BouncingSprite:extend()

function Sphere:new(game, x, y)
  Sphere.super.new(self, game, "sphere", x, y, 0.25, true, false)
  self:enableAnim (quads.sphere, 0, 8, .3)
end

function Sphere:__tostring()
  return "<Sphere: " .. Sphere.super.__tostring (self) .. ">"
end