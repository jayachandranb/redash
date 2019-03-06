FROM redash/redash:latest

USER root

RUN rm -f /app/redash/query_runner/__init__.py
ADD __init__.py /app/redash/query_runner/__init__.py

USER redash
