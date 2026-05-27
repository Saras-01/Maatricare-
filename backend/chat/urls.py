from django.urls import path
from .views import send_message, get_messages, get_conversation

urlpatterns = [
    path('send/', send_message),
    path('messages/', get_messages),
    path('conversation/', get_conversation),
]
