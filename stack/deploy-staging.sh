#!/usr/bin/env bash
# chmod +x ./deploy-staging.sh
# Run ./deploy-staging.sh
PROFILE=YOUR-AWS-PROFILE
STACK_NAME=MySQLDataConnectorStaging
LAMBDA_BUCKET=datalake-lambdas.aws # Replace with unique bucket name in your account
APP_FOLDER=mysql_connector

date
 
TIME=`date +"%Y%m%d%H%M%S"`
 
base=${PWD##*/}
zp=$base".zip"
echo $zp
 
rm -f $zp

pip install --target ./package -r requirements.txt
# boto3 is not required unless we want a specific version for Lambda

cd package
zip -r ../${base}.zip .

cd $OLDPWD

zip -r $zp "./${APP_FOLDER}" -x __pycache__ 
 
# Check if Lambda bucket exists:
LAMBDA_BUCKET_EXISTS=$(aws --profile ${PROFILE} s3 ls ${LAMBDA_BUCKET} --output text)
#  If NOT:
if [[ $? -eq 254 ]]; then
    # create a bucket to keep Lambdas packaged files:
    echo  "Creating Lambda code bucket ${LAMBDA_BUCKET} "
    CREATE_BUCKET=$(aws --profile ${PROFILE} s3 mb s3://${LAMBDA_BUCKET} --output text)
    echo ${CREATE_BUCKET}
fi
 
# Upload the package to S3:
aws --profile $PROFILE s3 cp ./${base}.zip s3://${LAMBDA_BUCKET}/${APP_FOLDER}/${base}${TIME}.zip

aws --profile $PROFILE \
cloudformation deploy \
--template-file step_full.yaml \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_IAM \
--parameter-overrides \
"StackPackageS3Key"="${APP_FOLDER}/${base}${TIME}.zip" \
"AppFolder"=$APP_FOLDER \
"S3LambdaBucket"=$LAMBDA_BUCKET \
"Environment"="staging" \
"Testing"="false"
