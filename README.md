# Flask Application with Load Balancing via Nginx

## Projeto

Este projeto utiliza o Docker para rodar uma aplicação Flask em dois contêineres, balanceados por um proxy reverso Nginx. A configuração usa o Docker Compose para gerenciar os contêineres e fornecer um ambiente escalável e de alta disponibilidade.

## Funcionalidades

- A aplicação Flask responde na rota `/`, exibindo o nome do contêiner (hostname) e o endereço IP do servidor.
- O Nginx atua como proxy reverso, balanceando o tráfego entre dois contêineres Flask.
- Se um contêiner Flask falhar, o Nginx redireciona as requisições para o contêiner ativo, garantindo a continuidade do serviço.

## Estrutura do Projeto

```
.
├── app.py                 # Aplicação Flask
├── Dockerfile             # Dockerfile para a aplicação Flask
├── docker-compose.yml      # Definição dos serviços Docker (Flask + Nginx)
├── nginx.conf             # Configuração do Nginx para balanceamento de carga
├── requirements.txt       # Dependências do Flask
└── README.md              # Instruções do projeto (este arquivo)
```

## Requisitos

- Docker
- Docker Compose

## Como rodar o projeto

1. **Clone o repositório:**

   ```bash
   git clone <seu-repositorio-url>
   cd <nome-do-projeto>
   ```

2. **Construa e inicie os contêineres:**

   Use o comando abaixo para construir as imagens do Docker e iniciar os contêineres:

   ```bash
   docker-compose up --build
   ```

3. **Acessar a aplicação:**

   Após iniciar os contêineres, a aplicação estará disponível em:

   ```bash
   http://localhost/
   ```

   O Nginx redirecionará o tráfego para um dos contêineres Flask e retornará o nome do contêiner e o IP que processou a requisição.

## Serviços

O arquivo `docker-compose.yml` define três serviços:

- **web1**: Um contêiner Flask rodando na porta interna 5000 e mapeado para a porta 5001 no host.
- **web2**: Um segundo contêiner Flask rodando na porta interna 5000 e mapeado para a porta 5002 no host.
- **nginx**: Um contêiner Nginx rodando na porta 80, fazendo o balanceamento de carga entre os dois servidores Flask.

## Estrutura dos Arquivos

### app.py

Este arquivo contém a aplicação Flask que exibe o nome da máquina (hostname) e o endereço IP:

```python
from flask import Flask
import socket

app = Flask(__name__)

@app.route('/')
def index():
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    return f'Hostname: {hostname}, IP Address: {ip_address}'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### Dockerfile

Este arquivo define o ambiente necessário para rodar a aplicação Flask:

```Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt requirements.txt
COPY app.py app.py

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]
```

### docker-compose.yml

Define os serviços e a rede do projeto:

```yaml
version: '3'

services:
  web1:
    build: .
    container_name: web1
    ports:
      - "5001:5000"
    networks:
      - flask_network

  web2:
    build: .
    container_name: web2
    ports:
      - "5002:5000"
    networks:
      - flask_network

  nginx:
    image: nginx:latest
    container_name: nginx
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    ports:
      - "80:80"
    depends_on:
      - web1
      - web2
    networks:
      - flask_network

networks:
  flask_network:
    driver: bridge
```

### nginx.conf

Configura o Nginx para balancear a carga entre os contêineres Flask:

```nginx
events { }

http {
    upstream flask_app {
        server web1:5000;
        server web2:5000;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://flask_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

## Encerrando os serviços

Para parar e remover os contêineres e a rede criada, execute:

```bash
docker-compose down
```

## Contribuição

Sinta-se à vontade para abrir *pull requests* e sugerir melhorias!
