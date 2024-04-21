from flask import Flask
from flask import jsonify
from flask_cors import CORS
import json
import time
import os
document_path = os.getcwd()+'\car.json'
document = open(document_path, 'r')

app = Flask(__name__)
fname = 'car.json'
CORS(app)



@app.route("/")
def hello():
    return "Hello, World!"

@app.route("/getcar/<id>")
def getcar(id):
    key = id
    with open(fname,'r') as f:
        j = json.load(f)
    for i in j['car']:
        if i == key:
            return jsonify(j['car'][i])

@app.route("/change/on/<id>")
def changecaron(id):
    with open(fname,'r') as f:
        j = json.load(f)
    
    j['car'][id] = True
    with open(fname,'w') as f:
            json.dump(j,f)
    return 200

@app.route("/change/off/<id>")
def changecaroff(id):
    with open(fname,'r') as f:
        j = json.load(f)
    
    j['car'][id] = False
    with open(fname,'w') as f:
            json.dump(j,f)
    return 200

if __name__ == "__main__":
    app.run(port=8080, host='0.0.0.0')

