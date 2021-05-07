require "sprites/walkingsprite"
require "sprites/bomb"
require "colorrotator"

Bombjack = WalkingSprite:extend()
Bombjack:implement(ColorRotator) 

STATES = {PLAYING = 1, PLAYING_ENNEMY_FREEZE = 2, DANCING = 3, FALLING = 4, DYING = 5, END_OF_PLAY = 6, WINNING = 7}

function Bombjack:new(game)
  Bombjack.super.new(self, game, "bj", 0, 0, HOR_SPEED, VERT_SPEED, 4, 0.5, quads.bj_idle)
  self.lifes, self.state = nil, STATES.PLAYING
  self.waiting_for_display = 0
  self:initColorRotator()
  self:resetLifes ()
end

function Bombjack:resetLifes ()
  self.lifes = NB_LIFES - 1
end

function Bombjack:reset ()
  self.x, self.y = SCREEN_W / 2, SCREEN_H / 2 - 8
  self.quad = quads.bj_idle
  self.state = STATES.PLAYING
  self.on_the_floor = false
end

function Bombjack:__tostring()
  return "<Bombjack: lifes="..tostring(self.lifes).."\n"..Bombjack.super.__tostring (self) .. ">"
end

function Bombjack:checkCollisionWithBombs()
  local bomb_order_to_activate, curr_bomb_activated, bomb_to_remove, bomb_to_remove_idx = 0, nil, nil,0
  for index, bomb in ipairs (self.game.bombs) do
    if bomb:isAnimEnabled() then
      curr_bomb_activated = bomb
    end
    if self:checkCollisionWithSprite (bomb) then
      bomb_order_to_activate = bomb.order + 1
      bomb_to_remove = bomb
      bomb_to_remove_idx = index
    end
  end
  if table.getn (self.game.bombs) > 0 and bomb_order_to_activate > 0 then
    if (curr_bomb_activated == nil or bomb_to_remove == curr_bomb_activated) then
      self.game:getNextBombToActivate (bomb_order_to_activate):enableAnim (quads.bomb_activated)
    end
  end 
  if bomb_to_remove then
    self.game:catchBomb (bomb_to_remove, bomb_to_remove_idx)
  end
end

function Bombjack:checkCollisionWithBonus()
  if self.game.bonus_objects.power and self:checkCollisionWithSprite (self.game.bonus_objects.power) then
    self.game:startFreezeTime()
  elseif self.game.bonus_objects.bonus and self:checkCollisionWithSprite (self.game.bonus_objects.bonus) then
    self.game:catchBonus()
  end
end

function Bombjack:isAlive()
  return self.state == STATES.PLAYING or self.state == STATES.PLAYING_ENNEMY_FREEZE
end

function Bombjack:checkCollisionWithEnnemies()
  for index, ennemy in ipairs (self.game.ennemies) do
    if self:checkCollisionWithSprite (ennemy) then
      if self.state == STATES.PLAYING_ENNEMY_FREEZE then
        self.game:killEnnemy(ennemy, index)
      else
        self.lifes = self.lifes - 1
        self.state = STATES.DANCING
        self.vy = 0
        self:enableAnim (quads.bj_dancing, 2, 3, 0.5)
        TEsound.stop ("music")
        TEsound.stop ("power")
        TEsound.play (SOUNDS.touched, "static")
        return
      end
    end
  end
end

function Bombjack:checkWalking()
  if self.on_the_floor and (love.keyboard.isDown ("left") or love.keyboard.isDown ("right")) then
    if #TEsound.findTag ("walking") == 0 then
      TEsound.play (SOUNDS.walking, "static", "walking")
    end
  end
end

function Bombjack:update(dt, limits, plateforms)
  if self:isAlive() then
    self:checkWalking()
    local new_directions = {}
    Bombjack.super.update(self, dt, limits, 1
                        , love.keyboard.isDown ("left"), love.keyboard.isDown ("right"), love.keyboard.isDown ("up"), new_directions)
    if new_directions.down then
      self.game:bombjackAction ("touch_plateform")
    elseif new_directions.falling and not self.on_the_floor then
      self.game:bombjackAction ("falling")
    end
    self:checkCollisionWithBombs()
    if table.getn (self.game.bombs) == 0 then
      self.state = STATES.WINNING
      self.rotating_colors = nil
      self:enableAnim ({quads.bj_winning_stand, quads.bj_winning_left, quads.bj_winning_stand, quads.bj_winning_right
                       , quads.bj_winning_stand, quads.bj_winning_up
                       }
                       , 2, 6, 1.75)
      self.waiting_for_display = 3
      TEsound.stop ("music")
      TEsound.stop ("power")
      TEsound.play (SOUNDS.clear_level, "static")
      MovingSprite.super.update(self, dt, limits)
    end
    self:rotateColorTable(dt)
    self:checkCollisionWithBonus()
    self:checkCollisionWithEnnemies()
  elseif self.state == STATES.DANCING then
    if not self:isAnimEnabled() then
      self.state = STATES.FALLING
      self:enableAnim (quads.bj_PLF, 0, 4, 1)
    end
    MovingSprite.super.update(self, dt, limits)
  elseif self.state == STATES.FALLING then
    if self.on_the_floor then
      self.state = STATES.DYING
      self:enableAnim (quads.bj_dead, 1, 4, 1)
    end
    Bombjack.super.update(self, dt, limits, 1, false, false, false, {}, true) -- On exécute pas defineQuad
  elseif self.state == STATES.DYING then
    if not self:isAnimEnabled() then
      self.state = STATES.END_OF_PLAY
      self.waiting_for_display = 3
    end
    MovingSprite.super.update(self, dt, limits)
  elseif self.state == STATES.END_OF_PLAY then
    self.waiting_for_display = self.waiting_for_display - dt
    if self.waiting_for_display < 0 then
      if self.lifes < 0 then
        self.game:gameover()
      else      
        self.game:restartLevel()
      end
    end
  elseif self.state == STATES.WINNING then
    MovingSprite.super.update(self, dt, limits)
    self.waiting_for_display = self.waiting_for_display - dt
    if self.waiting_for_display < 0 then
      self.game:startNextLevel() 
    end
  end  
end

function Bombjack:draw (gui, sprite_map, sprite_near_map)
  if self.state ~= STATES.END_OF_PLAY then
    if self:getColorTable() then
      self.game.shader:sendColor("fromColors", unpack (colors.BombjackFromColors))
      self.game.shader:sendColor("toColors", unpack (self:getColorTable()))
      love.graphics.setShader(self.game.shader)
      Bombjack.super.draw(self, sprite_near_map)
      love.graphics.setShader()
    else
      Bombjack.super.draw(self, sprite_map)      
    end
  end
end

function Bombjack:keypressed(key)
  if self:isAlive() then
    if key == ("rctrl") or key == ("lctrl") or key == ("space") then
      if self.on_the_floor then
        self.vy = 220
        self.on_the_floor = false
        self.game:bombjackAction("jump")
      else
        self.vy = 0
      end
    end
  end
end