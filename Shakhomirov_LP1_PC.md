
# Project conclusions
Batch data pipelines are popular because historically workloads were primarily batch-oriented in data environments.

We have just built an ETL data pipeline to extract data from MySQL and transform it in datalake. This pattern works best for datasets that aren't very large and require continuous processing because Athena charges according to the volume of data scanned.

The method works well when converting data into columnar formats like Parquet or ORC, combining several tiny files into bigger ones, or bucketing and adding partitions.
