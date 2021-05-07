require "guitext"

SCORE_TIME = 0.1
TEMPO_BEGIN_TIME, TEMPO_END_TIME = 2, 1.5

BONUS_STATES = {begin_tempo = 1, countdown = 2, end_tempo = 3}

SpecialBonus = GUIText:extend()

function SpecialBonus:new (quads, game, main_score_obj)
  SpecialBonus.super.new (self, quads)
  self:attachGame (game)
  self.tempo_time, self.bonus_score, self.main_score = TEMPO_BEGIN_TIME, main_score_obj:getSpecialBonusScore(), main_score_obj
  self.state = BONUS_STATES.begin_tempo
  self.color_index, self.color_time = 1, WHITE_COLOR_TIME
  TEsound.playLooping (SOUNDS.special_bonus, "static", "special_bonus")
end

function SpecialBonus:draw (sprite_near_map) 
  local w, h = 160, 100
  local x, y = (SCREEN_W - w) / 2, (SCREEN_H - h) / 2
  
  self.game.shader:sendColor("fromColors", colors.BonusSpecialFromColors[self.color_index])
  self.game.shader:sendColor("toColors", {255, 255, 255, 255})
  love.graphics.setShader(self.game.shader)
  
  love.graphics.draw (sprite_near_map, self.quads.bonus_box_upper_left, x, y)
  love.graphics.draw (sprite_near_map, self.quads.bonus_box_upper_right, x + w - 16, y)
  love.graphics.draw (sprite_near_map, self.quads.bonus_box_bottom_right, x + w - 16, y + h - 8)
  love.graphics.draw (sprite_near_map, self.quads.bonus_box_bottom_left, x, y + h - 8)
  for i=1,16 do
    for j=1,10 do
      love.graphics.draw (sprite_near_map, self.quads.bonus_in_box, x + 8 + i*8, y + 8 + j*7.6)
    end
    love.graphics.draw (sprite_near_map, self.quads.bonus_box_upper, x + 8 + i*8, y)
    love.graphics.draw (sprite_near_map, self.quads.bonus_box_bottom, x + 8 + i*8, y + h - 8)
  end
  for i=1,10 do
    love.graphics.draw (sprite_near_map, self.quads.bonus_box_left, x, y + 8 + i*7.8) -- Pourquoi 7.8 ?
    love.graphics.draw (sprite_near_map, self.quads.bonus_box_right, x + w - 16, y + 8 + i*7.8)
  end
  love.graphics.setShader()    
  local interligne = 7.5
  self:writeText ("YOU'VE GOTTEN", x + 26, y + 24, {1, 1, 0})
  self:writeNumber (self.main_score.catched, x + 26 + 8, y + 24 + 2*interligne, self:getColorFromCycle3())
  self:writeText ("FIRE BOMBS.", x + 26 + 3*8, y + 24 + 2*interligne, {1, 1, 0})
  self:writeText ("SPECIAL BONUS", x + 26, y + 24 +5*interligne)
  if self.bonus_score > 0 then
    self:writeNumber (self.bonus_score, x + 26 + 7*8, y + 24 + 7*interligne, self:getColorFromCycle3())
    self:writeText ("_", x + 26 + 9*8, y + 24 +7*interligne) -- _ pour Pts 
  end
end

function SpecialBonus:isDone()
  if self.state == BONUS_STATES.end_tempo and self.tempo_time < 0 then
    TEsound.stop ("special_bonus")
    return true
  else
    return false
  end
end

function SpecialBonus:updateWhiteCycle (dt)
  self.color_time = self.color_time - dt
  if self.color_time < 0 then
    self.color_time = self.color_time + WHITE_COLOR_TIME
    self.color_index = self.color_index + 1
    if self.color_index > #colors.BonusSpecialFromColors then
      self.color_index = 1
    end
  end
end

function SpecialBonus:updateTempoCycle (dt)
  self.tempo_time = self.tempo_time - dt  
  if self.state == BONUS_STATES.begin_tempo and self.tempo_time < 0 then
    self.state = BONUS_STATES.countdown
    self.tempo_time = SCORE_TIME
  elseif self.state == BONUS_STATES.countdown and self.tempo_time < 0 then 
    self.bonus_score = self.bonus_score - 1000
    if self.bonus_score == 0 then
      self.tempo_time = self.tempo_time + TEMPO_END_TIME
      self.state = BONUS_STATES.end_tempo
    else
      self.tempo_time = self.tempo_time + SCORE_TIME
    end    
  end
end

function SpecialBonus:update (dt)
  SpecialBonus.super.update (self, dt)
  self:updateWhiteCycle (dt)
  self:updateTempoCycle (dt)
end