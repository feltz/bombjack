import json
import uuid
from bombjack_model import Highscore, SessionID
from sqlalchemy import desc
from flask import request
from flask import Flask
from sqlalchemy.orm import scoped_session
from games_database import Session
from sqlalchemy.sql import func
from logging.config import dictConfig

dictConfig({
    'version': 1,
    'formatters': {'default': {
        'format': '[%(asctime)s] %(levelname)s in %(module)s: %(message)s',
    }},
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'default',
        },
        'file': {
            'class': 'logging.FileHandler',
            'filename': "bombjack.log",
            'formatter': 'default',
        },
    },
    'root': {
        'level': "INFO",
        'handlers': ['console', 'file']
    }
})

#http://viereck.fr:5000/bombjack/get_scores
app = Flask(__name__)
app.session = scoped_session(Session)

@app.route('/bombjack/get_scores')
def get_scores():
  scores = app.session.query( Highscore ).order_by(Highscore.score.desc()).all()
  json_list = []
  for score in scores:
    json_list.append ({i:score.__dict__[i] for i in score.__dict__ if i!="_sa_instance_state"})
  if request.args.get('session_id'):
    session_id = request.args.get('session_id')
    app.logger.info('Get score for sessions %s', session_id)
  else:
    newSessionId = SessionID (uuid.uuid4().hex)
    app.session.add (newSessionId)
    app.session.commit()
    session_id = newSessionId.id
    app.logger.info('Get score for NEW sessions %s', session_id)
  return json.dumps({"nb_scores":999, "session_id":session_id, "scores":json_list})

@app.route('/bombjack/close')
def close_session(): # ?session_id=xxxx
  session_id = request.args.get('session_id')
  if session_id:
    app.session.query(SessionID).filter(SessionID.id == session_id).delete()
    app.session.commit()
    app.logger.info('session %s successfully closed', session_id)
    return "<html>OK</html>"
  else:
    app.logger.error('session_id was not present')
    return "<html>session_id was not recognized.</html>"  

def calc_score (level_score_str):
  BONUS_SCORES = [10000, 20000, 30000, 50000]
  ENNEMY_POINTS = [100, 200, 300, 500, 800, 1200, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000]
  score = 0
  if len(level_score_str) > 0:
    i = 0
    while (i < len(level_score_str)):
      old_score = score
      if level_score_str[i] == 'J' or level_score_str[i] == 'T' or level_score_str[i] == 'F':
        score += 10 * int (level_score_str[i+1])
      elif level_score_str[i] == 'X': # special bonus between levels
        score += BONUS_SCORES[int (level_score_str[i+1])]
      elif level_score_str[i] == 'C': # bonus new life
        score += 3000 * int (level_score_str[i+1])
      elif level_score_str[i] == 'B': # normal bonus
        score += 1000 * int (level_score_str[i+1])
      elif level_score_str[i] == 'c': # catch animated bombs 
        score += 200 * int (level_score_str[i+1])
      elif level_score_str[i] == 'b': # catch bombs 
        score += 100 * int (level_score_str[i+1])
      else: # ennemy kill or catch power (from 'o' + index)
        score += ENNEMY_POINTS[ord(level_score_str[i])-111] * int (level_score_str[i+1])
      i = i + 2
  return score

@app.route('/bombjack/enter_score', methods=['POST'])
def enter_score(): 
  request_data = request.get_json()
  session_id = request_data.get('session_id')
  if session_id is None:
    app.logger.error('Session not found')
    return "<html>No session ID</html>" 
  session_row = app.session.query(SessionID).filter(SessionID.id == session_id).all()[0]

  if not session_row or not (request_data.get('score') and request_data.get('level') 
                             and (request_data.get('name') or request_data.get('level_score_str'))):
      app.logger.error('Incorrect parameters')
      return "<html>Incorrect parameters</html>"  

  level_score = calc_score (request_data['level_score_str'])
  if level_score != request_data['score'] - session_row.score:
    app.logger.info('%s: Invalidated score: string of level %d %s (%d) is not equal to %d-%d'
                   , session_id, request_data.get('level'), request_data['level_score_str']
                   , level_score, request_data['score'], session_row.score)
    return "<html>Invalidated score</html>"
  else:
    session_row.score += level_score

  if request_data.get('name'): # end of game -> store new highscore
    if request_data['score'] != session_row.score:
      app.logger.info('%s:Invalidated final score for %s : %d is not equal to %d', session_id, request_data['name']
                    , request_data['score'], session_row.score)
      return "<html>Invalidated final score</html>"
    newHighscore = Highscore(name = request_data['name'], score = request_data['score'], r = request_data['level'])
    app.session.add(newHighscore) 
    minScore = app.session.query(func.min(Highscore.score)).one()[0]
    idToDelete = app.session.query(Highscore).filter(Highscore.score==minScore).limit(1).all()[0].id
    session_row.score = 0
    session_row.level_done = 0
    app.session.query(Highscore).filter(Highscore.id==idToDelete).delete()
    app.session.commit()
    app.logger.info('New highscore added for %s (level %d): %d', request_data['name']
                   , request_data['level'], request_data['score'])
    return "<html>OK, new score added.</html>"
  else:
    session_row.level_done += 1
    app.session.commit()
    app.logger.info('New score updated %d', session_row.score)
    return "<html>OK, new score updated.</html>"
    
@app.teardown_appcontext
def close_db(*args, **kwargs):
  app.session.remove()

if __name__ == '__main__':
    app.run(host='0.0.0.0')
    
