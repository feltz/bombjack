require "sprites/movingsprite"

WalkingSprite = MovingSprite:extend()

-- Cette classe apporte, en plus des collisions et de l'animation apportées par les classes parent, le
-- déplacement en vol ou sur sol (ou plate-forme) avec la gestion du sprite adéquat en fonction du déplacement

function WalkingSprite:new(game, prefix, x, y, hor_speed, vert_speed, nb_anims, anim_duration, idle_quad)
  self.hor_speed, self.vert_speed = hor_speed, vert_speed
  WalkingSprite.super.new (self, game, prefix, x, y, nb_anims, anim_duration, idle_quad)
end

function WalkingSprite:__tostring()
  return "<WalkingSprite: hor_speed="..tostring(self.hor_speed)..", vert_speed="..tostring(self.vert_speed)
          .."\n"..WalkingSprite.super.__tostring (self) .. ">"
end

function WalkingSprite:defineQuad(isLeftDirection, isRightDirection)
  local directionStr = nil
  if isLeftDirection then
    directionStr = 'left'
  elseif isRightDirection then
    directionStr = 'right'
  end
  
  if self.on_the_floor then
    if isLeftDirection or isRightDirection then
      self:enableAnim (quads[self.prefix .. "_move_" .. directionStr])
    else
      self:enableIdle (quads[self.prefix .. "_idle"]) 
    end
  else
    if self.vy > 0 then 
      if isLeftDirection or isRightDirection then 
        self:enableIdle (quads[self.prefix .. "_flying_" .. directionStr])
      else
        self:enableIdle (quads[self.prefix .. "_flying"])
      end
    elseif self.vy < 0 then
      if isLeftDirection or isRightDirection then 
        self:enableIdle (quads[self.prefix .. "_falling_" .. directionStr])
      else
        self:enableIdle (quads[self.prefix .. "_falling"])
      end
    end
  end    
end

function WalkingSprite:moveMe(dt, speed_factor, isLeftDirection, isRightDirection, halfGravity)
  self.oldx, self.oldy = self.x, self.y
  if isLeftDirection then
    self.x = self.x - self.hor_speed * speed_factor * dt     
  elseif isRightDirection then
    self.x = self.x + self.hor_speed * speed_factor * dt 
  end
  if not self.on_the_floor then
    if halfGravity and self.vy > 0 then -- On va plus haut si le curseur Haut est actionné
      self.vy = self.vy - (GRAVITY/2) * dt * self.vert_speed
    else
      self.vy = self.vy - GRAVITY * dt * self.vert_speed
    end
    self.y = self.y - self.vy * dt
  end  
end

function WalkingSprite:update(dt, limits, speed_factor, isLeftDirection, isRightDirection, isUpDirection, new_directions, dontChangeAnim)
  self:moveMe(dt, speed_factor, isLeftDirection, isRightDirection, isUpDirection)
  WalkingSprite.super.update(self, dt, limits, isLeftDirection, isRightDirection, new_directions)
  if not dontChangeAnim then
    self:defineQuad(isLeftDirection, isRightDirection)    
  end
  return new_directions
end