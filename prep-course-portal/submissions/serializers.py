from rest_framework import serializers

from submissions.models import Submission


class SubmissionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Submission
        fields = ('id', 'created', 'slackid',
                  'learning_unit', 'exercise_notebook', 'score')
