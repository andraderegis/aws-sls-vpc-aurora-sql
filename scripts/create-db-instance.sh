CLUSTER_NAME=serverless-ra
USERNAME=regisandrade
PASSWORD=regis123789
DB_NAME=heroes
SECRET_NAME=aurora-secret01

RESOURCE_ARN=arn:aws:rds:us-east-1:609157373734:cluster:serverless-ra
SECRET_ARN=arn:aws:secretsmanager:us-east-1:609157373734:secret:aurora-secret01-2dc97x

aws rds create-db-cluster \
  --engine-version 5.6.10a \
  --db-cluster-identifier $CLUSTER_NAME \
  --engine-mode serverless \
  --engine aurora \
  --master-username $USERNAME \
  --master-user-password $PASSWORD \
  --scaling-configuration MinCapacity=2,MaxCapacity=4,AutoPause=false,TimeoutAction=ForceApplyCapacityChange \
  --enable-http-endpoint \
  --region us-east-1 \
  | tee rds-cluster.json

CREATING="creating"
STATUS=$CREATING

while [ $STATUS == $CREATING ]
do
  STATUS=$(aws rds describe-db-clusters \
    --db-cluster-identifier $CLUSTER_NAME \
    --query 'DBClusters[0].Status' \
    | tee rds-status.json)

  echo $STATUS
  sleep 1
done

# creating secret for aurora access
aws secretsmanager create-secret \
  --name $SECRET_NAME \
  --description "Credentials for aurora serverless db" \
  --secret-string '{"username": "'$USERNAME'", "password": "'$PASSWORD'"}' \
  --region us-east-1 \
  | tee secret.json

# running query for list databases at aurora
aws rds-data execute-statement \
  --resource-arn $RESOURCE_ARN \
  --secret-arn $SECRET_ARN \
  --database mysql \
  --sql "show databases;" \
  --region us-east-1 \
  | tee cmd-show-dbs.json

# running create database at aurora
aws rds-data execute-statement \
  --resource-arn $RESOURCE_ARN \
  --secret-arn $SECRET_ARN \
  --database mysql \
  --sql "CREATE DATABASE $DB_NAME;" \
  --region us-east-1 \
  | tee cmd-create-dbs.json

aws rds describe-db-subnet-groups \
  | tee db-subnets.json

