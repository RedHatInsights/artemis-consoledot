from proton import Message
from proton.utils import BlockingConnection
import sys

try:
    conn = BlockingConnection("amqp://localhost:5672")
    sender = conn.create_sender("health-check")

    sender.send(Message(body="ping"))

    conn.close()

    print("AMQP health check OK")
    sys.exit(0)

except Exception as e:
    print(f"AMQP health check failed: {e}")
    sys.exit(1)