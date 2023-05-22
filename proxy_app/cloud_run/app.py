# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""A proxy app to enable Vertex AI calls from Server-Side Tag Manager."""

import os

import pprint
from typing import Dict

from flask import abort
from flask import Flask
from flask import request
from google.cloud import aiplatform
from google.protobuf import json_format
from google.protobuf import struct_pb2


def get_prediction(
    project: str,
    endpoint_id: str,
    instance_dict: Dict,
    location: str,
):
  """Calls a Vertex AI endpoint and returns a prediction based on input data.

  Args:
    project: the GCP project of the endpoint.
    endpoint_id: the endpoint ID.
    instance_dict: the input dictionary to pass to the endpoint.
    location: the region where the endpoint is located.

  Returns:
    A prediction object.
  """
  client_options = {'api_endpoint': f'{location}-aiplatform.googleapis.com'}
  client = aiplatform.gapic.PredictionServiceClient(
      client_options=client_options
  )
  instance = json_format.ParseDict(instance_dict, struct_pb2.Value())
  instances = [instance]
  parameters_dict = {}
  parameters = json_format.ParseDict(parameters_dict, struct_pb2.Value())
  endpoint = client.endpoint_path(
      project=project, location=location, endpoint=endpoint_id
  )
  response = client.predict(
      endpoint=endpoint, instances=instances, parameters=parameters
  )
  predictions = response.predictions
  return pprint.pformat(predictions, indent=4)


app = Flask(__name__)


@app.route('/')
def root():
  """Return 400 for root path."""
  abort(400, 'Bad Request')


@app.route(
    '/predict/projects/<project_number>/locations/<location>/endpoints/<endpoint_id>',
    methods=['POST'],
)
def predict(project_number, location, endpoint_id):
  """Calls a Vertex AI endpoint and returns a prediction based on input data."""
  results = get_prediction(
      project=project_number,
      endpoint_id=endpoint_id,
      location=location,
      instance_dict=request.json,
  )
  return results

if __name__ == '__main__':
    server_port = os.environ.get('PORT', '80')
    app.run(debug=False, port=server_port, host='0.0.0.0')
