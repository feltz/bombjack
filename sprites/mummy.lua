require "sprites/walkingsprite"

Mummy = WalkingSprite:extend()

function Mummy:new(game, idle_quad, col_shader)
  local x, y = 0, SCREEN_H/4
  self.shader, self.explosion_color = col_shader, math.random(4)
  self.direction = {}
  if game.bombjack.x < SCREEN_W / 2 then
    x = BORDER+8+(game.floor.Mummy_X[2]-1)*8
  else
    x = BORDER+8+(game.floor.Mummy_X[1]-1)*8
  end
  self.idle_time = MUMMY_IDLE_TIME -- pause en secondes après l'apparition et avant le début du mouvement de la momie
  self.count_change_dir = 0
  self.curr_platform = game:getPlatformBelow(x)
  if self.curr_platform ~= nil then
    y = self.curr_platform.y - self.curr_platform.h-6
    self.on_the_floor = self.curr_platform
  end
  self.appearing, self.disappearing = true, false
  Mummy.super.new(self, game, "mummy", x, y, game.bombjack.hor_speed/4, game.bombjack.vert_speed, 3, .3, idle_quad)
  self:enableAnim (quads.ennemy_appearing, 1, 4, 0.5)
  TEsound.play (SOUNDS.mummy_appear, "static")
end

function Mummy:__tostring()
  return "<Mummy: direction="..tostring(self.direction).."\n"..Mummy.super.__tostring (self) .. ">"
end

function Mummy:ignoreCollision()
  return self.appearing or self.disappearing
end

function Mummy:update(dt, limits, speed_factor)
  local new_directions = {}
  Mummy.super.update(self, dt, limits, speed_factor, self.direction.left, self.direction.right, false, new_directions, self.appearing or self.disappearing)  
  if (self.direction.left and new_directions.right) or (self.direction.right and new_directions.left) then           
    -- On s'assure que les momies ne se bloquent pas si la plateforme est collée à un bord
    self.direction = new_directions
  end
  
  if not self.appearing then
    if self.on_the_floor then
      if type (self.on_the_floor) == "boolean" then -- alors on est sur le sol -> explosion
        if not self.disappearing then
          self.disappearing = true
          self.explosion_color = math.random(4) -- nouvelle couleur au hasard pour l'explosion de disparition
          self:enableAnim (quads.ennemy_appearing, 1, 4, 0.5)
        end
        if not self:isAnimEnabled() then -- animation terminée
          self.game:transformMummy (self)
        end
      else
        if self.curr_platform == nil then
          self.curr_platform = self.on_the_floor
        end
        if table.nb_elements (self.direction) == 0 then
          self.direction.right = true
        end
        if self.game.level.mummy_bouncing ~= nil and self.count_change_dir < self.game.level.mummy_bouncing then
          if self.direction.right and self.x+self.w >= self.curr_platform.x + self.curr_platform.w then
            self.x = self.curr_platform.x + self.curr_platform.w - self.w
            self.direction = {left = true}
            self.count_change_dir = self.count_change_dir + 1
          elseif self.direction.left and self.x <= self.curr_platform.x then
            self.x = self.curr_platform.x
            self.direction = {right = true}
            self.count_change_dir = self.count_change_dir + 1
          end
        end
      end
    else
      self.count_change_dir = 0
      -- On s'assure qu'il tombe bien en le poussant un peu à gauche ou à droite
      if self.direction.left then
        self.x = self.x - 2
      elseif self.direction.right then
        self.x = self.x + 2 
      end
      if #TEsound.findTag("mummy_fall") == 0 then
        TEsound.play (SOUNDS.mummy_fall, "static", "mummy_fall")
      end
      self.curr_platform, self.direction = nil, {}
    end
  else
    if not self:isAnimEnabled() then -- animation terminée
      self.idle_time = self.idle_time - dt
      self:enableIdle (quads.mummy_idle)
      if self.idle_time < 0 then
        self.appearing = false
      end
    end
  end
end

function Mummy:draw (sprite_map, sprite_near_map)
  local x, y = self.x, self.y
  if (self.appearing and self.idle_time == MUMMY_IDLE_TIME) or self.disappearing then
    self.shader:sendColor("fromColors", unpack (colors.MummyFromColors))
    self.shader:sendColor("toColors", unpack (colors.MummyToColors[self.explosion_color]))
    love.graphics.setShader(self.shader)
    if self.appearing then -- On décale de 8 pixels pour centrer la grosse l'explosion
      self.x = x - 8
      self.y = y - 8
    elseif self.disappearing then
      self.x = x - 8
    end
    Mummy.super.draw(self, sprite_near_map)
    love.graphics.setShader()
    self.x, self.y = x, y
  else
    Mummy.super.draw(self, sprite_map)
  end
end