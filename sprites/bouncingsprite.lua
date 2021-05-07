require "sprites/movingsprite"

BouncingSprite = MovingSprite:extend()

-- Cette classe apporte, en plus des collisions et de l'animation apportées par les classes parent, le
-- déplacement en vol avec la gestion du sprite adéquat en fonction du déplacement

function BouncingSprite:new(game, prefix, x, y, init_speed_factor, horizontal_bouncing, vertical_bouncing)
  BouncingSprite.super.new(self, game, "sphere", x, y)  
  self.hor_bounding = horizontal_bouncing or false
  self.vert_bounding = vertical_bouncing or false
  self.hor_speed, self.vert_speed = HOR_SPEED * init_speed_factor, VERT_SPEED * init_speed_factor
  self.vx, self.vy = self.hor_speed, -self.vert_speed
  if self.hor_bounding then
    self.vx = 0
  elseif self.vert_bounding then
    self.vy = 0
  end
end

function BouncingSprite:__tostring()
  return "<BouncingSprite: vx="..tostring(self.vx)..", vy="..tostring(self.vy)
          .."\n"..BouncingSprite.super.__tostring (self) .. ">"
end

function BouncingSprite:update(dt, limits, speed_factor)
  if self.hor_bounding then 
    if self.game.bombjack.x > self.x then
      self.vx = self.vx + dt * self.hor_speed
      if self.vx > self.hor_speed then
        self.vx = self.hor_speed
      end
    else
      self.vx = self.vx - dt * self.hor_speed
      if self.vx < -self.hor_speed then
        self.vx = -self.hor_speed
      end
    end
  end
  if self.vert_bounding then 
    if self.game.bombjack.y > self.y then
      self.vy = self.vy + dt * self.vert_speed
      if self.vy > self.vert_speed then
        self.vy = self.vert_speed
      end
    else
      self.vy = self.vy - dt * self.vert_speed
      if self.vy < -self.vert_speed then
        self.vy = -self.vert_speed
      end
    end  
  end
  
  local new_directions = {}
  BouncingSprite.super.update(self, dt, limits, false, false, new_directions)
  
  if new_directions.up then
    self.vy = -self.vert_speed
  elseif new_directions.down then
    self.vy = self.vert_speed
  else
  
    if new_directions.left then
      self.vx = -self.hor_speed
    elseif new_directions.right then
      self.vx = self.hor_speed
    end
  end
  self.oldx, self.oldy = self.x, self.y
  self.x = self.x + self.vx * dt * (speed_factor or 1)
  self.y = self.y + self.vy * dt * (speed_factor or 1)
end