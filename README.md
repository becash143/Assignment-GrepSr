
# Root Causes are #
1) Resources are not monitored  for Servers and the Containers. 
2) Resource Allocations for Each Container is not utilized properly or not configured 
3) HealthCheck is not configured For Containers
4) Storage is not used to Store Data. Disk in the Server is Used to store data rather than Storage Device like EFS, NFS and SAN.


# Solutions are Identified as following:
 
1) monitor the resources in the servers. 
2) Limit and Request the Resources for Containers.
3) Health check for all the Containers.
4) Use Storage for Data Storage like S3, EFS ( incase od AWS). We can use NFS as well.
5) We can enhance the performance of the Containers using the Following Objects in Kubernetes.
  i)Horizontal Pod AutoScaler(HPA) to Autoscale Pods based on the CPU Utilization.
  ii)pod Affinity Pod AntiAffiity Taints and Tolerations.
  iii) Adding more worker node to load balance.
6) Monitoring Kubernetes Clusters using ELK stack incase for logs and Prometheus and Grafana Incase of Metrics for the K8s Cluster.

1) to monitor the resources in the servers 

We need to make sure  we are monitoring CPU, Memory and Disk Usage for all the Provided Servers. The list of servers are the IP addresses of all 50 servers or the hostname that can be connected from Centralized Server or Build Server
```C#
cat <<EOF > server-list.txt
## List of Servers
192.16.100.2
192.16.100.3
192.16.100.4
192.16.100.5
192.16.100.6
192.16.100.7
192.16.100.8
192.16.100.9
192.16.100.10
192.16.100.11
192.16.100.12
192.16.100.13
192.16.100.14
192.16.100.15
192.16.100.16
192.16.100.17
192.16.100.18
192.16.100.19
192.16.100.20
192.16.100.21
192.16.100.22
192.16.100.23
192.16.100.24
192.16.100.25
192.16.100.26
192.16.100.27
192.16.100.28
192.16.100.29
192.16.100.30
192.16.100.31
192.16.100.32
192.16.100.33
192.16.100.34
192.16.100.35
192.16.100.36
192.16.100.37
192.16.100.38
192.16.100.39
192.16.100.40
192.16.100.41
192.16.100.42
192.16.100.43
192.16.100.44
192.16.100.45
192.16.100.46
192.16.100.47
192.16.100.48
192.16.100.49
192.16.100.50
192.16.100.52

EOF
```

```C#
#!/bin/bash

## Script to Monitor Sys STATS
for server in `more ./server-list.txt`
do
ssh $server
## Monitoring CPU
cpu=$(top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}')
## Montitoring Memory
mem=$($server free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
## Monitoring Disk Usage for all the Partions ##
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
  echo $output
  used=$($server echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  echo "The partition \"$partition\" on $(hostname) has used $used% at $(date)" >> /tmp/diskusage.csv
  
  if [ $usep >= 80 ]; then
            echo "The partition \"$partition\" on $(hostname) has used $used% at $(date)" | mail -s "Disk space alert: $used% used" your@email.com
  fi
done

  fi
done
echo "$server, $cpu, $mem" >> /tmp/cpu-mem-disk.csv
done
echo "CPU and Memory Report for `date +"%B %Y"`" | mail -s "CPU and Memory Report on `date`" -a /tmp/cpu-mem-swap.csv |  mail@example.com
```
```C#
## add cronjob to run the script every 30 minutes

crontab -e 

0,30 * * * * stats-monitoring.sh
```

Alert is written for Disk Usage only, we can do same for CPU and memory as well.

Note: This is just an appraoch to monitor servers using shell script, the servers can be monitored using tools like prometheus using node exporter to collect metrices from linux servers and visualized using Grafana. Monitoring Using Grafana-LOKI is written in folder STATS-Monitoring-with-LOKI. 

cd ./STATS-Monitoring-with-LOKI

./monitoring.sh

Some configurations must be modified. Instead of localhost we can provide the IP of the Servers we want to monitor.


2) Limit and Request the Resources for containers. 
   Resource limit is mandatory to start a container and whenver there is available resource container can use them.

```C#
resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 50m
      memory: 128 Mi   
     ```          
               
 3) Health check for Containers. We use l ivenessProbe, Readiness Probe and Startup Probe to check the health status of Containers. Depending on the health check and Restart Policy Defined Containers are either are removed or restarted. 
 ```C#
 livenessProbe:
    httpGet:
      path: /persons/
      port: 8090
    initialDelaySeconds: 60
    periodSeconds: 300
             
  readinessProbe:
      httpGet:
        path: /actuator/health
        port: 8090
      initialDelaySeconds: 60
      periodSeconds: 300
      ```
 ```C#     
startupProbe:
  httpGet:
    path: /persons/
    port: 8090
  failureThreshold: 30
  periodSeconds: 10 
```
Note:

