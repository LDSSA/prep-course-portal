# pull official base image
FROM python:3.7

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# set work directory
WORKDIR /app

# copy project
COPY . .

# install dependencies
#RUN apt update && apt add make automake gcc g++ subversion python3-dev
RUN pip install --upgrade pip
RUN pip install -r requirements.txt


# run the project
ENTRYPOINT [ "/bin/bash", "./run.sh" ]
