from rest_framework.decorators import api_view
from rest_framework.response import Response


@api_view(['POST'])
def upload_report(request):

    data = request.data

    uploaded_file = request.FILES.get('file')

    return Response({
        "message": "Report uploaded successfully",
        "report_type": data.get('report_type'),
        "doctor": data.get('doctor'),
        "file_name": uploaded_file.name if uploaded_file else None
    })