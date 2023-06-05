___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Vertex Prediction",
  "description": "Variable which obtains the conversion value from an online prediction provided by Vertex AI API. For more information head over to: https://github.com/google/gps-phoebe",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "endpointURL",
    "displayName": "URL of the Proxy App endpoint",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "projectNumber",
    "displayName": "Google Cloud Project Number hosting the Vertex AI model",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "cloudLocation",
    "displayName": "Cloud region where the Vertex AI model is deployed",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "vertexEndpointID",
    "displayName": "ID of the Vertex Endpoint to use",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "requestData",
    "displayName": "Request Data",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "data",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Property",
            "name": "key",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "value",
            "type": "TEXT"
          }
        ],
        "newRowButtonText": "Add Value"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "requestOptions",
    "displayName": "Request Options",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "TEXT",
        "name": "requestTimeout",
        "displayName": "Request Timeout in milliseconds",
        "simpleValueType": true,
        "defaultValue": 3000,
        "valueValidators": [
          {
            "type": "NON_NEGATIVE_NUMBER"
          }
        ]
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const JSON = require('JSON');
const log = require('logToConsole');
const makeInteger = require('makeInteger');
const makeNumber = require('makeNumber');
const makeString = require('makeString');
const makeTableMap = require('makeTableMap');
const promise = require('Promise');
const sendHttpRequest = require('sendHttpRequest');

const strEndsWith = (str, suffix) => {
  return str.indexOf(suffix, str.length - suffix.length) !== -1;
};

const postHeaders = {
  'Content-Type': 'application/json'
};

let postBodyData = {};

if (data.data) {
  let postBodyCustomData = makeTableMap(data.data, 'key', 'value');

  for (let key in postBodyCustomData) {
    key = makeString(key);
    if (strEndsWith(key, '_int')) {
      const new_key = key.replace('_int', '');
      postBodyData[new_key] = [makeInteger(postBodyCustomData[key])];
    } else if (strEndsWith(key, '_num')) {
      const new_key = key.replace('_num', '');
      postBodyData[new_key] = [makeNumber(postBodyCustomData[key])];
    } else {
      postBodyData[key] = [postBodyCustomData[key]];
    }
  }
}

let requestOptions = {headers: postHeaders, method: 'POST'};

if (data.requestTimeout) {
  requestOptions.timeout = makeInteger(data.requestTimeout);
}

const postBody = JSON.stringify(postBodyData);

const fullEndpointURL = data.endpointURL + '/projects/' + data.projectNumber +
    '/locations/' + data.cloudLocation + '/endpoints/' + data.vertexEndpointID;

log("fullEndpointURL: " + fullEndpointURL);

return sendHttpRequest(fullEndpointURL, requestOptions, postBody)
    .then(
        success_result => {
          log(JSON.stringify(success_result));
          if (success_result.statusCode >= 200 &&
              success_result.statusCode < 300) {
            let result_object = JSON.parse(success_result.body)[0][0];
            return result_object;
          } else {
            return -1;
          }
        },
        error_result => {
          return -1;
        });


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 5/3/2023, 5:16:28 PM


