from waitress import serve
from chord_drs.app import application

serve(application)