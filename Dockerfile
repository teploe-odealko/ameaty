FROM tiangolo/uvicorn-gunicorn-fastapi:python3.7
WORKDIR /usr/src/app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "app/main.py"]