import os
import sys
import json
import logging
import requests
import msal

from flask import Flask, session, request, redirect, url_for, jsonify
from flask_session import Session

app = Flask(__name__)
app.secret_key = 'a-super-secret-secret'
app.config["DEBUG"] = True

config = json.load(open('aad-config.json'))

# See also https://flask.palletsprojects.com/en/1.0.x/deploying/wsgi-standalone/#proxy-setups
from werkzeug.middleware.proxy_fix import ProxyFix
app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1, x_host=1)

@app.route('/login')
def hello_world():

    result = None
    client = msal.ConfidentialClientApplication(
        config["client_id"], authority=config["authority"],
        client_credential=config["secret"])

    if not request.args.get('code'):
        session["flow"] = client.initiate_auth_code_flow(config["scope"], redirect_uri=url_for("hello_world", _external=True))
        return redirect(session["flow"]["auth_uri"])

    try:
        result = client.acquire_token_by_auth_code_flow(session.get("flow", {}), request.args)
        print(result)
        if "error" in result:
            return result.get("error_description")
    except ValueError as error:  # Usually caused by CSRF
        print(error)
        pass  # Simply ignore them

    graph_data = None
    graph_data = requests.get(  # Use token to call downstream service
        config["endpoint"],
        headers={'Authorization': 'Bearer ' + result['access_token']}, ).json()
    return jsonify(graph_data)

@app.route('/')
def health_check():
    return "healthy!"

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))