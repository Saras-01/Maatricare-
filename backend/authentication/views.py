from rest_framework.decorators import api_view
from rest_framework.response import Response


@api_view(['POST'])
def register_user(request):

    data = request.data

    return Response({
        "message": "User registered successfully",
        "data": data
    })


@api_view(['POST'])
def login_user(request):

    data = request.data

    return Response({
        "message": "Login successful",
        "email": data.get('email')
    })