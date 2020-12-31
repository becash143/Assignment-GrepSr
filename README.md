# Solutions is Properly Based on the Experience, however there are multiple solutions
based on the Cloud Providers #
1. PreRequisites are the Server Credentials and the Kubernets cluster setup
2. Monitoring Can be done using Various tools like Ansible ( instead of shell-script ). Very popular these days. can be used on linux servers. Automation is main objective to use Ansible.
3. Container Monitoring can be done using tools like DataDog,CAdvisor, Prometheous, Grafana/loki, ELK
4. I have used helm chart for Prometheus and Grafana. This are readily available charts to run prometheus and grafana.


We can run the mysql-deployment and myapp-deployment   with  the given command

kubectl apply -f ./mysql-deployment
kubectl apply -f ./myapp-deployment


I have provide helm chart for prometheus and Grafana. Inorder to run the helm chart we need to install helm on the Machine.

Commands to Run Helm charts

helm install prometheus ./prometheus
helm install grafana    ./grafana


Note: We need to make sure the Kubernetes cluster is Running and the Helm Chart is installed. I am not going in details to setup the cluster. 
Also there might be some error during Deployment. So, it can be don eunder the supervision of engineer who have hands on Experience with Kubernetes




