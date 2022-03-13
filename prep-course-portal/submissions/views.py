from rest_framework import viewsets, mixins

from submissions.models import Submission
from submissions.serializers import SubmissionSerializer


class SubmissionViewSet(mixins.CreateModelMixin,
                        mixins.ListModelMixin,
                        viewsets.GenericViewSet):
    """
    A viewset that provides `retrieve`, `create`, and `list` actions.
    """
    queryset = Submission.objects.all()
    serializer_class = SubmissionSerializer
