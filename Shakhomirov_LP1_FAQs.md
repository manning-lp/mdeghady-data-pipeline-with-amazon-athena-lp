# FAQs

1. I'm deploying my Step Functions with AWS Cloudformation and keep getting this error:

```sh
Resource handler returned message: "Invalid State Machine Definition: 'MISSING_TRANSITION_TARGET: Missing 'Next' target: 
```
A: Make sure your Step Function definition has correct "Next" and "End" targets, i.e.
```json
 "SomeStep":
    { ...
        "Next": "Create Athena DB"
    },
 "Create Athena DB": {
    ...
 }
...
```

2. I keep getting this error when deploying the stack file: 
```sh
Resource handler returned message: "State Machine Already Exists: 
```
A: Make sure your State Machine ahndler has a uniwue name and hasn't been already deployed in another stack.
```yaml
  MyStateMachine:
    Type: AWS::StepFunctions::StateMachine
    Properties:
      StateMachineName: ETL-StateMachine # Must be unique for account
```


3. I am getting this error while running Step Functions:
```sh
You are not authorized to perform: athena:StartQueryExecution on the resource. 
```



A: Make sure that `StatesExecutionRole` has correct `Policies` attached including `AWS Glue` because Athena would use `glue` to create a database, i.e.
```yaml
  StatesExecutionRole:
    Type: "AWS::IAM::Role"
    Properties:
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: "Allow"
            Principal:
              Service:
                - !Sub states.${AWS::Region}.amazonaws.com
            Action: "sts:AssumeRole"
      Path: "/"
      Policies:
        - PolicyName: StatesExecutionPolicy
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: Allow
                Action:
                  - "lambda:InvokeFunction"
                Resource: "*"
              - Effect: Allow
                Action: # https://docs.aws.amazon.com/athena/latest/ug/udf-iam-access.html
                  - "athena:*"
                Resource: "*"
              - Effect: Allow
                Action:
                  - "glue:*"
                Resource: "*"
              - Effect: Allow
                Action:
                  - "s3:*"
                Resource: "*"

                # https://docs.aws.amazon.com/step-functions/latest/dg/connect-athena.html
```


4. I am getting this error when trying to deploy the stack file:
```sh
...
Proxy: null)' at 'statusMessage' failed to satisfy constraint: Member must have length less than or equal to 1024
```

A: Your Step definition JSON might be malformed. Check all "," and objects and validate your JSON.


5. My Step Function definition seems too be too long and I can't understand why it's not working.

A: Try moving it into a separate JSON file, siplify to just one step and deploy like so to debug:

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: An example template for a Step Functions state machine.
Resources:
  MyStateMachine:
    Type: AWS::StepFunctions::StateMachine
    Properties:
      StateMachineName: HelloWorld-StateMachine
      DefinitionS3Location:
        Bucket: example_bucket
        Key: hello_world.json
      DefinitionSubstitutions:
        HelloFunction: arn:aws:lambda:us-east-1:111122223333:function:HelloFunction
      RoleArn: arn:aws:iam::111122223333:role/service-role/StatesExecutionRole-us-east-1
         
```

Read more in official documentation [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-stepfunctions-statemachine.html)

6. I've created a database but export to S3 failed failed with error:
```sh
Both aurora_load_from_s3_role and aws_default_s3_role are not specified, please see documentation for more details
```

A: When adding MySQL RDS role to export tables to S3 make sure that principal is `rds.amazonaws.com`.
```yaml
    Type: "AWS::RDS::DBCluster"
  RDSDBClusterParameterGroup: 
    Properties: 
      Description: "CloudFormation Sample Aurora Cluster Parameter Group"
      Family: aurora5.6
      Parameters: 
        time_zone: US/Eastern
        ### Add a role to export to s3
        aws_default_s3_role: !GetAtt [ MySQLRDSExecutionRole, Arn ]
        ###
    Type: "AWS::RDS::DBClusterParameterGroup"
```

Read more [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAM.ServiceLinkedRoles.html) and [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Authorizing.IAM.AddRoleToDBCluster.html#aurora_cluster_params_iam_roles)

7. When exporting data from MySQL soemthing goes wrong and I see an error like this:
```sql
11:38:25	SELECT * FROM myschema.transactions INTO OUTFILE S3 's3://datalake.staging.liveproject/data/myschema/mytable/users'  FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'	Error Code: 1871. S3 API returned error: Missing Credentials: Cannot instantiate S3 Client	0.024 sec
```
A: Make sure cluster has `AssociatedRoles` with a proper IAM role. Make sure Cluster parameter group has a `parameter` with that role ARN.

```yaml
  RDSCluster: 
    Properties: 
      DBClusterParameterGroupName: 
        Ref: RDSDBClusterParameterGroup
      Engine: aurora-mysql
      MasterUserPassword: 
        Ref: DBPassword
      MasterUsername: 
        Ref: DBUser

### Add a role to export to s3
      AssociatedRoles:
        - RoleArn: !GetAtt [ MySQLRDSExecutionRole, Arn ]
###
  RDSDBClusterParameterGroup: 
    Properties: 
      Description: "CloudFormation Sample Aurora Cluster Parameter Group"
      Family: aurora-mysql5.7
      Parameters: 
        time_zone: US/Eastern
        ### Add a role to export to s3
        aws_default_s3_role: !GetAtt [ MySQLRDSExecutionRole, Arn ]
        ###
```

8. I am trying to create external Athena tables but keep getting empty tables.
A: Validate that data exists in your bucket. You can do this by running this CLI command:
```sh
aws s3 ls s3://datalake.staging.liveproject/data/myschema/users/ --human-readable --summarize --recursive
```