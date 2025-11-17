import json
import urllib.request
import urllib.parse


def lambda_handler(event, context):
    """
    Lambda function to call the Agify API and predict age based on name.
    
    Expected event format:
    {
        "name": "michael"
    }
    
    Returns:
    {
        "statusCode": 200,
        "body": {
            "name": "michael",
            "age": 62,
            "count": 233482
        }
    }
    """
    try:
        # Extract name from event
        name = event.get('name', 'michael')
        
        # Build API URL with query parameter
        params = urllib.parse.urlencode({'name': name})
        url = f'https://api.agify.io?{params}'
        
        # Make HTTP request
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode())
        
        return {
            'statusCode': 200,
            'body': json.dumps(data)
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }

