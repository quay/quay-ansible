#!/bin/bash

set -xe

set -o pipefail

FROM_REGISTRY_PATH=registry.redhat.io/
TO_REGISTRY_PATH=registry.corp.example.com/redhat/
SLASH_REPLACE_CHAR=_
# The following is necessary on Windows skopeo
SKOPEO_OPTS="--override-arch amd64 --override-os linux --insecure-policy "
SKOPEO_COPY_OPTS="--src-creds USERNAME:PASSWORD' --dest-creds USERNAME:PASSWORD"

OCP_TAGS=("v3.11" "v3.11.154")

IMAGES=(
"rhel7/rhel-tools:7.6"
"rhel7/etcd:3.2.26"
"ubi8/ubi:8.0"
"ubi8/ubi-init:8.0"
"ubi8/ubi-minimal:8.0"
"ubi7/ubi:7.7"
"ubi7/ubi-init:7.7"
"ubi7/ubi-minimal:7.7"
##"cloudforms46/cfme-openshift-postgresql"
##"cloudforms46/cfme-openshift-memcached"
##"cloudforms46/cfme-openshift-app-ui"
##"cloudforms46/cfme-openshift-app"
##"cloudforms46/cfme-openshift-embedded-ansible"
##"cloudforms46/cfme-openshift-httpd"
##"cloudforms46/cfme-httpd-configmap-generator"
##"rhgs3/rhgs-server-rhel7"
##"rhgs3/rhgs-volmanager-rhel7"
##"rhgs3/rhgs-gluster-block-prov-rhel7"
##"rhgs3/rhgs-s3-server-rhel7"

#"jboss-amq-6/amq63-openshift"
#"jboss-datagrid-7/datagrid71-openshift"
#"jboss-datagrid-7/datagrid71-client-openshift"
#"jboss-datavirt-6/datavirt63-openshift"
#"jboss-datavirt-6/datavirt63-driver-openshift"
#"jboss-decisionserver-6/decisionserver64-openshift"
#"jboss-processserver-6/processserver64-openshift"
#"jboss-eap-6/eap64-openshift"
#"jboss-eap-7/eap71-openshift"
#"jboss-webserver-3/webserver31-tomcat7-openshift"
#"jboss-webserver-3/webserver31-tomcat8-openshift"
"rhscl/mongodb-36-rhel7:1"
"rhscl/mysql-57-rhel7:5.7"
#"rhscl/perl-524-rhel7"
#"rhscl/php-56-rhel7"
"rhscl/postgresql-96-rhel7:1"
"rhscl/postgresql-10-rhel7:1"
#"rhscl/python-35-rhel7"
#"redhat-sso-7/sso70-openshift"
#"rhscl/ruby-24-rhel7"
"redhat-openjdk-18/openjdk18-openshift:1.6"
"openjdk/openjdk-11-rhel7:1.0"
#"redhat-sso-7/sso71-openshift"
#"rhscl/nodejs-6-rhel7"
"rhscl/mariadb-103-rhel7:1"
"rhscl/httpd-24-rhel7:2.4"
"rhscl/nginx-114-rhel7:1"
)

OCP_IMAGES=(
"openshift3/apb-base"
"openshift3/apb-tools"
"openshift3/automation-broker-apb"
"openshift3/csi-attacher"
"openshift3/csi-driver-registrar"
"openshift3/csi-livenessprobe"
"openshift3/csi-provisioner"
"openshift3/grafana"
"openshift3/local-storage-provisioner"
"openshift3/manila-provisioner"
"openshift3/mariadb-apb"
"openshift3/mediawiki"
"openshift3/mediawiki-apb"
"openshift3/mysql-apb"
"openshift3/ose-ansible-service-broker"
"openshift3/ose-cli"
"openshift3/ose-cluster-autoscaler"
"openshift3/ose-cluster-capacity"
"openshift3/ose-cluster-monitoring-operator"
"openshift3/ose-console"
"openshift3/ose-configmap-reloader"
"openshift3/ose-control-plane"
"openshift3/ose-deployer"
"openshift3/ose-descheduler"
"openshift3/ose-docker-builder"
"openshift3/ose-docker-registry"
"openshift3/ose-efs-provisioner"
"openshift3/ose-egress-dns-proxy"
"openshift3/ose-egress-http-proxy"
"openshift3/ose-egress-router"
"openshift3/ose-haproxy-router"
"openshift3/ose-hyperkube"
"openshift3/ose-hypershift"
"openshift3/ose-keepalived-ipfailover"
"openshift3/ose-kube-rbac-proxy"
"openshift3/ose-kube-state-metrics"
"openshift3/ose-metrics-server"
"openshift3/ose-node"
"openshift3/ose-node-problem-detector"
"openshift3/ose-operator-lifecycle-manager"
"openshift3/ose-ovn-kubernetes"
"openshift3/ose-pod"
"openshift3/ose-prometheus-config-reloader"
"openshift3/ose-prometheus-operator"
"openshift3/ose-recycler"
"openshift3/ose-service-catalog"
"openshift3/ose-template-service-broker"
"openshift3/ose-tests"
"openshift3/ose-web-console"
"openshift3/postgresql-apb"
"openshift3/registry-console"
"openshift3/snapshot-controller"
"openshift3/snapshot-provisioner"
"openshift3/metrics-cassandra"
"openshift3/metrics-hawkular-metrics"
"openshift3/metrics-hawkular-openshift-agent"
"openshift3/metrics-heapster"
"openshift3/metrics-schema-installer"
"openshift3/oauth-proxy"
"openshift3/ose-logging-curator5"
"openshift3/ose-logging-elasticsearch5"
"openshift3/ose-logging-eventrouter"
"openshift3/ose-logging-fluentd"
"openshift3/ose-logging-kibana5"
"openshift3/prometheus"
"openshift3/prometheus-alertmanager"
"openshift3/prometheus-node-exporter"
"openshift3/jenkins-2-rhel7"
"openshift3/jenkins-agent-maven-35-rhel7"
"openshift3/jenkins-agent-nodejs-8-rhel7"
"openshift3/jenkins-slave-base-rhel7"
"openshift3/jenkins-slave-maven-rhel7"
"openshift3/jenkins-slave-nodejs-rhel7"
)

if ! which skopeo > /dev/null; then
  echo "Could not find 'skopeo' on PATH"
  exit 1
fi

for t in ${OCP_TAGS[@]}; do 
    for o in ${OCP_IMAGES[@]}; do 
        IMAGES+=("${o}:${t}")
    done
done

for i in ${IMAGES[@]}; do
    IMAGE=$(echo $i| sed "s@/@${SLASH_REPLACE_CHAR}@")
    for c in 1 2 3 4 5; do
        skopeo ${SKOPEO_OPTS} copy ${SKOPEO_COPY_OPTS} docker://${FROM_REGISTRY_PATH}${i} docker://${TO_REGISTRY_PATH}${IMAGE} && break || sleep 3
    done
done
