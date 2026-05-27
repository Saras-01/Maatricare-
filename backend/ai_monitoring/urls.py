from django.urls import path
from .views import predict_risk, history_risk

urlpatterns = [
    path('predict/', predict_risk),
    path('history/', history_risk),
]
