

from django.http import JsonResponse
from django.views.generic import View

class HealthCheckView(View):
    def get(self, request):
        return JsonResponse({'status': 'ok'})