ReadinessProbe check for the Application to get ready, Lets say if the Apllications runs at port 8090 and the port is accessible we can say the Apllication is ready. 
However, for the Liveness of the Application the Apllication must be functioning correctly. Let us say  we could write an healthcheck script in the application and check it using the route path.
We’ve seen a program fail by exiting with a nonzero exit code. But workers can fail in other ways. Specifically, they can get stuck and not make any forward progress.To help cover this case, you can use liveness probes with jobs. If the liveness probeolicy determines that a Pod is dead, it’ll be restarted/replaced.


4) Use Storage for Data Storage like S3, EFS ( incase od AWS). 
   We can use NFS as well.

                    
5)We can enhance the performance of the Containers using the Following Objects in Kubernetes 
i) we can use Horizontal Pod AutoScaler(HPA) to Autoscale Pods based on the CPU Utilization.The Replicas will autoscale based on the CPU utilization.

```C#
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: myapp
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50
  ```
  
  
  6) Use the Objects like Node Affinity, Pod  Affinity, Pod AntiAffinity, Taints and tolerations to schedule the containers in desired worker nodes or restrict the containers in the desired  
   worker-nodes.

We need a deployment manifest to run a a Kubernetes cluster. This is just a sample deployment.yaml file for single application, with 3 replicas.Replicas will be distributed along the worker-nodes inorderto load balance based on the Objects defined in the deployment Manifest file. For every applications we need to write a deployment.yaml


The deployment consist of initContainers to check the status of the database. 


PreRequisite to Run this Deployment file:

i)We need to have a Kubernetes Cluster setup.
ii) Mysql Deployment.yaml

command to run this Deployment 

kubectl apply -f deployment.yaml



deployment.yaml 

```C#
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:  
  selector:
    matchLabels:
      app: myapp
  replicas: 3
  template:     
    metadata:
      labels:
        app: myapp 
    spec:
      initContainers:
        - name: db-check
          image: mysql:8.0
          imagePullPolicy: Always
          env:
            - name: HOST
              value: mysql-service
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                 secretKeyRef:
                    name: mysql-secret
                    key: MYSQL_ROOT_PASSWORD
            - name: PORT
              value: '3306'
          command: [ "sh", "-c" ]
          args:
            - echo starting;
              chmod +x /tmp/my-config.sh;
              sh /tmp/my-config.sh;
              
              echo done;
          volumeMounts:
             - name: workdir
               mountPath: "/tmp"               
      containers:
        - image: bikclu/myapplication:200908-91ba4d8
          name: myapp
          imagePullPolicy: Always
          env:
           - name: SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT
             value: org.hibernate.dialect.MySQL8Dialect
           - name: SPRING_DATASOURCE_DRIVER-CLASS-NAME
             value: com.mysql.cj.jdbc.Driver
           - name: SPRING_DATASOURCE_URL
             value: jdbc:mysql://mysql-service/assignment?allowPublicKeyRetrieval=true
           - name: SPRING_DATASOURCE_USERNAME
             value: root
           - name: MYSQL_ROOT_HOST 
             value: '%'
           - name: MYSQL_ROOT_PASSWORD
             valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_ROOT_PASSWORD               
          resources:
             requests:
               cpu: 200m
               memory: 512Mi
             limits:
               cpu: 50m
               memory: 128Mi  
          livenessProbe:
             httpGet:
               path: /persons/
               port: 8090
             initialDelaySeconds: 60
             periodSeconds: 60
             
          readinessProbe:
             httpGet:
               path: /actuator/health
               port: 8090
             initialDelaySeconds: 60
             periodSeconds: 60
          
         startupProbe:
            httpGet:
             path: /persons/
             port: 8090
           failureThreshold: 30
           periodSeconds: 60
        
          ports:
           - containerPort: 8090

      volumes:
       - name: workdir
         configMap:
           name: init-script
      restartPolicy: OnFailure

```
ii) Adding more worker node to the Kubernetes Cluster.
iii) Monitoring Container Logs Using ELK/EFK stack and Monitoring Container Metrics with Prometheus and Grafana
```C#
cd ./ELK-Monitoring 

kubectl apply -f .
```

Prometheus and Grafana for Prometheus are Defined in Helm Chart. So we need to install Helm in the Server and run the command as following
```C#
helm install <release-name> ./prometheus
helm install <release-name> ./grafana
````

Command may differ from helm2 and helm3.  

