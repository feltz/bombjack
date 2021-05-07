require "sprites/sprite"

AnimatedSprite = Sprite:extend()

function AnimatedSprite:new (x, y, nb_anims, anim_duration, idle_quad, anim_quads, repeating, delay)
  AnimatedSprite.super.new(self, x, y, 0, 0)
  self.nb_anims, self.anim_duration, self.anim_quads, self.repeating = nb_anims, anim_duration, anim_quads, repeating or 0
  self.delay = delay or 0
  if idle_quad then
    self:enableIdle (idle_quad)
  end
  self.anim_counter, self.anim_index = 0, 1
  if self.nb_anims == 1 then
    _, _, self.w, self.h = self.anim_quads[1]:getViewport()
  end
end

function newMiniscore (x, y, score_quad, delay)
  return AnimatedSprite (x, y, 1, 0.5, nil, {score_quad}, 1, delay)
end

function newBombExplosion (x, y)
  return AnimatedSprite (x, y, 3, 0.15, nil, quads.bomb_explosion, 1)
end

function newPowerExplosion (x, y)
  return AnimatedSprite (x, y, 1, 0.25, nil, quads.power_explosions, 1)
end

function newEnnemyFreeze (x, y)
  return AnimatedSprite (x, y, 7, 0.35, nil, quads.ennemy_freezes)
end

function newEnnemyExplosion (x, y)
  return AnimatedSprite (x, y, 4, 0.25, nil, quads.ennemy_explosions, 1)
end

function AnimatedSprite:__tostring()
  return "<AnimatedSprite: nb_anims="..tostring(self.nb_anims)..", anim_duration="..tostring(self.anim_duration)
        ..", repeating="..tostring(self.repeating).."\n"..AnimatedSprite.super.__tostring (self) .. ">"
end

function AnimatedSprite:enableIdle (quad)
  self.anim_quads = nil
  self.idle_quad = quad or self.idle_quad 
  self.quad = self.idle_quad 
  _, _, self.w, self.h = self.quad:getViewport()
end

function AnimatedSprite:enableAnim (quads, repeating, nb_anims, anim_duration)
  self.anim_quads = quads or self.anim_quads
  self.repeating = repeating or self.repeating
  self.nb_anims = nb_anims or self.nb_anims
  self.anim_duration = anim_duration or self.anim_duration
  if self.anim_index >= #quads then
    self.anim_index = 1
  end
end

function AnimatedSprite:isAnimEnabled ()
  return self.anim_quads
end

function AnimatedSprite:isDone()
  return self.anim_quads == nil and self.quad == nil
end

function AnimatedSprite:draw(sprite_map)
  if self.quad then
    love.graphics.draw (sprite_map, self.quad, self.x, self.y)
  end
end

function AnimatedSprite:update(dt)
  self.delay = self.delay - dt
  if self.delay <= 0 and self.anim_quads then
    self.anim_counter = self.anim_counter + dt
    if self.anim_counter > self.anim_duration / self.nb_anims then
      self.anim_counter = 0
      self.anim_index = self.anim_index + 1
      if self.anim_index >= self.nb_anims + 1 then
        self.anim_index = 1
        self.repeating = self.repeating - 1 -- Si on départ on a un repeating de 0, alors il passe à -1 ce qui permet d'animer en boucle
        if self.repeating == 0 then
          self.anim_quads, self.quad = nil, nil
          return
        end
      end
    end  
    self.quad = self.anim_quads[self.anim_index]
    _, _, self.w, self.h = self.quad:getViewport()
  end
end