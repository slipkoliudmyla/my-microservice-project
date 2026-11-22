from django.db import OperationalError, connection
from django.http import HttpResponse, JsonResponse
from django.urls import path


def home(request):
    return HttpResponse(
        '<!doctype html><html lang="uk"><meta charset="utf-8">'
        '<title>GoIT DevOps</title><h1>Django працює</h1>'
        '<p>Цю сторінку Django повертає через Nginx.</p>'
        '<p><a href="/health/">Перевірити підключення до PostgreSQL</a></p></html>'
    )


def health(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
    except OperationalError:
        return JsonResponse({"database": "unavailable"}, status=503)
    return JsonResponse({"database": "ok"})


urlpatterns = [path("", home), path("health/", health)]
