require "sprites/bouncingsprite"

Orb = BouncingSprite:extend()

function Orb:new(game, x, y)
  Orb.super.new(self, game, "orb", x, y, 0.25, false, true)
  self:enableAnim (quads.orb, 0, 7, 0.8)
end

function Orb:__tostring()
  return "<Orb: "..Orb.super.__tostring (self) .. ">"
end