# FROM ubuntu:20.04

FROM python:3.9

RUN apt-get install wget
RUN pip install pandas sqlalchemy psycopg psycopg2-binary prefect
WORKDIR /app