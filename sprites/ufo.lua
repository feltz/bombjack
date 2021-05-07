require "sprites/movingsprite"

Ufo = MovingSprite:extend()

MV_STATES = {READY = 1, MOVING = 2, MOVING_BOUNCED = 3}

function Ufo:new(game, x, y)
  Ufo.super.new(self, game, "ufo", x, y, 5, .3)
  self.speed_fast, self.speed_slow = game.bombjack.hor_speed*.75, game.bombjack.hor_speed/4
  self.move_state = MV_STATES.READY
  self.vx = 0
  self:enableAnim (quads.ufo)
end

function Ufo:__tostring()
  return "<Ufo: vx=" .. tostring(self.vx) .. ", vy=" .. tostring(self.vy)
         .. "\n"..Bird.super.__tostring (self) .. ">"
end

function Ufo:update(dt, limits, speed_factor)

  local speed = self.speed_fast
  if self.move_state == MV_STATES.READY then
    self.move_state = MV_STATES.MOVING
    local angle_theta = math.atan2 (self.game.bombjack.y - self.y, self.game.bombjack.x - self.x)
    self.vx = math.cos (angle_theta)
    self.vy = math.sin (angle_theta)
    self.move_done = false
  end
  if calc_distance (self.game.bombjack.x, self.game.bombjack.x, self.x, self.y) < 50 then
    speed = self.speed_slow
  end
  self.oldx, self.oldy = self.x, self.y
  self.x = self.x + self.vx * speed * dt * speed_factor
  self.y = self.y + self.vy * speed * dt * speed_factor
  local new_directions = {}
  if table.nb_elements (Ufo.super.update(self, dt, limits, false, false, new_directions)) > 0 then    
    if self.move_state == MV_STATES.MOVING then
      self.vx, self.vy = -self.vx, -self.vy
      self.move_state = MV_STATES.MOVING_BOUNCED
    else
      self.move_state = MV_STATES.READY
    end
  end
end