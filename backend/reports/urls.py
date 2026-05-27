from django.urls import path
from .views import upload_report

urlpatterns = [

    path('upload/', upload_report),

]