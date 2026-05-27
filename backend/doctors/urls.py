from django.urls import path
from .views import (
    get_doctors, 
    create_doctor_request, 
    approve_request, 
    reject_request, 
    fetch_assigned_patients, 
    fetch_mother_assigned_doctor, 
    admin_dashboard_stats,
    fetch_all_requests
)

urlpatterns = [
    path('', get_doctors),
    path('request/', create_doctor_request),
    path('request/<int:request_id>/approve/', approve_request), # Keeping for backward compatibility if needed
    path('request/<int:request_id>/reject/', reject_request), # Keeping for backward compatibility
    path('approve-request/', approve_request), # Will map to the new POST payload-based view
    path('dashboard/<str:doctor_name>/', fetch_assigned_patients), # Kept for backward compat
    path('patients/', fetch_assigned_patients), # Alias for the new query-param based approach
    path('status/<str:mother_name>/', fetch_mother_assigned_doctor), # Kept for backward compat
    path('assigned-doctor/', fetch_mother_assigned_doctor), # Alias for query-param approach
    path('admin-dashboard/', admin_dashboard_stats),
    path('requests/', fetch_all_requests),
]