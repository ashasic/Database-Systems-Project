from flask import Flask
from .config import get_db_connection

def create_app():
    app = Flask(__name__)

    @app.route("/health")
    def health():
        with get_db_connection() as cur:
            cur.execute("SELECT 1")
            return "DB OK!"

    from . import routes 
    routes.init_app(app)
    return app
