from typing import Dict, List
import json

import pandas as pd

from generate_fake_dataframe import generate_fake_dataframe
from submit import submit


df = generate_fake_dataframe(
    size = 100,
    cols = "iiif",
    col_names=["learning_unit", "exercise_notebook", "slackid", "score"],
    intervals = [
        (0, 18), (1, 3),(50_000, 100_000), (0.0, 20.0)
    ],
    seed=42
)
result: str = df.to_json(orient="records")
submissions: List[Dict] = json.loads(result)

for sub in submissions:
    submit(**sub)
