GUIText = Object:extend()

COLOR_CYLE = .5 -- seconds
BOX_CYCLE = 2 -- seconds

function GUIText:new (quads)
  self.quads, self.game = quads, nil
  self.text_time, self.box_color_time = 0, 0
  self.cycle_counter = 1
  self.cycle_3_colors = {{1, 0, 0, 1}}
  self.old_color = {1, 1, 1, 1}
end

function GUIText:attachGame (game)
  self.game = game
end

function GUIText:setColor(color_tab, dont_save)
  if color_tab then
    if not dont_save then
      self.old_color = {love.graphics.getColor()}
    end
    love.graphics.setColor (color_tab)
  end
end

function GUIText:getColorFromCycle3(shift_index)
  return self.cycle_3_colors[shift_index or 1]
end

function GUIText:unsetColor()
  if self.old_color then
    love.graphics.setColor (self.old_color)
  end
end

function GUIText:writeText (text, x, y, color_tab)
  self:setColor (color_tab)
  for i = 1, #text do
    local c = text:sub(i,i)
    if c == '-' then
      love.graphics.draw (spritesPNG_near, self.quads.letter_dash, x+(i-1)*8, y)
    elseif c == '.' then
      love.graphics.draw (spritesPNG_near, self.quads.letter_dot, x+(i-1)*8, y)
    elseif c == '!' then
      love.graphics.draw (spritesPNG_near, self.quads.letter_exclamation, x+(i-1)*8, y)
    elseif c == "'" then
      love.graphics.draw (spritesPNG_near, self.quads.letter_apostroph, x+(i-1)*8, y)
    elseif c == "_" then
      love.graphics.draw (spritesPNG_near, self.quads.letter_pts, x+(i-1)*8, y)
    elseif c == '�' then
      love.graphics.draw (spritesPNG_near, self.quads.letter_copyright, x+(i-1)*8, y)
    elseif c == '�' then
      love.graphics.draw (spritesPNG_near, self.quads.letter_trademark, x+(i-1)*8, y)
    elseif tonumber (c) then
      love.graphics.draw (spritesPNG_near, self.quads.digits[tonumber (c)+1], x+(i-1)*8, y)
    elseif c ~= ' ' then
      love.graphics.draw (spritesPNG_near, self.quads.letters[c], x+(i-1)*8, y)
    end
  end
  self:unsetColor ()
end

function GUIText:writeNumber (number, x, y, color_tab)  
  local str = tostring (number)
  self:setColor (color_tab)
  for i = 1,#str do
    love.graphics.draw (spritesPNG_near, quads.digits[1+tonumber (str:sub (i, i))], x - 8*(#str-i), y)
  end
  self:unsetColor ()
end

function GUIText:update(dt)
  self.box_color_time = self.box_color_time + dt * (self.game:isPowerOrFreezeTime() and 3 or 1)
  if self.box_color_time > BOX_CYCLE then
    self.box_color_time = 0
  end
  self.text_time = self.text_time + dt
  if self.text_time > COLOR_CYLE then
    self.text_time = self.text_time - COLOR_CYLE
    self.cycle_counter = self.cycle_counter + 1
  end
  for i = 0,4 do -- les autres couleurs de la liste seront des couleurs décalées par rapport au cycle d'origine (max décalage = cycle/2)
    local text_time = self.text_time + i * (COLOR_CYLE/2/5)
    local c_counter = self.cycle_counter
    if text_time > COLOR_CYLE then c_counter = c_counter + 1 end -- On ne dépassera qu'une fois au maximum    
    local factor = text_time / COLOR_CYLE
    if self.cycle_counter % 3 == 1 then
      self.cycle_3_colors[i+1] = {1, factor, 0, 1}
    elseif self.cycle_counter % 3 == 2 then
      self.cycle_3_colors[i+1] = {1-factor, 1-factor, factor, 1}
    elseif self.cycle_counter % 3 == 0 then
      self.cycle_3_colors[i+1] = {factor, 0, 1-factor, 1}
    end  
  end
end  

function GUIText:getLifeCoords (life_index)
  local _, _, w, _ = self.quads.bj_idle:getViewport()
  return BORDER + (life_index-1)*(w+2), SCREEN_H - BORDER
end

function GUIText:drawLifes (nb_lifes)
  for i = 1, nb_lifes do
    love.graphics.draw (spritesPNG, self.quads.bj_idle, self:getLifeCoords (i))
  end
end

function GUIText:draw(sprite_near_map, play_started, highscore_reached)
  local function substract_index (tab_colors, index, num_to_sub)
    local idx = index - num_to_sub
    if idx < 1 then 
      idx = #tab_colors + idx
    end  
    return idx
  end
  self:writeText ("SIDE-ONE", 8, 0, play_started and self:getColorFromCycle3() or {1, 1, 0, 1})
  if self.game.highscores:is_online() then
    self:writeText ("ONLINE", 200, 0, {1/3, 1/3, 1/3, 1})
  end
  self:writeText ("ROUND", 112, 240, {0, 1, 0, 1})
  self:writeText ("HI-SCORE", 192, 240, highscore_reached and self:getColorFromCycle3() or {1, 1, 0, 1})
  self:writeNumber (self.game.highscores:get_highscore(), 248, 248)
  self:writeText ("-" .. tostring (self.game.curr_level) .. "-", 120, 248, {0, 1, 1, 1})
  if not play_started then
    self:drawLifes (3)
  end
  
  local rot_colors
  if self.game:isPowerOrFreezeTime() then
    rot_colors = self.game.bonus_objects.power and self.game.bonus_objects.power:getCurrentColors() or self.game.bombjack:getColorTable()
  else
    rot_colors = colors.StartLogoColors
  end
    
  local index = math.ceil (#rot_colors * self.box_color_time / BOX_CYCLE)
  self:setColor (rot_colors[index])
  love.graphics.rectangle ("fill", SCREEN_W / 2 - 20, 0, 40, 16)  
  for i=1, self.game:isPowerOrFreezeTime() and 5 or math.floor (self.game.score.intern_power_score / 2) do
    self:setColor (rot_colors [substract_index (rot_colors, index, i)], true)
    love.graphics.rectangle ("fill", SCREEN_W / 2 - 20 - i * 4, 0, 4, 16)
    love.graphics.rectangle ("fill", SCREEN_W / 2 + 20 + (i-1) * 4, 0, 4, 16)
  end
  self.game.shader:sendColor("fromColors", {1, 1, 1, 1})
  self.game.shader:sendColor("toColors", rot_colors[substract_index (rot_colors, index, 6)])
  love.graphics.setShader(self.game.shader)
  love.graphics.draw (sprite_near_map, self.quads.multiplier[1], SCREEN_W / 2 - 12, 2)
  love.graphics.draw (sprite_near_map, self.quads.multiplier[self.game.score.multiplier + 1], SCREEN_W / 2, 2)
  love.graphics.setShader()
  self:unsetColor()
end

function GUIText:keypressed(key)
end