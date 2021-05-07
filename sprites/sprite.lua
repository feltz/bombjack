Sprite = Object:extend()

function Sprite:new (x, y, w, h)
  self.x, self.y, self.w, self.h = x, y, w, h
end

function Sprite:__tostring()
  return "<Sprite: x="..tostring (round(self.x))..', y='..tostring (round(self.y))..', w='..tostring (self.w)..', h='..tostring (self.h)..">"
end