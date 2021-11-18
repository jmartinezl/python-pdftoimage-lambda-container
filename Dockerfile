FROM public.ecr.aws/lambda/python:3.8

RUN yum update && \
    yum install -y poppler poppler-utils poppler-cpp-devel gcc gcc-c++ cmake3 make pkg-config cmake-data python-devel

RUN ln -s /usr/bin/cmake3 /usr/bin/cmake


# Pythonモジュールのインストール
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    rm requirements.txt

COPY app.py   ./
CMD ["app.lambda_handler"]    
