# Usar a imagem base do Python
FROM python:3.9-slim
# Definir o diretório de trabalho dentro do contêiner
WORKDIR /app
# Copiar os arquivos locais para o diretório de trabalho do contêiner
COPY requirements.txt requirements.txt
COPY app.py app.py
# Instalar as dependências
RUN pip install -r requirements.txt
# Expor a porta que o aplicativo usará
EXPOSE 5000
# Comando para executar a aplicação
CMD ["python", "app.py"]