require "guitext"

Menu = GUIText:extend()
Menu:implement(ColorRotator)

function Menu:new (quads, game, highscores)
  Menu.super.new (self, quads)
  self.game, self.highscores = game, highscores
  self.page_time, self.page, self.game = 0, MENUPAGES.main, game
  self.highscore_page = 1
  self.index_entering, self.name_entering, self.letter_idx = nil, "", nil
  self:initColorRotator (colors.BombjackLogoColors, 0.07)
end

function Menu:update(dt)
  Menu.super.update (self, dt)
  self:rotateColorTable(dt)
  if self.page == MENUPAGES.main then
    self.page_time = self.page_time + dt
    if self.page_time > MAIN_PAGE_SECS then
      self.page_time = 0
      self.page = MENUPAGES.highscores
    end
  elseif self.page == MENUPAGES.highscores then
    self.page_time = self.page_time + dt
    if self.page_time > HIGHSCORE_PAGE_SECS * (self.highscore_page == 1 and 2 or 1) then
      self.page_time = 0
      self.highscore_page = self.highscore_page + 1
      if self.highscore_page > self.highscores:get_pages_count() then
        self.page = MENUPAGES.main
        self.highscore_page = 1
        return
      end
    end
  end
end  

function Menu.getNthText (pos)
  local text = tostring (pos)
  if pos == 1 then text = text .. "ST" 
  elseif pos == 2 then text = text .. "ND"
  elseif pos == 3 then text = text .. "RD"
  else text = text .. "TH"
  end
  return text
end

function Menu:startEnteringScore(score_to_enter, round_reached)
  menu_displayed = true
  self.highscores:load_scores() -- On recharge les derniers scores
  if score_to_enter > self.highscores:get_min_highscore() then
    TEsound.playLooping (SOUNDS.highscore_entering, "static", "highscore_entering")
    self.page = MENUPAGES.entering_score
    self.highscore_page, self.index_entering = self.highscores:insert_new_score (score_to_enter, round_reached)
    self.name_entering = ""
    self.letter_idx = 1
  end
end

