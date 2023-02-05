import json
from io import BytesIO
import base64
from typing import Union

import pandas as pd
import matplotlib.pyplot as plt

from django.core import serializers

from submissions.models import Submission


def get_submissions() -> pd.DataFrame:
    '''Get all the submissions into a dataframe.'''
    if Submission.objects.exists():
        for sub in Submission.objects.all():
            sub_dict = {
                'created': sub.created,
                'slackid': sub.slackid,
                'learning_unit': sub.learning_unit,
                'exercise_notebook': sub.exercise_notebook,
                'score': sub.score,
            }

        data = serializers.serialize("json", Submission.objects.all())
        data = json.loads(data)
        submissions = [sub['fields'] for sub in data]
    else:
        submissions = []
    df = pd.DataFrame(submissions)

    return df

def get_submissions_plot_data(df: pd.DataFrame) -> Union[pd.DataFrame, None]:
    '''
    Transform the submissions data into a dataframe ready to be ploted.

    :df: from get_submissions()
    :returns: a dataframe ready to be ploted
    '''
    if df.empty:
        return None

    df_plot = (
        df
        .groupby(['learning_unit', 'exercise_notebook'])
        .slackid
        .count()
        .reset_index()
        .pivot(index='learning_unit', columns='exercise_notebook', values='slackid')
        .fillna(0)
        .astype(int)
    )

    return df_plot

def plot_submissions(df_plot: Union[pd.DataFrame, None]) -> Union[str, None]:
    '''
    Plot the submissions, get the plot ready to be displayed in template.
    https://stackoverflow.com/questions/61936775/how-to-pass-matplotlib-graph-in-django-template

    :df_plot: from get_submissions_plot_data()

    :returns: the encoded plot, ready to be passed to the template.
    '''
    if df_plot is None:
        return None

    ax = df_plot.plot.bar(figsize=(16, 4))
    plt.xticks(rotation=0)
    plt.tight_layout()

    buffer = BytesIO()
    plt.savefig(buffer, format='png')
    buffer.seek(0)
    image_png = buffer.getvalue()
    buffer.close()

    graphic = base64.b64encode(image_png)
    graphic = graphic.decode('utf-8')

    return graphic
