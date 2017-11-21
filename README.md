# Create 6 Virtual Machines under a Load balancer and configures Load Balancing rules for the VMs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpaulpc%2Fazure-ece-recipe%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fpaulpc%2Fazure-ece-recipe%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Template shamelessly borrowed from the Azure Github repo https://github.com/Azure/azure-quickstart-templates/tree/master/201-2-vms-loadbalancer-lbrules. Mainained the MIT license for that.
This template allows you to create the minimum viable ECE environment in Azure for a three zone architecture from (https://www.elastic.co/guide/en/cloud-enterprise/current/ece-topology-example3.html).

We will create 6 VMs - 2 per zone and a load balancer between them with rules on port 12443 for management and 9243 for ElasticSearch and Kibana.

This template also deploys a Storage Account, Virtual Network, Public IP address, Availability Set and Network Interfaces.

In this template, we use the resource loops capability to create the network interfaces and virtual machines