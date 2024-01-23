from django.urls import path
from . import views

urlpatterns = [
    path('', views.regs, name='regs'),
]
