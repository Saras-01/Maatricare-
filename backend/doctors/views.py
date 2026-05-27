from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Doctor, DoctorRequest
import json

@api_view(['GET'])
def get_doctors(request):
    doctors = Doctor.objects.all()
    # If no doctors exist, return a mock list so the UI works
    if not doctors.exists():
        mock_doctors = [
            {
                "id": 1,
                "name": "Dr. Elena Rostova",
                "specialization": "Obstetrician & Gynecologist",
                "hospital": "City Hospital NICU",
                "experience": 12,
                "rating": 4.9,
                "availability": "Mon, Wed, Fri",
                "profile_image": "https://i.pravatar.cc/150?img=47",
                "patients": "1.2k",
                "success_rate": "98%",
                "response_time": "< 10 min"
            },
            {
                "id": 2,
                "name": "Dr. Sarah Jenkins",
                "specialization": "Maternal-Fetal Medicine",
                "hospital": "MaatriCare Maternity Center",
                "experience": 15,
                "rating": 4.8,
                "availability": "Tue, Thu, Sat",
                "profile_image": "https://i.pravatar.cc/150?img=44",
                "patients": "2.4k",
                "success_rate": "99%",
                "response_time": "< 5 min"
            }
        ]
        return Response(mock_doctors)
    
    data = []
    for d in doctors:
        data.append({
            "id": d.id,
            "name": d.name,
            "specialization": d.specialization,
            "hospital": d.hospital,
            "experience": d.experience,
            "rating": d.rating,
            "availability": d.availability,
            "profile_image": d.profile_image,
            "patients": "1k+",
            "success_rate": "95%",
            "response_time": "< 15 min"
        })
    return Response(data)

@api_view(['POST'])
def create_doctor_request(request):
    data = request.data
    mother_name = data.get('mother_name')
    mother_email = data.get('mother_email', f"{mother_name}@example.com")
    doctor_name = data.get('doctor_name')
    doctor_email = data.get('doctor_email', "doctor@example.com")
    pregnancy_week = data.get('pregnancy_week', 0)
    status = data.get('status', 'pending')

    if not mother_name or not doctor_name:
        return Response({"error": "mother_name and doctor_name are required"}, status=400)

    try:
        # Check if mother already has a pending or approved request
        existing_request = DoctorRequest.objects.filter(mother_name=mother_name, status__in=['pending', 'approved']).first()
        if existing_request:
            existing_request.doctor_name = doctor_name
            existing_request.doctor_email = doctor_email
            existing_request.pregnancy_week = int(pregnancy_week)
            existing_request.status = status
            existing_request.save()
        else:
            DoctorRequest.objects.create(
                mother_name=mother_name,
                mother_email=mother_email,
                doctor_name=doctor_name,
                doctor_email=doctor_email,
                pregnancy_week=int(pregnancy_week),
                status=status
            )

        return Response({"message": "Doctor request sent for admin approval successfully", "doctor_name": doctor_name})
    except Exception as e:
        return Response({"error": str(e)}, status=500)

@api_view(['POST'])
def approve_request(request, request_id=None):
    try:
        # Extract from payload if not in URL
        if not request_id:
            request_id = request.data.get('request_id')
        req = DoctorRequest.objects.get(id=request_id)
        req.status = 'approved'
        req.save()
        return Response({"message": "Request approved."})
    except DoctorRequest.DoesNotExist:
        return Response({"error": "Request not found."}, status=404)

@api_view(['POST'])
def reject_request(request, request_id=None):
    try:
        if not request_id:
            request_id = request.data.get('request_id')
        req = DoctorRequest.objects.get(id=request_id)
        req.status = 'rejected'
        req.save()
        return Response({"message": "Request rejected."})
    except DoctorRequest.DoesNotExist:
        return Response({"error": "Request not found."}, status=404)

from django.db.models import Q

