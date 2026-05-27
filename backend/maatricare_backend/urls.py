from django.contrib import admin
from django.urls import path, include

urlpatterns = [

    path('admin/', admin.site.urls),

    path('', include('authentication.urls')),

    path('doctors/', include('doctors.urls')),

    path('reports/', include('reports.urls')),

    path('emergency/', include('emergency.urls')),
    
    path('ai-risk/', include('ai_monitoring.urls')),

    path('chat/', include('chat.urls')),
]