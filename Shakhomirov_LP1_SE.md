# Solution explanation

Full solution includes the following:
- AWS Lambda Function to execute SQL query
- Athena Tables created with Step Functions

To deploy Full solution in your AWS account simply run this in your command lineas a whole shell script (copy and paste). Make sure <YOUR_S3_BUCKET> exists and replace it with your actual S3 bucket:
```sh
# deploy.sh starts here:
date
TIME=`date +"%Y%m%d%H%M%S"`

MySQLLambdaLocation="<YOUR_S3_BUCKET>/lambdas/mysql_connector"
base=${PWD##*/}
zp=$base".zip" # This will return stack.zip if you are in stack folder.
echo $zp
 
rm -f $zp

pip install --target ./package pymysql 

cd package
zip -r ../${base}.zip .

cd $OLDPWD

zip -r $zp ./mysql_connector

aws s3 cp ./${base}.zip s3://${MySQLLambdaLocation}/${base}${TIME}.zip
# Result:
# upload: ./stack.zip to s3://datalake.staging.liveproject/lambdas/mysql_connector/stack.zip

aws \
cloudformation deploy \
--template-file step_full.yaml \
--stack-name ETLSolutionStaging \
--capabilities CAPABILITY_IAM \
--parameter-overrides "S3LambdaKey"="lambdas/mysql_connector/${base}${TIME}.zip"
```
Keep in mind that everytime we deploy code changes we would want to create a new stack zip file with unique name. Otherwise Cloudformation will not propagate the changes.
```sh
upload: ./stack.zip to s3://datalake.staging.liveproject/lambdas/mysql_connector/stack20230326092933.zip
```

After we deploy the changes our final dag will be like this:
![](final_dag.png)
![](tables_dont_exist.png)
