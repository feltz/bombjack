require "sprites/animatedsprite"

Bomb = AnimatedSprite:extend()

function Bomb:new (x, y, order, quad)
  Bomb.super.new(self, x, y, 6, 0.3, quad)
  self.order = order
end

function Bomb:__tostring()
  return "<Bomb: order="..tostring(self.order).."\n"..Bomb.super.__tostring (self) .. ">"
end