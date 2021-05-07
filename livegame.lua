require "score"
require "astar"
require "specialbonus"
require "gameover"
require "newlife"
require "sprites/mummy"
require "sprites/bomb"
require "sprites/sphere"
require "sprites/bird"
require "sprites/ufo"
require "sprites/horn"
require "sprites/orb"
require "sprites/club"
require "sprites/power"
require "sprites/bonus"
require "sprites/startlogosprite"

LiveGame = Object:extend()

function LiveGame:new (gui, highscores, quads, col_shader, levels)
  self.gui, self.highscores, self.quads = gui, highscores, quads
  self.bombs, self.platforms, self.floor, self.tansients, self.bonus_objects = {}, {}, {}, {}, {power = nil, bonus = nil}
  self.curr_level, self.level, self.level_grid, self.curr_mummy_transform = 1, nil, {}, 1
  self.speed_factor_idx, self.speed_time = 1, 0
  self.freeze_time, self.freeze_end_time = 0, 0
  self.start_logo = nil
  self.special_bonus = nil
  self.shader = col_shader
  self.bombjack = Bombjack (self)
  self:restartGame ()
  self.pause = false
end

function LiveGame:restartGame()
  self.game_over = nil
  self.score = Score()
  self.curr_level = START_LEVEL
  self:setupLevel ()
  self:restartLevel()
  self.bombjack:resetLifes()
end

function LiveGame:restartLevel()
  self.ennemies, self.backup_ennemies, self.transients, self.bonus_objects = {}, {}, {}, {power = nil, bonus = nil}
  self.mummy_time, self.mummies_created = 0, 0
  self.speed_time = 0
  self.curr_mummy_transform = 1
  self.score:restartLevel()
  self.bombjack:reset()
  self:disableAllBombs()
  Sphere.count = 0
  self.start_logo = { StartLogoSprite ("left"), StartLogoSprite ("right") }
end

function LiveGame:setupLevel()
  self.level = levels.Levels[self.curr_level]
  self.level_grid = {}
  self.speed_factor_idx = self.level.init_speed_factor
  for i=1,13 do 
    table.insert (self.level_grid, {})
    for j=1,13 do
      table.insert (self.level_grid[i], 0)
    end 
  end
  self:getBombs (levels[self.level.letter].Block, quads)
  self:readPlatforms (levels[self.level.letter].Floor) -- Met également à jour self.level_grid avec des 1 pour les plateformes
  self.floor = levels[self.level.letter].Floor  
  table.insert (self.level_grid, 1, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1})
  table.insert (self.level_grid, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1})
  for i=2,14 do
    table.insert (self.level_grid[i], 1, 1)
    table.insert (self.level_grid[i],  1)
  end
  self.astar = AStar (self.level_grid)
end

function LiveGame:startNextLevel(force)
  if self.score:getSpecialBonusScore () > 0 and not (force or false) then
    TEsound.stop ("music")
    self.special_bonus = SpecialBonus (self.quads, self, self.score)
    self.score:applySpecialBonusScore()
  else
    self.highscores:send_intermediate_score(self.curr_level, self.score.level_score, self.score.score)
    self.special_bonus = nil
    self.curr_level = self.curr_level + 1
    if self.curr_level > LAST_LEVEL then
      self.curr_level = 1
    end
    self:setupLevel ()
    self:restartLevel()
    self.score:nextLevel()
  end
end

function LiveGame:gameover()
  self.game_over = Gameover (self.bombjack.x, self.bombjack.y, self)
end

