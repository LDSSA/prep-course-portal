from django.urls import path
from django.conf import settings
from django.conf.urls.static import static

from . import views

app_name = "website"

urlpatterns = [
    path(
        "",
        view=views.GradesListView.as_view(),
        name="grades-list",
    ),
]
