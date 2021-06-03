# syntax=docker/dockerfile:1

# Baseado em: https://docs.docker.com/language/python/build-images/
# Por que não usar alpine? https://pythonspeed.com/articles/base-image-python-docker-images/

FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 80

CMD [ "python3", "app.py" ]

