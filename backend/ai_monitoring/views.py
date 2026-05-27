from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import PregnancyRisk
from .serializers import PregnancyRiskSerializer

@api_view(['POST'])
def predict_risk(request):
    data = request.data
    
    # Extract values
    bp_str = data.get('blood_pressure', '120/80')
    sugar = float(data.get('sugar_level', 100))
    hemoglobin = float(data.get('hemoglobin', 12))
    
    risk_level = 'Low'
    recommendation = 'All vitals are within normal range. Continue regular checkups.'
    alert_status = 'Normal'
    
    # Simple AI Logic
    is_high_risk = False
    is_medium_risk = False
    
    # Check BP
    try:
        systolic, diastolic = map(int, bp_str.split('/'))
        if systolic >= 140 or diastolic >= 90:
            is_high_risk = True
    except:
        pass
        
    # Check Sugar
    if sugar > 140:
        is_high_risk = True
        
    # Check Hemoglobin
    if hemoglobin < 11.0:
        is_medium_risk = True
        
    if is_high_risk:
        risk_level = 'High'
        recommendation = 'URGENT: High risk detected based on your vitals. Please consult your doctor immediately.'
        alert_status = 'Critical'
    elif is_medium_risk:
        risk_level = 'Medium'
        recommendation = 'Monitor your health closely. Your hemoglobin is low. Consider dietary changes and consult your doctor.'
        alert_status = 'Warning'
        
    # Inject predicted values into data to save to DB
    mutable_data = request.data.copy() if hasattr(request.data, 'copy') else dict(request.data)
    mutable_data['risk_level'] = risk_level
    mutable_data['ai_recommendation'] = recommendation
    
    serializer = PregnancyRiskSerializer(data=mutable_data)
    if serializer.is_valid():
        serializer.save()
        return Response({
            "message": "Risk predicted successfully",
            "risk_level": risk_level,
            "recommendation": recommendation,
            "alert_status": alert_status,
            "data": serializer.data
        }, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def history_risk(request):
    history = PregnancyRisk.objects.all().order_by('-timestamp')
    serializer = PregnancyRiskSerializer(history, many=True)
    return Response(serializer.data)
