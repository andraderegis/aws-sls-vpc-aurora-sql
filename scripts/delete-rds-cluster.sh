CLUSTER_NAME=serverless-ra
SECRET_NAME=aurora-secret01

aws secretsmanager delete-secret \
  --secret-id $SECRET_NAME \
  | tee secret-delete.json

aws rds delete-db-cluster \
  --db-cluster-identifier $CLUSTER_NAME \
  --skip-final-snapshot \
  | tee rds-delete.cluster.json
