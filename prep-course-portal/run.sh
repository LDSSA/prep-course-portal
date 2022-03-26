#!/bin/bash

# perform necessary migrations
python manage.py makemigrations --noinput
python manage.py migrate --noinput
python manage.py collectstatic --noinput
# create admin user if not exists
python manage.py initadmin

# run the project
gunicorn prep-course-portal.wsgi:application -b 0.0.0.0:8000
