require "sprites/movingsprite"

Bird = AnimatedSprite:extend()

function Bird:new(game, first_bird)
  local x, y
  self.left, self.up = false, false
  self.same_direction = -1 -- lorsqu'il vaut trois, l'oiseau fait une pause
  self.bird_pause_time = 0
  self.blink_color_idx, self.blink_color_time = 1, 0
  if love.keyboard.isDown ("left") or love.keyboard.isDown ("right") then
    self.left = love.keyboard.isDown ("right")
    if first_bird then
      self.up = not first_bird.up
    else
      self.up = math.random(0, 1) == 0
    end
  else
    self.left = math.random(0, 1) == 0
    self.up = math.random(0, 1) == 0
    if first_bird and self.left == first_bird.left and self.up == first_bird.up then
      self.up = not self.up
    end
  end
  
  if self.left then x = BORDER+8+2 else x = SCREEN_W - BORDER - 24 +2 end
  if self.up then y = BORDER+8 else y = SCREEN_H - BORDER - 24 + 2 end
  self.game = game
  self.distance_done = 9999
  Bird.super.new(self, x, y, 3, .3, nil, nil, 0)
  self.hor_speed, self.vert_speed = game.bombjack.hor_speed/4, game.bombjack.vert_speed/4
  self.vx, self.vy = 0, 0
  self.bj_oldx, self.bj_oldy = 0, 0
  self.path = {}
  self.prefix = "bird"
end

function Bird:setAnimation()
  if self.vx == -1 then 
    self:enableAnim (quads.bird_move_left)
  elseif self.vx == 1 then 
    self:enableAnim (quads.bird_move_right)
  else
    self:enableAnim (quads.bird_move_vertical)
  end
end

function Bird:setDirection()
  if #self.path == 0 or (math.abs (self.game.bombjack.x-self.bj_oldx) > 8 or math.abs (self.game.bombjack.y-self.bj_oldy) > 8) then 
    self.same_direction = -1
    self.path = self.game.astar:getPath ({round (self.x/16), round (self.y/16)}
                                       , {round ((self.game.bombjack.x)/16), round((self.game.bombjack.y)/16)})
    self.bj_oldx, self.bj_oldy = self.game.bombjack.x, self.game.bombjack.y
  end
  if self.path[1][1] < round(self.x/16) then 
    if self.vx == -1 then self.same_direction = self.same_direction + 1 end
    self.vx = -1
    self.vy = 0
  elseif self.path[1][1] > round(self.x/16) then 
    if self.vx == 1 then self.same_direction = self.same_direction + 1 end
    self.vx = 1
    self.vy = 0
  else
    if self.path[1][2] < round(self.y/16) then 
      if self.vy == -1 then self.same_direction = self.same_direction + 1 end
      self.vy = -1
    else 
      if self.vy == 1 then self.same_direction = self.same_direction + 1 end
      self.vy = 1
    end
    self.vx = 0
  end
  table.remove (self.path, 1)
  self.distance_done = 0
end

function Bird:__tostring()
  return "<Bird: vx="..tostring(self.vx)..", vy="..tostring(self.vy)..", dist="..tostring(self.distance_done)
         .."\n path = " .. table.val_to_str (self.path)
         .."\n"..Bird.super.__tostring (self) .. ">"
end

function Bird:update(dt, limits, speed_factor)
  self.blink_color_time = self.blink_color_time + dt
  if self.blink_color_time > 0.06 then
    self.blink_color_time = self.blink_color_time - 0.06
    self.blink_color_idx = self.blink_color_idx + 1
    if self.blink_color_idx > #colors.BirdToColors then
      self.blink_color_idx = 1
    end
  end
  if self.same_direction == 3 and self.bird_pause_time < BIRD_PAUSE / speed_factor then
    if self.bird_pause_time == 0 then
      if self.vx ~= 0 then
        self:enableAnim (quads.bird_move_vertical) 
      else
        self:enableAnim (quads.bird_move_right) 
      end
    end
    self.bird_pause_time = self.bird_pause_time + dt
    if self.bird_pause_time > BIRD_PAUSE / speed_factor then
      self.bird_pause_time = 0
      self.same_direction = -1
      self:setAnimation()
    end
  else    
    local dx, dy = self.vx * self.hor_speed * dt * speed_factor, self.vy * self.vert_speed * dt * speed_factor
    self.x = self.x + dx
    self.y = self.y + dy
    self.distance_done = self.distance_done + math.abs(dx) + math.abs(dy)
    if self.distance_done > 16 then
      self:setDirection()
      self:setAnimation()
    end
  end
  Bird.super.update(self, dt)
end

function Bird:draw (sprite_map, sprite_near_map)
  self.game.shader:sendColor("fromColors", {1, 0, 0, 1})
  self.game.shader:sendColor("toColors", colors.BirdToColors[self.blink_color_idx])
  love.graphics.setShader(self.game.shader)
  Bird.super.draw(self, sprite_near_map)
  love.graphics.setShader()

  if DEBUG_BIRD then
    if self.path then 
      for _, v in ipairs (self.path) do
        love.graphics.rectangle ("fill", v[1]*16, v[2]*16, 3, 3)
      end
    end
  end
end