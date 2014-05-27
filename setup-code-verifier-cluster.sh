#!/bin/bash

# Set project ID
PROJECT=${PROJECT-"singpath-hd"}

# Set instance zone
ZONE=${ZONE-"us-central1-a"}

# Set instance region according to the zone
REGION=${REGION-"us-central1"}

# Set a unique tag
TAG=${TAG-"codeverifier"}

VM_COUNT=${VM_COUNT-2}

# Set instance names
i=1
while [[ i -le $VM_COUNT ]]; do
    INSTANCES[$i]="vm$i"
    i=$(( $i + 1 ))
done

for i in ${INSTANCES[@]}; do
    instances="$ZONE/instances/$i,$instances"
done

INSTANCES_LIST=`echo ${INSTANCES[@]}`
instances=${instances%?}

echo "####################################################################"
echo "   Start building Code Verifier Cluster on Google Compute Engine    "
echo
echo "   Project  : $PROJECT "
echo "   Zone     : $ZONE"
echo "   Region   : $REGION"
echo "   TAG      : $TAG"
echo "   Instance : $VM_COUNT"
echo
echo "#####################################################################"

echo -e "##################### \n\n Step 1 : Delete existing vms  $INSTANCES_LIST if they exist \n\n ####################"
gcutil deleteinstance $INSTANCES_LIST \
    --zone=$ZONE --delete_boot_pd --force 2>/dev/null

echo -e "##################### \n\n Step 2 : Creating vms  $INSTANCES_LIST \n\n ####################"
gcutil addinstance $INSTANCES_LIST \
    --metadata_from_file=startup-script:install.sh \
    --project=$PROJECT --machine_type=f1-micro \
    --zone=$ZONE --tags=$TAG --image=backports-debian-7 --auto_delete_boot_disk


# Create a new firewall and apply it to the instances just created
echo -e "\n\n##################### \n\nStep 3 : Delete firewall rule $TAG-firewall if it exists \n\n ####################"
gcutil --project=$PROJECT deletefirewall $TAG-firewall --force 2>/dev/null

echo -e "\n\n##################### \n\nStep 4 : Create firewall rule $TAG-firewall \n\n ####################"
gcutil --project=$PROJECT addfirewall $TAG-firewall --target_tags=$TAG --allowed=tcp:80


# Remove those objects has to be done in order.
# E.g. no ref. to the healthcheach rule should exist to be able to delete it.
echo -e "\n\n##################### \n\nStep 5 : Remove forwarding rules if they exists \n\n ####################"
gcutil --project=$PROJECT deleteforwardingrule $TAG-rule --region=$REGION --force 2>/dev/null
gcutil --project=$PROJECT deletetargetpool $TAG-pool --region=$REGION --force 2>/dev/null
gcutil --project=$PROJECT deletehttphealthcheck $TAG-healthcheck --force 2>/dev/null


# Add a basic health check object
echo -e "\n\n##################### \n\nStep 6 : Create health check object $TAG-healthcheck \n\n ####################"
gcutil --project=$PROJECT addhttphealthcheck $TAG-healthcheck \
    --check_interval_sec=20 --check_timeout_sec=15 \
    --description="Check main verifier" \
    --healthy_threshold=2 --unhealthy_threshold=3 \
    --request_path="/aws/basic_health_check"


# Create a pool of instances
echo -e "\n\n##################### \n\nStep 7 : Add resource pool $TAG-pool \n\n ####################"
gcutil --project=$PROJECT addtargetpool $TAG-pool --region=$REGION --health_checks=$TAG-healthcheck --instances=$instances


# Add a forwarding rule points to instance pool
echo -e "\n\n##################### \n\nStep 8 : Add forwarding rule $TAG-rule \n\n ####################"
gcutil --project=$PROJECT addforwardingrule $TAG-rule --region=$REGION --port_range=80 --target=$TAG-pool


LOADBALANCER_IP=`gcutil getforwardingrule  $TAG-rule --region=$REGION | grep 'ip ' | tr -d "[:alpha:] |"`
echo -e "\n\n#################### \n\n Step 9 : Loadbalancer IP is $LOADBALANCER_IP \n\n ##################"

echo -e "\n\n#################### \n\n Accessing the vms by ssh through the external-ips listed below \n\n ####################"
gcutil listinstances

