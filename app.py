import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return f"I am now a certified devops engineer"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
