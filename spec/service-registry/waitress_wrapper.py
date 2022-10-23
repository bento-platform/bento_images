from waitress import serve
from bento_beacon.bento_beacon.app import application

serve(application)