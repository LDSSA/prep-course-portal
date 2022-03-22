from django.conf.urls import include, url
from django.contrib import admin
from rest_framework.schemas import get_schema_view

API_TITLE = 'Pastebin API'
API_DESCRIPTION = 'A Web API for creating and viewing highlighted code submissions.'
schema_view = get_schema_view(title=API_TITLE)

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    # Submissions
    url(r'^', include('submissions.urls')),
    # url(r'^schema/$', schema_view),
    # Website
    url(r'^', include('website.urls')),
]
