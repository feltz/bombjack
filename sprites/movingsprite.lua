require "sprites/animatedsprite"

MovingSprite = AnimatedSprite:extend()

-- Cette classe, en plus de l'animation des sprites apportés dans la classe parent, gère la collision des
-- sprites avec les bords et les plates-formes en évitant leur dépassement. La fonction update retourne la direction opposée à 
-- la collision

function MovingSprite:new(game, prefix, x, y, nb_anims, anim_duration, idle_quad)
  MovingSprite.super.new (self, x, y, nb_anims, anim_duration, idle_quad)
  self.vy = 0
  self.on_the_floor = false
  self.prefix, self.game = prefix, game
  self.oldx, self.oldy = x, y
end

function MovingSprite:__tostring()
  return "<MovingSprite: vy="..tostring(self.vy)..", on_the_floor="..tostring(self.on_the_floor)
          .."\n"..MovingSprite.super.__tostring (self) .. ">"
end

function MovingSprite:draw(sprite_map)
  if DEBUG_COLLISIONS then
    local old_r, old_g, old_b, old_a = love.graphics.getColor ()
    love.graphics.setColor ({1, 0, 1, 1})
    love.graphics.rectangle ("line", self.x, self.y, self.w, self.h)  
    love.graphics.setColor (old_r, old_g, old_b, old_a)  
  end
  MovingSprite.super.draw (self, sprite_map)
end


function MovingSprite:checkCollisionWithBorders(dt, limits, new_directions)
  if self.y > limits.bottom - self.h then
    self.y = limits.bottom - self.h
    self.vy = 0
    self.on_the_floor = true
    new_directions.up = true
  elseif self.y < limits.up then
    self.y = limits.up
    self.vy = 0 
    new_directions.down = true
  end
  
  if self.x <= limits.left then
    self.x = limits.left
    new_directions.right = true
  end
  
  if self.x + self.w >= limits.right then
    self.x = limits.right - self.w
    new_directions.left = true
  end
end

function MovingSprite:checkCollisionWithPlatforms(dt, new_directions)
  if type (self.on_the_floor) == "table" then -- alors on_the_floor contient un objet Platform
    local p = self.on_the_floor
    if self.x+self.w <= p.x or self.x >= p.x+p.w then
      self.on_the_floor = false
      if self.x+self.w <= p.x then
        self.x = self.x - 3 -- On force le destin...
      else
        self.x = self.x + 3 -- On force le destin...
      end
      new_directions.falling = true
    end
  end
  for _, p in ipairs (self.game.platforms) do
    -- Si le sprite est bien positionné en Y, on vérifie si on entre dans la plateforme par la gauche ou la droite
    if p.y + p.h > self.y and p.y < self.y +self.h then
      if self.x + self.w > p.x and (self.x + self.w - p.x) < p.w / 2 then
        self.x = self.oldx
        new_directions.left = true
      elseif self.x < p.x + p.w and (p.x + p.w - self.x) < p.w / 2 then
        self.x = self.oldx
        new_directions.right = true
      end
    end  
    
    -- Si le sprite est bien positionné en X, on vérifie si on entre dans la plateforme par le haut ou le bas
    if self.x + self.w > p.x and self.x < p.x + p.w then
      if self.y + self.h > p.y and (self.y + self.h - p.y) < p.h / 2 then
        self.vy = 0
        self.on_the_floor = p
        self.y, self.oldy = p.y - self.h, p.y - self.h
        new_directions.up = true
      elseif self.y < p.y + p.h and (p.y + p.h - self.y) < p.h / 2 then
        self.vy = 0
        self.y = self.oldy
        new_directions.down = true
      end
    end
  end
end

function MovingSprite:checkCollisionWithSprite(sprite)
  local offset_me = 3 -- Dans le jeu original, les côtés du bombjack peuvent se superposer un peu aux autres objets
  local offset_bomb = 0 -- La mêche de 5 pixels n'est pas pris en compte pour la collision
  if sprite:is(Bomb) then
    local offset_bomb = 5
  end
  return self.x+offset_me < sprite.x+sprite.w and
         sprite.x < self.x+self.w-offset_me and
         self.y+offset_me < sprite.y+sprite.h and
         sprite.y+offset_bomb < self.y+self.h-offset_me
end

function MovingSprite:update(dt, limits, isLeftDirection, isRightDirection, new_directions)
  self:checkCollisionWithBorders (dt, limits, new_directions)
  self:checkCollisionWithPlatforms (dt, new_directions)
  MovingSprite.super.update(self, dt)
  return new_directions
end