from rest_framework import serializers
from .models import PregnancyRisk

class PregnancyRiskSerializer(serializers.ModelSerializer):
    class Meta:
        model = PregnancyRisk
        fields = '__all__'
