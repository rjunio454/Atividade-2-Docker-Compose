from flask import Flask
import socket
app = Flask(__name__)
@app.route('/')
def index():
# Obter o nome da máquina e o IP
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    return f'Hostname: {hostname}<br>IP Address: {ip_address}'
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
