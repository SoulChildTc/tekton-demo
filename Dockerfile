FROM python:3.10.9

WORKDIR /code
ENV PYTHONPATH=/code
COPY . /code
RUN pip install -r requirements.txt -i https://mirrors.cloud.tencent.com/pypi/simple

ENV TZ Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
