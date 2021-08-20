Problem 2:
1.	Create a S3 bucket in the US region (bucket1) with retention  as 30 days.
2.	Trigger an S3 event when object (text file) is placed in the S3 (bucket1)
3.	Trigger a lambda function to move the file to another bucket (bucket2) when S3 event is received
4.	Create a glue Job to compress the bucket2's object with gz
