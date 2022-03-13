from django.conf.urls import include, url
from rest_framework.schemas import get_schema_view

API_TITLE = 'Pastebin API'
API_DESCRIPTION = 'A Web API for creating and viewing highlighted code submissions.'
schema_view = get_schema_view(title=API_TITLE)

urlpatterns = [
    # Submissions
    url(r'^', include('submissions.urls')),
    # url(r'^schema/$', schema_view),
    # Website
    url(r'^', include('website.urls')),
]
