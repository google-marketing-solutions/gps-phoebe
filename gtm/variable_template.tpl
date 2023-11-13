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

const getEventData = require("getEventData");
const JSON = require('JSON');
const log = require('logToConsole');
const makeInteger = require('makeInteger');
const makeNumber = require('makeNumber');
const makeString = require('makeString');
const makeTableMap = require('makeTableMap');
const object = require('Object');
const promise = require('Promise');
const sendHttpRequest = require('sendHttpRequest');

const strEndsWith = (str, suffix) => {
  return str.indexOf(suffix, str.length - suffix.length) !== -1;
};

// set to true for eCommerce Example
let isEcommerce = true;

const postHeaders = {
  'Content-Type': 'application/json'
};



let globalValues = {};
if (data.data) {
  let customData = makeTableMap(data.data, 'key', 'value');
  for (let key in customData) {
    key = makeString(key);
    if (strEndsWith(key, '_int')) {
      const new_key = key.replace('_int', '');
      globalValues[new_key] = makeInteger(customData[key]);
    } else if (strEndsWith(key, '_num')) {
      const new_key = key.replace('_num', '');
      globalValues[new_key] = makeNumber(customData[key]);
    } else {
      globalValues[key] = customData[key];
    }
  }
}

let postBodyData = {}; 
if (isEcommerce == true) {
  postBodyData = [];
  const items = getEventData("items");
  let ids = [];
  let itemCount = 0;
  for (const item of items) {
    let instance = {};
    for (let key in item) {
      instance[key] = item[key];
    }
    for (let key in globalValues) {
     instance[key] = globalValues[key]; 
    }
    itemCount++;
    instance.index = itemCount;
    postBodyData.push(instance);
  }
}
else {
  postBodyData = [globalValues];
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
            let result_object = JSON.parse(success_result.body);
            let sum = 0;
            result_object.forEach( num => {
              sum += num;
            });
            return makeString(sum);
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
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "items"
              }
            ]
          }
        },
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 5/3/2023, 5:16:28 PM


