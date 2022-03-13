from django.views.generic import ListView

from submissions import models
from website.utils import (
    get_submissions,
    get_submissions_plot_data,
    plot_submissions,
)


class GradesListView(ListView):
    model = models.Submission
    # the minus in the order by makes it in descending order
    # https://docs.djangoproject.com/en/dev/ref/models/querysets/#order-by
    queryset = models.Submission.objects.order_by("-learning_unit", "-exercise_notebook", "-created")
    template_name = "grades_list.html"
    detail_view_name = "website:grades"

    def get_queryset(self):
        # no need to call super().get_queryset() because
        # "By default, it returns the value of the queryset attribute"
        # https://docs.djangoproject.com/en/3.2/topics/class-based-views/generic-display/#dynamic-filtering
        slackid = self.request.GET.get("slackid")
        learning_unit = self.request.GET.get("learning_unit")
        exercise_notebook = self.request.GET.get("exercise_notebook")
        # TODO this is inneficient, is there a better way?
        queryset = self.queryset.all()
        if slackid:
            queryset = queryset.filter(slackid=slackid)
        if learning_unit:
            queryset = queryset.filter(learning_unit=learning_unit)
        if exercise_notebook:
            queryset = queryset.filter(exercise_notebook=exercise_notebook)

        return queryset.order_by("-learning_unit", "-exercise_notebook", "-created")

    # noinspection PyAttributeOutsideInit
    def get(self, request, *args, **kwargs):
        self.object_list = self.get_queryset()
        context = self.get_context_data(
            object_list=self.object_list, detail_view_name=self.detail_view_name
        )

        df = get_submissions()
        df_plot = get_submissions_plot_data(df)
        graphic = plot_submissions(df_plot)
        context['graphic'] = graphic

        return self.render_to_response(context)
