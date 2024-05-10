from django.contrib import admin
from submissions import models

# Submission admin interface
class SubmissionAdmin(admin.ModelAdmin):
    list_display = ('created', 'slackid', 'learning_unit', 'exercise_notebook', 'score')
    list_filter = ('created', 'learning_unit', 'exercise_notebook')
    search_fields = ('slackid', 'learning_unit', 'exercise_notebook')

admin.site.register(models.Submission, SubmissionAdmin)
