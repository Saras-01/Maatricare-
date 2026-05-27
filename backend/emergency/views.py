from rest_framework.decorators import api_view
from rest_framework.response import Response


@api_view(['POST'])
def create_sos_alert(request):

    data = request.data

    return Response({
        "message": "Emergency SOS alert created successfully",
        "mother_name": data.get('mother_name'),
        "emergency_type": data.get('emergency_type'),
        "status": data.get('alert_status')
    })