require "sprites/bouncingsprite"

Club = BouncingSprite:extend()

function Club:new(game, x, y)
  Club.super.new(self, game, "club", x, y, 0.25, true, true)
  self:enableAnim (quads.club, 0, 4, 0.3)
end

function Club:__tostring()
  return "<Club: "..Club.super.__tostring (self) .. ">"
end