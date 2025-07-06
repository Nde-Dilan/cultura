import json
import boto3


def lambda_handler(event, context):
    runtime_client = boto3.client('runtime.sagemaker')
    endpoint_name = 'huggingface-pytorch-inference-2025-07-06-16-29-32-191'
    
    # Format the payload correctly - it should match the format used in deployment
    payload = {
        "inputs": "I love you"
    }

    response = runtime_client.invoke_endpoint(
        EndpointName=endpoint_name,
        ContentType='application/json',
        Body=json.dumps(payload)  # Use the formatted payload
    )
    
    print("response: ", response)
    result = json.loads(response['Body'].read().decode('utf-8'))
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'translation': result,
            'message': 'Translation completed successfully'
        })
    }