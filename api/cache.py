import json
import os
import redis

client = redis.Redis(
    host=os.getenv("REDIS_HOST", "redis"),
    port=int(os.getenv("REDIS_PORT", "6379")),
    decode_responses=True,
)

def _key(device_id):
    return f"latest:{device_id}"

def get_latest_from_cache(device_id):
    value = client.get(_key(device_id))
    if value is None:
        return None
    return json.loads(value)

def set_latest_in_cache(device_id, measurement):
    client.set(_key(device_id), json.dumps(measurement))