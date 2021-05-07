require "constants"

json = require "json"
Object = require "classic" -- Permet de faire du simili-objet 

local sep = package.path:find("\\") and "\\" or "/"
package.path = package.path .. ';.' .. sep .. 'sprites' .. sep .. '?.lua'

require "tesound"

require "bombjack"
require "score"
require "platform"
require "livegame"
require "menu"
require "highscores"
 
function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end -- Permet le debug
  love.window.setMode(SCREEN_W*SCALE, SCREEN_H*SCALE)
  love.graphics.setLineStyle ("rough")
  love.window.setTitle("BombJack")
  fps_font = love.graphics.newFont(8)
  
  spritesPNG = love.graphics.newImage("graphics/sprites.png")
  spritesPNG_near = love.graphics.newImage("graphics/sprites.png")
  spritesPNG_near:setFilter("nearest", "nearest")
  screensPNG = love.graphics.newImage("graphics/screens.png")

  screens = loadScreens(screensPNG)
  quads = loadQuads (spritesPNG, "sprites/sprites.json")
  levels = getJson ("levels.json")  
  colors = getColors (getJson ("colors.json"))
  highscores = Highscores()

  limits = {bottom = SCREEN_H-BORDER-8, left = BORDER+8, right = SCREEN_W-BORDER-8, up = BORDER+8}
  local paletteShader = love.graphics.newShader ("change_color.glsl")
  manage_music()
  
  gui = GUIText (quads)
  my_game = LiveGame (gui, highscores, quads, paletteShader, levels)
  gui:attachGame (my_game)
  
  menu = Menu (quads, my_game, highscores)
  menu_displayed = true
end

function manage_music()
  if not MUSIC_ON then
    for i, v in ipairs (MUSICS) do
      MUSICS[i] = "sounds/empty.wav"
    end
  end
  if not SOUND_ON then
    for k, v in pairs (SOUNDS) do
      SOUNDS [k] = "sounds/empty.wav"
    end
  end
end

function getColors(colors)
  for _, c1 in pairs (colors) do
    for idx2, c2 in pairs (c1) do
      for idx3, c3 in pairs (c2) do
        if type(c3) == "table" then
          for idx4, c4 in pairs (c3) do
            c3[idx4] = c4/255
          end
        else
          c2[idx3] = c3/255
        end
      end
    end
  end  
  return colors
end

function loadScreens ()
  local w, h = screensPNG:getWidth() / 4, screensPNG:getHeight()
  screens = {}
  for i=0,4 do
    quad = love.graphics.newQuad ((screensPNG:getWidth() / 5) * i, 0, screensPNG:getWidth() / 5, screensPNG:getHeight(), screensPNG:getDimensions())
    table.insert (screens, quad)
  end
  return screens
end

function loadQuads(image, json_filename)
  local json = getJson (json_filename)
  local quads = {}
  for key, value in pairs (json) do
    if table.getn (json[key]) == 0 then
      if key == "letterA" then
        local letters = {}
        for i = 0,25 do
          letters[string.char(65+i)] = love.graphics.newQuad (json[key].x + i * 12, json[key].y, json[key].w, json[key].h, image:getDimensions())
        end
        quads['letters'] = letters
      else
        quads[key] = love.graphics.newQuad (json[key].x, json[key].y, json[key].w, json[key].h, image:getDimensions())
      end
    else
      quads[key] = {}
      for _, value in pairs (json[key]) do
        table.insert (quads[key], love.graphics.newQuad (value.x, value.y, value.w, value.h, image:getDimensions()))
      end
    end
  end
  return quads
end

function love.update(dt)
  TEsound.cleanup()
  menu:update(dt)
  gui:update(dt)
  if menu_displayed then
    TEsound.stop ("music")
  else    
    my_game:update(dt, limits)
  end    
end

function love.draw()
  love.graphics.scale( SCALE, SCALE )
  love.graphics.setFont(fps_font)
  if SHOW_FPS then
    love.graphics.print("FPS: " .. tostring (love.timer.getFPS( )), 200, 5)  
  end
  gui:draw(spritesPNG_near, not menu_displayed, my_game.score.score > (menu.highscore or 0), my_game.curr_level or 1)
  if menu_displayed then
    menu:draw(menu_displayed)
  else    
    my_game:draw(spritesPNG, spritesPNG_near, screensPNG, screens)
  end  
end

function love.keypressed(key)
  if menu_displayed then
    menu_displayed = not menu:keypressed(key)
    if not menu_displayed then
      my_game:restartGame()
    end
  else
    my_game:keypressed(key)
  end
end

function love.quit()
  highscores:close_session()
end