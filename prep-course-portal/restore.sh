#!/bin/bash

echo "==> Removing all data from the database..."
python manage.py flush --noinput

echo "==> Loading user fixtures..."
python manage.py loaddata submissions/fixtures/users.json

echo "==> Loading submissions fixtures..."
python manage.py loaddata submissions/fixtures/submissions.json

echo "==> Done!"
