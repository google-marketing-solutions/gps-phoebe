# Demo Environment with gPS Phoebe

This document will guide you through all the steps needed to deploy a demo site
using gPS Phoebe with server side tagging.

For the demo, you will deploy:

-   A Vertex AI model and endpoint, created from fake generated data.
-   A Google Tag Manager variable to hold the predicted value.

Be mindful that each component has some cost associated to it, so make sure to
monitor the billing associated with your project to avoid unexpected charges.

Note: if you just want to deploy the tool and not the demo environment, skip
this document and follow the [main one](../README.md).

## Requirements

-   [Server-side Tag Manager](https://developers.google.com/tag-platform/learn/sst-fundamentals)
    deployed.
-   A Google Tag Manager Web Container created (no need to have anything
    configured yet).
-   [GTM Boilerplate](https://github.com/gtech-professional-services/gtm-boilerplate)
    deployed and configured to use the Google Tag Manager Web container.
    You can find the detailed instructions
    [here](https://github.com/gtech-professional-services/gtm-boilerplate/blob/main/website/README.md#guided-deployment).

## Installation

### Train and deploy the sample model

1. Create a new instance in Vertex AI Workbench following the [official GCP instructions](https://cloud.google.com/vertex-ai/docs/workbench/instances/create#create). We recommend using the default values and the lowest possible configuration for a Virtual Machine.

2. Download the demo [Jupyter notebook](https://github.com/google-marketing-solutions/gps-phoebe/blob/main/demo/notebook/vertex_ai_demo_product_returns_case_study.ipynb) which will help train, evaluate and deploy the demo AI model.

3. Open Jupyterlab in your Vertex AI Workbench instance and upload the notebook you downloaded. Follow the instructions in the notebook to get the model trained and deployed.

### Configure Tag Manager

Download the template files from your browser:

-   [`gtm/phoebe_demo_web_container.json`](gtm/phoebe_demo_web_container.json)
-   [`gtm/phoebe_demo_server_container.json`](gtm/phoebe_demo_server_container.json)

From to the [Google Tag Manager UI](https://tagmanager.google.com/#/home),
select the web container, and then click on `Import Container` from the `Admin`
tab. Select the `phoebe_demo_web_container.json` file and choose overwrite as
the import option.

Next, go to the `Variables` section, open the `Server Container URL` variable
and replace the sample value with the server container URL.

Repeat the import operation from the server container, and use the
`phoebe_demo_server_container.json` file as the import file.

Next, go to the `Variables` section, and replace the following variables with
the right values:

-   `Google Cloud Project Number`: The project number is shown in the
    [home dashboard](https://console.cloud.google.com/home/dashboard) of your
    cloud project.
-   `Google Cloud Region`: The region you used for the deployment above.
-   `Vertex Endpoint ID`: The ID of the Vertex endpoint.

## Disclaimers

**This is not an officially supported Google product.**

*Copyright 2023 Google LLC. This solution, including any related sample code or
data, is made available on an “as is,” “as available,” and “with all faults”
basis, solely for illustrative purposes, and without warranty or representation
of any kind. This solution is experimental, unsupported and provided solely for
your convenience. Your use of it is subject to your agreements with Google, as
applicable, and may constitute a beta feature as defined under those agreements.
To the extent that you make any data available to Google in connection with your
use of the solution, you represent and warrant that you have all necessary and
appropriate rights, consents and permissions to permit Google to use and process
that data. By using any portion of this solution, you acknowledge, assume and
accept all risks, known and unknown, associated with its usage, including with
respect to your deployment of any portion of this solution in your systems, or
usage in connection with your business, if at all.*
