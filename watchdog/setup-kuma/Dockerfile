FROM python:3.12-alpine
RUN pip install --no-cache-dir "python-socketio[client]"
COPY setup-kuma.py /setup-kuma.py
ENTRYPOINT ["python", "-u", "/setup-kuma.py"]
