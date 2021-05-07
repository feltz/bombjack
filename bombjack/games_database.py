from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

Base = declarative_base()

engine = create_engine('postgresql:///games')
Session = sessionmaker(bind=engine)
