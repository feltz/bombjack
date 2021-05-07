require "constants"

local http = require("socket.http")
local json = require "json"

Highscores = Object:extend()

function Highscores:new ()
  self.highscores = nil
  self:load_scores()
end

function Highscores:get_min_highscore()
  return self.highscores.scores[self.highscores.nb_scores].score
end

function Highscores:get_highscore()
  return self.highscores.scores[1].score
end

function Highscores:is_online()
  return self.highscores.session_id ~= nil
end

function Highscores:get_pages_count()
  return math.ceil (#self.highscores.scores/10)
end

function Highscores:get_score (index)
  return self.highscores.scores[index]
end

function Highscores:set_name (index, name)
  self.highscores.scores[index].name = name
end


function Highscores:insert_new_score(score_to_enter, level) -- Retourne la page et l'index dans la page du score inséré  
  table.remove (self.highscores.scores, self.highscores.nb_scores)
  local idx = self.highscores.nb_scores - 1
  while idx > 0 and self.highscores.scores[idx].score < score_to_enter do
    idx = idx - 1
  end
  idx = idx + 1
  table.insert (self.highscores.scores, idx, {score = score_to_enter, name = "", round = level or 1})
  return math.ceil (idx/10), idx
end

function Highscores:load_scores()
  if self.highscores and self.highscores.session_id then
    body, code, header = http.request(HIGHSCORES_BASE_URL .. "/get_scores?session_id=" .. self.highscores.session_id)
  else
    body, code, header = http.request(HIGHSCORES_BASE_URL .. "/get_scores")
  end
  if code == 200 then
    self.highscores = json.decode (body)
  else
    self.highscores = ("highscores.json")
  end
end

function Highscores:send_intermediate_score(curr_level, level_score_str, total_score)
  if self.highscores.session_id then
    co = coroutine.create( function() Highscores.send_json ({session_id = self.highscores.session_id
                                                           , score = total_score
                                                           , level = curr_level
                                                           , level_score_str = level_score_str
                                                            }) end )
    coroutine.resume(co) 
  end
end

function Highscores:send_final_score(name, curr_level, level_score_str, total_score)
  Highscores.send_json ({session_id = self.highscores.session_id
                       , score = total_score
                       , name = name
                       , level = curr_level
                       , level_score_str = level_score_str
                        })   
end

function Highscores:close_session()
  if self.highscores.session_id then
    http.request(HIGHSCORES_BASE_URL .. "/close?session_id=" .. self.highscores.session_id)
  end  
end

function Highscores.send_json (json_obj)
  req = json.encode (json_obj)
  resp={}
  
  body, code, header = http.request{url = HIGHSCORES_BASE_URL .. "/enter_score"
                                  , method = "POST"
                                  , headers = {["content-type"] = "application/json", ["content-length"] = tostring(#req)}
                                  , source = ltn12.source.string (req)
                                  , sink=ltn12.sink.table(resp)
                                   }
end