from django.urls import path
from .views import create_sos_alert

urlpatterns = [

    path('sos/', create_sos_alert),

]