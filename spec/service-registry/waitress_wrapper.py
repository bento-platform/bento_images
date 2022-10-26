from waitress import serve
# from bento_service_registry.bento_service_registry.app import application
from bento_service_registry.app import application

serve(application)