from django.db import models

class Doctor(models.Model):
    name = models.CharField(max_length=100)
    specialization = models.CharField(max_length=100)
    hospital = models.CharField(max_length=100)
    experience = models.IntegerField()
    rating = models.FloatField()
    availability = models.CharField(max_length=100)
    profile_image = models.URLField()

    def __str__(self):
        return self.name

class DoctorRequest(models.Model):
    mother_email = models.EmailField(default="mother@example.com")
    mother_name = models.CharField(max_length=255)
    doctor_name = models.CharField(max_length=255)
    doctor_email = models.EmailField(default="doctor@example.com")
    pregnancy_week = models.IntegerField(default=0)
    status = models.CharField(max_length=50, default="pending") # pending, approved, rejected
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.mother_name} -> {self.doctor_name} ({self.status})"

class ChatMessage(models.Model):
    sender_email = models.EmailField()
    receiver_email = models.EmailField()
    sender_role = models.CharField(max_length=50) # Mother, Doctor, Admin
    message = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    def __str__(self):
        return f"From {self.sender_email} to {self.receiver_email} at {self.timestamp}"