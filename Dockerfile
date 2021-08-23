FROM registry.cn-shanghai.aliyuncs.com/soulchild/google-appengine-python

RUN virtualenv /env

ENV VIRTUAL_ENV /env
ENV PATH /env/bin:$PATH
ENV PORT 8080

COPY app /cache/app

RUN pip install -r /cache/app/requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn

WORKDIR /cache/app
CMD gunicorn -b :$PORT main:app
