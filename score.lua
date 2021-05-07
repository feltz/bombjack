Score = Object:extend()

function Score:new ()
  self.score, self.intern_power_score, self.catched, self.ennemy_count = 0, 0, 0, 0
  self.next_fiveT, self.fiveT_reached, self.bonus_active = BONUS_LIMIT, false, false
  self.level_score = ''
  self.multiplier = 1
  self.quads_to_draw = {}
end

function Score:restartLevel ()
  self.bonus_active = false
end

function Score:nextLevel()
  self.multiplier = 1
  self.catched = 0
  self.level_score = ''
  self.next_fiveT = (math.floor(self.score/BONUS_LIMIT) + 1) * BONUS_LIMIT
end

function Score:checkFiveT()
  if self.score >= self.next_fiveT then
    if not self.bonus_active then
      self.fiveT_reached = true
    end
    self.next_fiveT = self.next_fiveT + BONUS_LIMIT
  end
end

function Score:jump() 
  self.score = self.score + 10 * self.multiplier
  self.level_score = self.level_score .. 'J' .. tostring (self.multiplier)
  self:checkFiveT()
end

function Score:touch_plateform() 
  self.score = self.score + 10 * self.multiplier
  self.level_score = self.level_score .. 'T' .. tostring (self.multiplier)
  self:checkFiveT()
end

function Score:falling() 
  self.score = self.score + 10 * self.multiplier
  self.level_score = self.level_score .. 'F' .. tostring (self.multiplier)  
  self:checkFiveT()
end

function Score:applySpecialBonusScore ()
  if self:getSpecialBonusScore() > 0 then
    self.level_score = self.level_score .. 'X' .. tostring (self.catched%10)
  end
end

function Score:increaseSpecialBonusScore()
  self.score = self.score + 1000
end

function Score:getSpecialBonusScore ()
  if self.catched == 20 then
    return 10000
  elseif self.catched == 21 then
    return 20000
  elseif self.catched == 22 then
    return 30000
  elseif self.catched == 23 then
    return 50000
  else
    return 0
  end
end

function Score:isBonusReached()
  if self.fiveT_reached and self.multiplier < 5 then
    self.fiveT_reached = false
    self.bonus_active = true    
    return true
  else
    return false
  end
end

function Score:catchBonus(bonus)
  self.score = self.score + bonus:getScore() * self.multiplier
  self.level_score = self.level_score .. bonus:getLevelScore() .. tostring (self.multiplier)  
  if self.score >= self.next_fiveT then
    self.next_fiveT = self.next_fiveT + BONUS_LIMIT
  end  
  if not bonus:isNewLife() then
    self.multiplier = self.multiplier + 1
  end
  self.bonus_active = false
end

function Score:catchBomb(bomb, is_power_active) 
  if bomb:isAnimEnabled () then
    self.level_score = self.level_score .. 'c' .. tostring (self.multiplier)  
    self.score = self.score + 200 * self.multiplier
    self.catched = self.catched + 1
    if not is_power_active then 
      self.intern_power_score = self.intern_power_score + 1
    end
  else
    self.level_score = self.level_score .. 'b' .. tostring (self.multiplier)  
    self.score = self.score + 100 * self.multiplier
    if not is_power_active then 
      self.intern_power_score = self.intern_power_score + 0.5
    end
  end
  self:checkFiveT()
end

function Score:isPowerScoreReached()
  return self.intern_power_score >= 10
end

function Score:powerCreated()
  self.intern_power_score = self.intern_power_score - 10
end  

function Score:powerTouched(power)
  self.score = self.score + ENNEMY_POINTS [power.color_index] * self.multiplier
  self.level_score = self.level_score .. string.char(110 + power.color_index) .. tostring (self.multiplier)  
  self:checkFiveT()
end  

function Score:killEnnemy()
  self.ennemy_count = self.ennemy_count + 1
  self.score = self.score + ENNEMY_POINTS [self.ennemy_count] * self.multiplier
  self.level_score = self.level_score .. string.char(110 + self.ennemy_count) .. tostring (self.multiplier)  
  self:checkFiveT()
end

function Score:getEnnemyScore ()
  return ENNEMY_POINTS[self.ennemy_count]
end

function Score:startFreezeTime()
  self.ennemy_count = 0
end

function Score:draw()
  gui:writeNumber (self.score, 64, 8)
end