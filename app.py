import json
from poppler import load_from_file, PageRenderer
from PIL import Image
import pdfkit
from zeep import Client
from pdf2image import convert_from_path

def lambda_handler(event, context):
    body = {
        "message": "Go Serverless v1.0! Your function executed successfully!",
        "input": event
    }
    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }
    return response