function Menu:draw()
  Menu.super.draw (self, spritesPNG_near, false, false)
  my_game.score:draw()
  if self.page == MENUPAGES.main then
    self.game.shader:sendColor("fromColors", unpack (colors.BombjackLogoColors))
    self.game.shader:sendColor("toColors", unpack (self:getColorTable()))
    love.graphics.setShader(self.game.shader)
    love.graphics.draw (spritesPNG_near, self.quads.logo, 16+16, 32)  
    love.graphics.setShader()
    self:writeText ("PUSH", 16+96, 120, self:getColorFromCycle3())
    self:writeText ("1 PLAYER BUTTON ONLY", 16+32, 136)
    self:writeText ("PRESENTED", 16+72, 160)
    self:writeText ("BY", 16+104, 176)
    self:writeText ("TEHKAN", 16+72, 192, {0, 1, 0})
    self:writeText ("LTD.", 16+128, 192)
    self:writeText ("CREDIT", 16+80, 224, {1, .53, 0})
    self:writeText ("1", 16+136, 224)
  else
    local page_index_entering
    if self.page == MENUPAGES.highscores then
      self:writeText ("BEST PLAYERS", 64, 32, {1, .53, 0})
    else
      page_index_entering = self.index_entering % 10
      if page_index_entering == 0 then page_index_entering = 10 end
      self:writeText ("FANTASTIC SCORE!", 48, 24, self:getColorFromCycle3())
      self:writeText ("RECORD YOUR NAME", 48, 40)
      self.game.shader:sendColor("fromColors", unpack (colors.EnteringFromColors))
      self.game.shader:sendColor("toColors", self:getColorFromCycle3(1), self:getColorFromCycle3(2), self:getColorFromCycle3(3)
                                           , self:getColorFromCycle3(4), self:getColorFromCycle3(5))
      love.graphics.setShader(self.game.shader)      
      love.graphics.draw (spritesPNG_near, self.quads.entering_rect, 115, 50 + (page_index_entering - 1) * 16)
      love.graphics.setShader()
    end
    local score_info
    for i=1, 10 do
      local score_position = i + (self.highscore_page-1)*10
      score_info = self.highscores:get_score (score_position)
      local y = 56+(i-1)*16
      local text = Menu.getNthText (score_position)
      if score_info then
        if self.page == MENUPAGES.highscores then
          self:writeText (text, 32 - (#text-1)*8, y)
          self:writeNumber (score_info.score, 104, y, i == 1 and self:getColorFromCycle3() or nil)
          self:writeText ("ROUND", 160, y)
          self:writeNumber (score_info.round, 216, y, i == 1 and self:getColorFromCycle3() or nil)
          self:writeText (score_info.name, 120, y)
        else -- MENUPAGES.entering_score
          self:writeText (text, 32 - (#text-1)*8, y, i == page_index_entering and self:getColorFromCycle3() or {1, 1, 0})
          self:writeNumber (score_info.score, 104, y, i == page_index_entering and self:getColorFromCycle3() or nil)
          self:writeText ("ROUND", 160, y, i == page_index_entering and self:getColorFromCycle3() or {0, 1, 0})
          self:writeNumber (score_info.round, 216, y, i == page_index_entering and self:getColorFromCycle3() or nil)
          if i == page_index_entering then
            self:writeText (LETTERS[self.letter_idx], 120+#self.name_entering*8, y, {0, 1, 1})
            self:writeText (self.name_entering, 120, y, i == page_index_entering and {1, .53, 0})
          else
            self:writeText (score_info.name, 120, y, i == page_index_entering and {1, .53, 0})
          end
        end
      end
      self:writeText ('Â' .. '©' .. "1984", 40, 224)
      self:writeText ("TEHKAN", 96, 224, self.page == MENUPAGES.highscores and self:getColorFromCycle3() or {0, 1, 0})
      self:writeText ("LTD.", 152, 224)
    end
  end
end

function Menu:keypressed(key)
  local restart_game = key == "1" or key == "2" or key == "space" or key == "return" or key == "rctrl" and key == "lctrl"
  if self.page == MENUPAGES.entering_score then
    if key == "right" or key == 'down' then
      self.letter_idx = self.letter_idx == #LETTERS and 1 or self.letter_idx + 1
    elseif key == "left" or key == 'up' then
      self.letter_idx = self.letter_idx == 1 and #LETTERS or self.letter_idx - 1
    elseif #key == 1 and string.match(string.upper (key), "[".. table.concat(LETTERS) .. "]") then
      for i in ipairs (LETTERS) do
        if string.upper (key) == LETTERS[i] then
          self.name_entering = self.name_entering .. LETTERS[i]
          self.letter_idx = 1
        end
      end
    elseif key == "rctrl" or key == "lctrl" then
      self.name_entering = self.name_entering .. LETTERS[self.letter_idx]
      self.letter_idx = 1
    end
    if #self.name_entering == 3 then
      self.page = MENUPAGES.highscores
      self.page_time = 0
      TEsound.stop ("highscore_entering")
      self.highscores:set_name (self.index_entering, self.name_entering)
      self.highscores:send_final_score (self.name_entering, self.game.curr_level
                                      , self.game.score.level_score, self.game.score.score)
    end
    return false
  elseif self.page == MENUPAGES.highscores then
    if restart_game then return true end
    self.page_time = 0
    if key == 'up' or key == 'pageup' then
      self.highscore_page = self.highscore_page - 1
      if self.highscore_page < 1 then self.highscore_page = self.highscores:get_pages_count() end
    elseif key == 'down' or key == 'pagedown' then
      self.highscore_page = self.highscore_page + 1
      if self.highscore_page > self.highscores:get_pages_count() then self.highscore_page = 1 end
    elseif key == 'end' then
      self.highscore_page = self.highscores:get_pages_count()
    elseif key == 'home' then
      self.highscore_page = 1
    end
  else
    return restart_game
  end
end