@api_view(['GET'])
def fetch_assigned_patients(request, doctor_name=None):
    # If not provided in URL, get from query params
    if not doctor_name:
        doctor_name = request.GET.get('doctor_name', '')

    # Fetch ONLY APPROVED assignments for the doctor dashboard
    assignments = DoctorRequest.objects.filter(
        Q(doctor_name__icontains=doctor_name) | Q(doctor_email__iexact=doctor_name),
        status='approved'
    )
    
    print("Doctor:", doctor_name)
    print("Approved Requests:", assignments.count())
        
    patients_list = []
    for a in assignments:
        patients_list.append({
            "mother_name": a.mother_name,
            "mother_email": a.mother_email,
            "lmp_date": None,
            "risk_level": "Low",
            "latest_vitals": "BP: 120/80, HR: 75",
            "ai_status": "Healthy Progress"
        })

    # Fetch pending requests for this doctor to show in "Pending Patient Requests" section
    pending_requests = DoctorRequest.objects.filter(
        Q(doctor_name__icontains=doctor_name) | Q(doctor_email__iexact=doctor_name),
        status='pending'
    )
        
    pending_list = []
    for r in pending_requests:
        pending_list.append({
            "id": r.id,
            "mother_name": r.mother_name,
            "lmp_date": None,
        })

    # Dynamically build appointments and reports based on actual approved patients
    appointments = []
    reports = []
    if patients_list:
        appointments.append({
            "time": "10:00 AM",
            "patient_name": patients_list[0]['mother_name'],
            "type": "Routine Checkup",
            "is_video": False
        })
        if len(patients_list) > 1:
            appointments.append({
                "time": "11:30 AM",
                "patient_name": patients_list[1]['mother_name'],
                "type": "Video Consultation",
                "is_video": True
            })
        
        reports.append({
            "type": "Ultrasound Scan",
            "patient_name": patients_list[0]['mother_name'],
            "ai_insight": "Normal Growth",
            "status": "Pending Review"
        })

    return Response({
        "patients": patients_list,
        "requests": pending_list,
        "appointments": appointments,
        "reports": reports,
        "emergencies": []
    })

@api_view(['GET'])
def fetch_mother_assigned_doctor(request, mother_name=None):
    if not mother_name:
        mother_name = request.GET.get('mother_name', '')
    req = DoctorRequest.objects.filter(mother_name__iexact=mother_name).order_by('-created_at').first()
    if req:
        doctor = Doctor.objects.filter(name=req.doctor_name).first()
        return Response({
            "doctor_id": doctor.id if doctor else 0,
            "doctor_name": req.doctor_name,
            "doctor_email": req.doctor_email,
            "status": req.status
        })
    return Response({"status": "unassigned"})

@api_view(['GET'])
def admin_dashboard_stats(request):
    total_mothers = DoctorRequest.objects.values('mother_name').distinct().count()
    total_doctors = Doctor.objects.count()
    active_pregnancies = DoctorRequest.objects.filter(status='approved').count()
    
    pending_requests = DoctorRequest.objects.filter(status='pending')
    pending_list = []
    for r in pending_requests:
        pending_list.append({
            "id": r.id,
            "mother_name": r.mother_name,
            "doctor_name": r.doctor_name,
            "status": r.status,
            "created_at": str(r.created_at.date())
        })

    return Response({
        "total_mothers": total_mothers,
        "total_doctors": total_doctors,
        "active_pregnancies": active_pregnancies,
        "pending_requests": pending_list,
        "emergencies": [],
        "reports": [],
        "deliveries_completed": 0,
        "high_risk_cases": 0
    })

@api_view(['GET'])
def fetch_all_requests(request):
    pending_requests = DoctorRequest.objects.filter(status='pending')
    data = []
    for r in pending_requests:
        data.append({
            "id": r.id,
            "mother_name": r.mother_name,
            "doctor_name": r.doctor_name,
            "pregnancy_week": f"Week {r.pregnancy_week}",
            "status": r.status,
            "created_at": str(r.created_at.date())
        })
    return Response(data)

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
            return Response({"success": False, "message": "Missing fields"}, status=400)

        chat_msg = ChatMessage.objects.create(
            sender_email=sender_email,
            receiver_email=receiver_email,
            sender_role=sender_role,
            message=message
        )
        return Response({
            "success": True,
            "message": "Message sent"
        })
    except Exception as e:
        print(f"Chat Send Exception: {e}")
        return Response({"success": False, "message": str(e)}, status=500)

@api_view(['GET'])
def get_messages(request):
    sender_email = request.GET.get('sender_email')
    receiver_email = request.GET.get('receiver_email')

    if not sender_email or not receiver_email:
        return Response({"error": "sender_email and receiver_email are required"}, status=400)

    # Fetch messages where either A sent to B, or B sent to A
    messages = ChatMessage.objects.filter(
        Q(sender_email__iexact=sender_email, receiver_email__iexact=receiver_email) |
        Q(sender_email__iexact=receiver_email, receiver_email__iexact=sender_email)
    ).order_by('timestamp')

    serializer = ChatMessageSerializer(messages, many=True)
    return Response(serializer.data)