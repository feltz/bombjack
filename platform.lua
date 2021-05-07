require "sprites/sprite"

Platform = Sprite:extend()

function Platform:new (x, y, l, direction, corners, color)
  if direction == "H" then
    Platform.super.new(self, BORDER+8+(x-1)*8, BORDER+8+(y-1)*8, l * 8, 8)
  else
    Platform.super.new(self, BORDER+8+(x-1)*8, BORDER+8+(y-1)*8-8*l, 8, l * 8)
  end
  self.left_border = x == 1
  self.right_border = x+l == 27
  self.direction, self.color, self.corners = direction, color, corners or {}
  self.old_r, self.old_g, self.old_b, self.old_a = nil, nil, nil, nil
end

function Platform:__tostring()
  return "<Platform: direction="..tostring(self.direction).."\n"..Platform.super.__tostring (self) .. ">"
end

function Platform:draw()
  local old_r, old_g, old_b, old_a = love.graphics.getColor ()
  local offset
  for i, rgb in ipairs (colors[self.color]) do
    love.graphics.setColor (rgb)
    if i > 1 and i < 8 then offset = 1 else  offset = 0 end -- L'offset c'est pour l'arrondi
    if self.direction == "H" then
      if self.left_border or self.right_border then offset = offset + 1 end -- Lorsque la plateforme touche le bord de l'écran
      -- Les rajouts de 0.5 sont présents pour éviter les erreurs d'arrondi du scale
      love.graphics.line (self.x-(self.corners.corner_left and 0 or offset)+.5 -- Rajoute un arrondi sauf si accroché à une autre platf.
                        , self.y+i
                        , self.x+self.w+(self.corners.corner_right and 0 or offset)+.5 -- Idem pour l'arrondi
                        , self.y+i)
      if self.left_border and i >= 3 and i <= 5 then
        love.graphics.line (self.x-3+.5, self.y+i, self.x, self.y+i)
      elseif self.right_border and i >= 3 and i <= 5 then
        love.graphics.line (self.x+self.w+.5, self.y+i, self.x+self.w+3, self.y+i)
      end
    else -- self.direction == "V" 
      love.graphics.line (self.x+i, self.y-offset+.5, self.x+i, self.y+self.h+offset+.5)
      if self.corners.corner_up_middle and i >= 3 and i <= 5 then
        love.graphics.line (self.x+i, self.y, self.x+i, self.y-2+.5)
      elseif self.corners.corner_bottom_middle and i >= 3 and i <= 5 then
        love.graphics.line (self.x+i, self.y, self.x+i, self.y+2+.5)
      end

      if self.corners.corner_bottom_left then
        love.graphics.line (self.x+i, self.y+self.h+offset, self.x+i, self.y+self.h+offset+i) 
      end
      if self.corners.corner_bottom_right then
        love.graphics.line (self.x+i, self.y+self.h+offset, self.x+i, self.y+self.h-i+8+0.5) 
      end      
      if self.corners.corner_up_right then
        love.graphics.line (self.x+i, self.y+i-8, self.x+i, self.y+0.5)
      end
      if self.corners.corner_up_left then
        love.graphics.line (self.x+i, self.y-i+0.5, self.x+i, self.y-i+8+0.5)
      end
    end
  end
  if DEBUG_COLLISIONS then
    love.graphics.setColor ({1, 0, 1, 1})
    love.graphics.rectangle ("line", self.x, self.y, self.w, self.h)
  end  
  love.graphics.setColor (old_r, old_g, old_b, old_a)
end

function Platform.drawBorders(color_name)
  local old_r, old_g, old_b, old_a = love.graphics.getColor ()
  for i, rgb in ipairs (colors[color_name]) do
    love.graphics.setColor (rgb)
    love.graphics.line (BORDER+(i-1), BORDER+i, BORDER + 28*8- (i-1), BORDER+i)
    love.graphics.line (BORDER+(i-1), BORDER+i-.5, BORDER+(i-1), SCREEN_H - BORDER - (i-1))
    love.graphics.line (BORDER+(i-1-.5), SCREEN_H - BORDER - (i-1), BORDER + 28*8- (i-1), SCREEN_H - BORDER - (i-1))
    love.graphics.line (BORDER + 28*8- (i-1), BORDER+i-.5, BORDER + 28*8- (i-1), SCREEN_H - BORDER - (i-1)+.5)
  end
  love.graphics.setColor (old_r, old_g, old_b, old_a)
end