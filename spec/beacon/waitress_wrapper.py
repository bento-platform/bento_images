from waitress import serve
from bento_beacon.bento_beacon.app import app

serve(app)