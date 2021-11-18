# Custom AWS Lambda with Docker Container (Python 3.8)

# Introduction

This repository is for anyone looking for python custom Dockerfile lambda example, maybe you are searching for a way to run pytho poppler in aws lambda.

# Services used in this example

## AWS Lambda

[AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) is a serverless computing service that lets you
run code without managing servers. It executes your code only when required and scales automatically, from a few
requests per day to thousands per second.

## Amazon Elastic Container Registry

[Amazon Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/?nc1=h_ls) is a fully managed container registry.
It allows us to store, manage, share docker container images. You can share docker containers privately within your
organization or publicly worldwide for anyone.


---

# Create a custom `docker` image

We are going to build a custom python `docker` image.

We have a `app.py` that looks something like this, use that file to put your custom code.

```python
import json

def handler(event, context):
    body = {
        "message": "Go Serverless v1.0! Your function executed successfully!",
        "input": event
    }
    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }
    return response
```

To containerize our Lambda Function, we have a `dockerfile` in the same directory with the following content.

```bash
FROM public.ecr.aws/lambda/python:3.8

RUN yum update && \
    yum install -y poppler poppler-utils poppler-cpp-devel gcc gcc-c++ cmake3 make pkg-config cmake-data python-devel

RUN ln -s /usr/bin/cmake3 /usr/bin/cmake


# Python requirements
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    rm requirements.txt

COPY app.py   ./
CMD ["app.lambda_handler"]    
```

Additionally we can add a `.dockerignore` file to exclude files from your container image.

```bash
Dockerfile
README.md
*.pyc
*.pyo
*.pyd
__pycache__
.pytest_cache
events
```

To build our custom `docker` image we run.

```bash
docker build -t docker-lambda .
```

and then to test it we run

```bash
docker run -d -p 8080:8080 docker-lambda
```

Afterwards, in a separate terminal, we can then locally invoke the function using `curl`.

```
curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{"payload":"hello world!"}'
```

---

# Deploy a custom `docker` image to ECR

Since we now have a local `docker` image we can deploy this to ECR. Therefore we need to create an ECR repository with
the name `docker-lambda`.

For the next instructions you need to configure aws cli first: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

_I will asume you already now how to use and configure aws cli_

```bash
aws ecr create-repository --repository-name docker-lambda
```

Next we need to `tag` / rename our previously created image to an ECR format. The format for this is
`{AccountID}.dkr.ecr.{region}.amazonaws.com/{repository-name}`

For example

```bash
docker tag docker-lambda 891511646143.dkr.ecr.eu-central-1.amazonaws.com/docker-lambda
```

To check if it worked we can run `docker images` and should see an image with our tag as name


Finally, we push the image to ECR Registry.

```bash
 docker push 891511646143.dkr.ecr.eu-central-1.amazonaws.com/docker-lambda
```

---

# Set up `AWS Lambda Function` from `ECR repository`

Once the image is pushed to the ECR, you can use it in a new Lambda function. In the Lambda console, choose Create function, and then select the new container image in the Basic information panel. Choose Create function to finish the process.

For Container image URI, provide a container image we already created.

In the Lambda console, you can set the timeout (1–900 seconds) and the memory allocation (128 MB to 10,240 MB). The 10 GB limit is a new feature, raising the previous memory maximum of 3 GB.

---

For further information: https://docs.aws.amazon.com/lambda/latest/dg/images-create.html, https://docs.aws.amazon.com/lambda/latest/dg/configuration-images.html

Recommended reading: https://shpals.medium.com/create-aws-lambda-from-ecr-docker-image-and-integrate-it-with-github-ci-cd-pipeline-dfa3015b5ee0

[AWS Lambda with custom docker images as runtime](https://www.philschmid.de/aws-lambda-with-custom-docker-image)
