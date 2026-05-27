from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Q
from .models import ChatMessage
from .serializers import ChatMessageSerializer

@api_view(['POST'])
def send_message(request):
    try:
        data = request.data
        sender_email = data.get('sender_email', '')
        receiver_email = data.get('receiver_email', '')
        sender_role = data.get('sender_role', 'Mother')
        message = data.get('message', '')

        if not sender_email or not receiver_email or not message:
            return Response({"success": False, "message": "Missing fields"}, status=status.HTTP_400_BAD_REQUEST)

        chat_msg = ChatMessage.objects.create(
            sender_email=sender_email,
            receiver_email=receiver_email,
            sender_role=sender_role,
            message=message
        )
        return Response({
            "success": True,
            "message": "Message sent"
        }, status=status.HTTP_201_CREATED)
    except Exception as e:
        print(f"Chat Send Exception: {e}")
        return Response({"success": False, "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
def get_messages(request):
    messages = ChatMessage.objects.all().order_by('timestamp')
    serializer = ChatMessageSerializer(messages, many=True)
    return Response(serializer.data)

@api_view(['GET'])
def get_conversation(request):
    user1 = request.query_params.get('sender_email')
    user2 = request.query_params.get('receiver_email')
    
    print(f"\n--- BACKEND FETCH QUERY LOGS ---")
    print(f"Logged In User (Sender): {user1}")
    print(f"Target Peer (Receiver): {user2}")

    if not user1 or not user2:
        return Response(
            {"error": "Please provide both sender_email and receiver_email query parameters."}, 
            status=status.HTTP_400_BAD_REQUEST
        )
        
    messages = ChatMessage.objects.filter(
        (Q(sender_email__iexact=user1) & Q(receiver_email__iexact=user2)) |
        (Q(sender_email__iexact=user2) & Q(receiver_email__iexact=user1))
    ).order_by('timestamp')
    
    print(f"Fetched Message Count: {messages.count()}")
    print(f"--------------------------------\n")
    
    serializer = ChatMessageSerializer(messages, many=True)
    return Response(serializer.data)
