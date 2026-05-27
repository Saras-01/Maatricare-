from django.contrib import admin
from .models import Doctor

@admin.register(Doctor)
class DoctorAdmin(admin.ModelAdmin):
    list_display = ('name', 'specialization', 'hospital', 'experience', 'rating', 'availability')
    list_filter = ('specialization', 'availability', 'hospital')
    search_fields = ('name', 'specialization', 'hospital')
    list_editable = ('availability',)
