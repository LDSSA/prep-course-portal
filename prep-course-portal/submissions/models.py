from django.db import models
from jsonfield import JSONField


class Submission(models.Model):
    created = models.DateTimeField(auto_now_add=True)
    slackid = models.CharField(max_length=100, blank=True, default='')
    learning_unit = models.IntegerField()
    exercise_notebook = models.IntegerField()
    score = models.FloatField()

    class Meta:
        ordering = ('created', )
