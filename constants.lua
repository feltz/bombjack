SCALE = 3
HOR_SPEED = 80
VERT_SPEED = 80
GRAVITY = 2
SCREEN_W, SCREEN_H = 256, 256
BORDER = 16
NB_LIFES = 3
ENNEMY_POINTS = { 100, 200, 300, 500, 800, 1200, 2000, 2000, 2000, 2000 }
BONUS_LIMIT = 5000
WHITE_COLOR_TIME = .1 -- seconds (utilisé par SpecialBonus et NewLife)
LAST_LEVEL = 30 -- Devrait être 99
START_LEVEL = 1 -- Devrait être toujours 1 (sauf debug)
MUMMY_IDLE_TIME = .7 -- seconds
MUSIC_ON = true
SOUND_ON = true
MUMMY_DELTA_FACTORS = { 1, 0.8, 0.8^2, 0.8^3, 0.8^3*0.7, 0.8^3*0.7*0.5, 0.8^3*0.7*0.5 }
SPEED_FACTORS = { 1, 0.8, 0.8^2, 0.8^3, 0.8^4, 0.8^5, 0.8^5 }
INITIAL_MUMMY_DELTA = 4.3 -- seconds
SPEED_INC_TIME = 30 -- seconds
HIGHSCORES_BASE_URL = "http://viereck.fr:5000/bombjack"

DEBUG_BIRD = false
DEBUG_COLLISIONS = false
BIRD_PAUSE = 0.4 -- seconds
SHOW_FPS = false

MENUPAGES = {main = 0, highscores = 1, entering_score = 2}
MAIN_PAGE_SECS = 7 -- seconds
HIGHSCORE_PAGE_SECS = 3 -- seconds
LETTERS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R"
         , "S", "T", "U", "V", "W", "X", "Y", "Z", " ", "."}

MUSICS = {"sounds/03_Ringo_no_Mori_no_Koneko_Tachi_BGM_1.mp3", "sounds/06_BGM_2.mp3", "sounds/10_Lady_Madonna_BGM3.mp3"}
SOUNDS = {touched = "sounds/11_Touched_an_Enemy.mp3", gameover = "sounds/12_Game_Over.mp3", clear_level = "sounds/05_Clear.mp3"
        , highscore_entering = "sounds/13_Name_Entry_1.mp3", special_bonus = "sounds/09_Special_Bonus.mp3"
        , power_appearing = "sounds/08_Power_Ball_Appearing.mp3", got_power = "sounds/07_Got_a_Power_Ball.mp3"
        , take_bomb = "sounds/take_bomb.wav", take_exploding_bomb = "sounds/take_exploding_bomb.wav", jump = "sounds/jump.wav"
        , mummy_appear = "sounds/mummy_appear.wav", mummy_fall = "sounds/mummy_fall.wav", kill_ennemy = "sounds/kill_ennemy.wav"
        , bonus = "sounds/bonus.wav", take_bonus = "sounds/take_bonus.wav", walking = "sounds/walking.wav"}