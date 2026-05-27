from django.db import models

class PregnancyRisk(models.Model):
    RISK_LEVELS = [
        ('Low', 'Low'),
        ('Medium', 'Medium'),
        ('High', 'High'),
    ]

    mother_name = models.CharField(max_length=255)
    age = models.IntegerField()
    blood_pressure = models.CharField(max_length=20) # e.g., "120/80"
    sugar_level = models.FloatField()
    hemoglobin = models.FloatField()
    weight = models.FloatField()
    symptoms = models.TextField(blank=True)
    risk_level = models.CharField(max_length=20, choices=RISK_LEVELS, blank=True)
    ai_recommendation = models.TextField(blank=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.mother_name} - {self.risk_level} Risk"
