from rest_framework import serializers

from submissions.models import Submission


class SubmissionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Submission
        fields = ('id', 'created', 'slackid',
                  'learning_unit', 'exercise_notebook', 'score')
        
    # Make a limit to the learning_unit and score allowed
    def validate_learning_unit(self, value):
        if value < 0 or value > 18:
            raise serializers.ValidationError("Learning unit must be between 1 and 18")
        return value
    
    def validate_score(self, value):
        if value < 0 or value > 20:
            raise serializers.ValidationError("Score must be between 0 and 20")
        return value
