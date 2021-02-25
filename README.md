# notepadApp
Notepad application running on Azure

## Setup

Please go through the following steps:

1. follow the instructions in [terraform/README.md](terraform/README.md) to setup your Kubernetes cluster in Azure;
1. then go through [aks/README.md](aks/README.md) to setup the container registry in Azure and the application namespace in the cluster;
1. lastly you need to trigger the pipeline with GitHub Actions to build and deploy the application on the cluster.

## Open issues

### Failed deployment
Unfortunately the deployment fails for timeout; the deployed pods' logs contain:

```
/bin/sh: 1: ./bin/www: Permission denied
```

### Database
The SQLite database is in the pods and it is created empty at every deployment. It should be either in a shared persistent storage claim in the cluster or in a external server; the latter option would require to change the application to let it use MySQL, PostgreSQL or MsSQL Server instead of SQLite.

### Ingress and DNS
An ingress is deployed on the cluster, but it uses a dummy host name (notepad-app.example.com): no DNS has been set up. Neither `ingress-nginx` nor `cert-manager` are installed in the cluster: they could be installed with Helm.

## Business requirements

Here are listed the business requirements of the assignment, and for each of them a comment about the application's compliance to them:

* The Application must serve variable amount of traffic. Most users are active during business hours. During big events and conferences the traffic could be 4 times more than typical.
    * The *Horizontal Pod Autoscaler* should be set up for the application's Kubernetes deployment in order to adapt the amount of pods to the traffic on the application.
* The Customer takes guarantee to preserve your notes up to 3 years and recover it if needed.
    * As previously mentioned the application should be changed to support an external SQL database.
* The Customer ensures continuity in service in case of datacenter failures.
    * The Kubernetes cluster should be able to maintain a costant amout of nodes, so in case one fails, a newer one will be spawned; an external SQL database with regular backups would definitely help.
* The Service must be capable of being migrated to any regions supported by the cloud provider in case of emergency.
    * The provided instructions give the possibility to recreate the same infrastructure within a short period of time.
* The Customer is planning to have more than 100 developers to work in this project who want to roll out multiple deployments a day without interruption / downtime.
    * The GitHub Actions pipeline can be triggered by that amount of developers and having more than one replica in the Kubernetes deployment avoids downtime to the application.
* The Customer wants to provision separated environments to support their development process for development, testing, production in the near future.
    * Different Kubernetes namespaces can be defined for different environments; ideally the production environment's namespace is located on a separate Kubernetes cluster.
* The Customer wants to see relevant metrics and logs from the infrastructure for quality assurance and security purposes.
    * A Log Analytics Workspace can be created in Azure with Terraform together with the Kubernetes cluster in order to get metrics and logs from the cluster.
