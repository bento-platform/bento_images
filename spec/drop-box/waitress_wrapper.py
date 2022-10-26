from waitress import serve
# from bento_drop_box_service.bento_drop_box_service.app import application
from bento_drop_box_service.app import application

serve(application)