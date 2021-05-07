from datetime import datetime
from sqlalchemy import Column, Text, DateTime, Integer, Identity, create_engine
from sqlalchemy.ext.declarative import declarative_base
from games_database import Base

class Highscore(Base):
	__tablename__ = 'highscores'
	id = Column(Integer, Identity(), primary_key=True)
	name = Column(Text)
	score = Column(Integer)
	round = Column(Integer)
	
	def __init__ (self, name = '...', score = 10000, r = 1):
		self.name = name
		self.score = score
		self.round = r
		
	def __str__(self):
		return self.name + " " + str(self.score) + " " + str(self.round)
		
class SessionID(Base):
	__tablename__ = 'sessions'
	id = Column(Text, primary_key=True)
	creation = Column(DateTime, default=datetime.now)
	level_done = Column(Integer, default=0)
	score = Column(Integer, default=0)
	
	def __init__ (self, session_id):
		self.id = session_id
		
	def __str__(self):
		return self.id + " " + str(self.creation)
