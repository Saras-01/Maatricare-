from django.db import models

class ChatMessage(models.Model):
    sender_email = models.CharField(max_length=255)
    receiver_email = models.CharField(max_length=255)
    sender_role = models.CharField(max_length=50, default="Mother")
    message = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    def __str__(self):
        return f"From {self.sender_email} to {self.receiver_email} - {self.timestamp}"