function LiveGame:createMissingBirds()
  local count_birds = 0
  for _, v in ipairs (self.ennemies) do
    if v.prefix == "bird" then
      count_birds = count_birds + 1
    end
  end
  for i=count_birds+1,self.level.birds do
    table.insert (self.ennemies, i == 1 and Bird(self) or Bird(self, self.ennemies[#self.ennemies]))
  end  
end

function LiveGame:transformMummy (mummy)
  for idx, ennemy in ipairs (self.ennemies) do
    if ennemy == mummy then
      table.remove (self.ennemies, idx)
      local ennemy = self.level.mummies[self.curr_mummy_transform]
      if ennemy == "Sphere" then
        table.insert (self.ennemies, Sphere (self, mummy.x, mummy.y))
      elseif ennemy == "Ufo" then
        table.insert (self.ennemies, Ufo (self, mummy.x, mummy.y))
      elseif ennemy == "Horn" then
        table.insert (self.ennemies, Horn (self, mummy.x, mummy.y))
      elseif ennemy == "Orb" then
        table.insert (self.ennemies, Orb (self, mummy.x, mummy.y))
      elseif ennemy == "Club" then
        table.insert (self.ennemies, Club (self, mummy.x, mummy.y))
      end
      self.curr_mummy_transform = self.curr_mummy_transform + 1
    end
  end    
end

function LiveGame:activatePower()
  self.bonus_objects.power = Power(self)
  self.score:powerCreated()
  TEsound.pause ("music")
  TEsound.playLooping (SOUNDS.power_appearing, "static", "power")  
end

function LiveGame:bombjackAction (action)
  if (action == "jump" or action == "touch_plateform" or action == "falling") and self.bonus_objects.power then
    self.bonus_objects.power:changeColor()
  end
  if action == "jump" then
    self.score:jump()
    TEsound.play (SOUNDS.jump, "static")
  elseif action == "touch_plateform" then
    self.score:touch_plateform()
  elseif action == "falling" then
    self.score:falling()
  end
end

function LiveGame:addMiniscores (origin_sprite, simple_score, multiplier, delay)
  local x, y, quad = origin_sprite.x, origin_sprite.y, nil  
  for i, value in ipairs ({100, 200, 300, 500, 800, 1000, 1200, 2000, 3000, 5000}) do
    if simple_score == value then
      quad = quads.scores[i]
    end
  end
  local miniscore = newMiniscore (x, y, quad, delay)
  table.insert (self.transients, miniscore)
  if multiplier > 1 then
    quad = quads.multipliers[multiplier - 1]
    if simple_score < 1000 then
      local _, _, quad_w, _ = quad:getViewport()
      x, y = x + origin_sprite.w - quad_w, y + miniscore.h
    else
      x = x + miniscore.w
    end
    table.insert (self.transients, newMiniscore (x, y, quad, delay))  
  end
  return miniscore
end

function LiveGame:catchBonus()
  local bonus = self.bonus_objects.bonus
  TEsound.play (SOUNDS.take_bonus, "static")
  self.score:catchBonus(bonus)
  local power_explosion = newPowerExplosion (bonus.x-8, bonus.y-8)
  table.insert (self.transients, power_explosion)
  local miniscore = self:addMiniscores (bonus, bonus:getScore(), self.score.multiplier, power_explosion.anim_duration)
  if bonus:isNewLife() then
    table.insert (self.transients, Newlife (self, miniscore.anim_duration))    
  end
  self.bonus_objects.bonus = nil  
end

function LiveGame:catchBomb(bomb, index)
  if bomb:isAnimEnabled() then
    TEsound.play (SOUNDS.take_exploding_bomb, "static")
  else
    TEsound.play (SOUNDS.take_bomb, "static")
  end
  table.remove (self.bombs, index)
  table.insert (self.transients, newBombExplosion (bomb.x, bomb.y))  
  if bomb:isAnimEnabled() then
    self:addMiniscores (bomb, 200, self.score.multiplier)
  end
  local bombs_nomore_taken_into_account = self.bonus_objects.power ~= nil or self.bombjack.state == STATES.PLAYING_ENNEMY_FREEZE
  self.score:catchBomb (bomb, bombs_nomore_taken_into_account)
  if not bombs_nomore_taken_into_account and self.score:isPowerScoreReached() then
    self:activatePower()
  end  
end

function LiveGame:isPowerOrFreezeTime()
  return self.bombjack.state == STATES.PLAYING_ENNEMY_FREEZE or self.bonus_objects.power
end

function LiveGame:startFreezeTime()
  local power = self.bonus_objects.power
  self:addMiniscores (power, power:getScore(), self.score.multiplier)
  table.insert (self.transients, newPowerExplosion (power.x-8, power.y-8))
  self.score:powerTouched (power)
  self.bombjack:startColorRotation (colors.PowerToColors[power.color_index])
  self.bonus_objects.power = nil
  self.backup_ennemies = self.ennemies
  self.ennemies = {}
  for _, ennemy in ipairs (self.backup_ennemies) do
    table.insert (self.ennemies, newEnnemyFreeze (ennemy.x, ennemy.y))
  end
  self.bombjack.state = STATES.PLAYING_ENNEMY_FREEZE
  self.freeze_time, self.freeze_end_time = 4, 1
  self.score:startFreezeTime()
  TEsound.stop ("power")
  TEsound.play (SOUNDS.got_power, "static", "power", nil, nil, function () TEsound.resume ("music") end)
end

function LiveGame:killEnnemy(ennemy, index_of_ennemy)
  self.score:killEnnemy()
  local explosion = newEnnemyExplosion (ennemy.x-8, ennemy.y-8)
  table.insert (self.transients, explosion)
  self:addMiniscores (ennemy, self.score:getEnnemyScore(), self.score.multiplier, explosion.anim_duration)
  table.remove (self.ennemies, index_of_ennemy)
  table.remove (self.backup_ennemies, index_of_ennemy)
  if ennemy.prefix ~= "bird" then -- Les birds sont recréés via l'appel à createMissingBirds dans l'update
    self.mummies_created = self.mummies_created - 1
  end  
  TEsound.play (SOUNDS.kill_ennemy, "static", "kill_ennemy") 
end

function LiveGame:update(dt, limits)
  if self.pause then
    return
  elseif self.special_bonus ~= nil then
    self.special_bonus:update(dt)
    if (self.special_bonus:isDone()) then
      self:startNextLevel(true)
    end
  elseif self.game_over then
    self.game_over:update (dt)
  elseif self.start_logo then
    for _, logo in ipairs (self.start_logo) do logo:update(dt) end
    if self.start_logo[1]:isDone() then
      self.start_logo = nil
      self.mummy_time = INITIAL_MUMMY_DELTA * MUMMY_DELTA_FACTORS[self.speed_factor_idx]
    end
  else  
    self.speed_time = self.speed_time + dt
    if self.speed_time > SPEED_INC_TIME then
      self.speed_factor_idx = self.level.init_speed_factor+1
    end
    if #TEsound.findTag("music") == 0 and self.bombjack:isAlive() and #TEsound.findTag("power") == 0 then
      TEsound.play (MUSICS[1], "stream", "music") 
    end  
    for _, bomb in ipairs (self.bombs) do bomb:update(dt) end  
    for idx, trans in ipairs (self.transients) do
      trans:update(dt)
      if trans:isDone() then
        table.remove (self.transients, idx)
      end
    end
    if self.score:isBonusReached() then
      self.bonus_objects.bonus = Bonus (self)
    end
    if self.bombjack.state ~= STATES.PLAYING_ENNEMY_FREEZE then
      self:createMissingBirds()
      self.mummy_time = self.mummy_time + dt
      if self.mummy_time > INITIAL_MUMMY_DELTA * MUMMY_DELTA_FACTORS[self.speed_factor_idx] and self.mummies_created < #self.level.mummies then
        self.mummy_time = self.mummy_time - INITIAL_MUMMY_DELTA * MUMMY_DELTA_FACTORS [self.speed_factor_idx]
        self.mummies_created = self.mummies_created + 1
        table.insert (self.ennemies, Mummy (self, quads.mummy_idle, self.shader))
      end
    else
      self.freeze_time = self.freeze_time - dt
      if self.freeze_time < 0 then
        self.freeze_end_time = self.freeze_end_time - dt
        if self.freeze_end_time < 0 then
          self.bombjack.state = STATES.PLAYING
          self.bombjack:stopColorRotation()
          self.ennemies = self.backup_ennemies
        end
      end
    end
    for _, ennemy in ipairs (self.ennemies) do ennemy:update(dt, limits, (1/SPEED_FACTORS[self.speed_factor_idx])) end 
    for _, obj in pairs (self.bonus_objects) do obj:update (dt, limits) end
    self.bombjack:update(dt, limits)
  end
end  

function LiveGame:draw(sprite_map, sprite_near_map, screens_map, screens_tab)
  self.score:draw()
  gui:drawLifes (self.bombjack.lifes)  
  if self.special_bonus ~= nil then
    self.special_bonus:draw(sprite_near_map)
  else
    love.graphics.draw (screens_map, screens_tab[self.level.screen], BORDER, BORDER)
    for _, bomb in ipairs (self.bombs) do bomb:draw(sprite_map) end
    for _, trans in ipairs (self.transients) do trans:draw(sprite_map) end  
    for _, ennemy in ipairs (self.ennemies) do
      if self.bombjack.state ~= STATES.PLAYING_ENNEMY_FREEZE 
         or (self.freeze_time > 0 or (self.freeze_time < 0 and (self.freeze_end_time * 10) % 2 < 1))  then
        ennemy:draw(sprite_map, sprite_near_map)
      end
    end  
    Platform.drawBorders(self.level.color)
    for _, p in ipairs (self.platforms) do p:draw() end
    if self.start_logo then
      for _, logo in ipairs (self.start_logo) do logo:draw(self.shader, self.gui, sprite_near_map) end
    else
      for _, obj in pairs (self.bonus_objects) do obj:draw (sprite_map, sprite_near_map) end
      self.bombjack:draw(self.gui, sprite_map, sprite_near_map)
      self.astar:draw()
    end
    if self.game_over then self.game_over:draw (self.gui) end
  end
end

function LiveGame:getBombs (level_grid, quads)
  self.bombs = {}
  for col_no, line in ipairs (level_grid) do
    for line_no, z in ipairs (line)  do
      if z > 0 then
        table.insert (self.bombs, Bomb (BORDER + 8 + (line_no-1) * 24, BORDER + 8 + (col_no-1) * 24, z, quads.bomb))
      end
    end
  end  
end

function LiveGame:readPlatforms (level_grid)
  self.platforms = {}
  if self.level.screen ~= 5 then -- le niveau Californie est un niveau sans plateformes
    for _, p in ipairs (level_grid.Platforms) do
      platform = Platform (p.x, p.y, p.l, p.Sym, p.corners, self.level.color)
      table.insert (self.platforms, platform)
      for i=1, p.l do
        if platform.direction == 'H' then
          self.level_grid[math.ceil((p.x+i-1)/2)][math.ceil(p.y/2)] = 1
        else
          self.level_grid[math.ceil((p.x+1)/2)][math.ceil((p.y-i)/2)] = 1
        end
      end
    end
  end
end

function LiveGame:getPlatformBelow (x)
  local miny = SCREEN_H
  local p_to_return = nil
  for _, p in ipairs (self.platforms) do
    if x >= p.x and x <= p.x+p.w then
      if p.y <= miny then
        miny = p.y
        p_to_return = p
      end
    end
  end
  return p_to_return
end

function LiveGame:disableAllBombs ()
  for _, bomb in ipairs (self.bombs) do
    if bomb:isAnimEnabled() then
      bomb:enableIdle()
    end
  end
end

function LiveGame:getNextBombToActivate (order_min)
  if table.getn (self.bombs) == 0 then
    return nil
  elseif table.getn (self.bombs) == 1 then
    return self.bombs[1]
  else
    local bomb_to_return = nil
    for index, bomb in ipairs (self.bombs) do
      if bomb.order >= order_min and (bomb_to_return == nil or bomb.order < bomb_to_return.order) then
        bomb_to_return = bomb
      end
    end
    if bomb_to_return then
      return bomb_to_return
    else
      return self:getNextBombToActivate (1)
    end
  end
end

function LiveGame:keypressed(key)
  if key == "p" then    
    self.pause = not self.pause
  end
  
  if not self.pause then
    if self.game_over == nil then
      self.bombjack:keypressed(key)
    else
      if key == "escape" or key == "1" then
        self:restartGame()
      end
    end
  end
end