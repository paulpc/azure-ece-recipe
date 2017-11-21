# Create 6 Virtual Machines under a Load balancer and configures Load Balancing rules for the VMs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpaulpc%2Fazure-ece-recipe%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fpaulpc%2Fazure-ece-recipe%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Template shamelessly borrowed from the Azure Github repo https://github.com/Azure/azure-quickstart-templates/tree/master/201-2-vms-loadbalancer-lbrules. Mainained the MIT license for that.

This template allows you to create the minimum viable ECE environment in Azure for a three zone architecture from (https://www.elastic.co/guide/en/cloud-enterprise/current/ece-topology-example3.html).

It will create 6 VMs - 2 per zone and a load balancer between them with load balancing rules on port 12443 for management and 9243 for ElasticSearch and Kibana.

This template also deploys a Storage Account, Virtual Network, Public IP address, Availability Set and Network Interfaces.

Once the deployment is complete, log in to the first host and start installing ECE (https://www.elastic.co/guide/en/cloud-enterprise/current/ece-installing.html#ece-installing-first).
*Caveats* here that the install folder is different due to Azure using the /mnt folder, so a modified version of the set up script resides in /opt, so to start the installation, run:
`/opt/elastic-cloud-enterprise.sh install`

On the other hosts, you can then run:
`/opt/elastic-cloud-enterprise.sh install --coordinator-host ecenode0 --availability-zone [ece-region-here] --roles-token '[enter_token_here]'`
where:
- [ece_region_here] is one of the 3 regions you planned (assuming you want 3 regions). By default, you'll have ece-region-1a (you can just add 1b and 1c)
- [enter_token_here] is the allocator / coordinator token you get when creating the first host - you can assign the right function in the interface later
- you might need the ip in stead of the hostname for the coordinator host - it's the first host you installed ECE on.