[root@InfraDB137 E19143]# rclone config
Current remotes:

Name                 Type
====                 ====
minio44              s3

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> n
name> minio_test
Type of storage to configure.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
 1 / 1Fichier
   \ "fichier"
 2 / Alias for an existing remote
   \ "alias"
 3 / Amazon Drive
--- 생략 ---
Storage> s3
** See help for s3 backend at: https://rclone.org/s3/ **

Choose your S3 provider.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
 1 / Amazon Web Services (AWS) S3
   \ "AWS"
 2 / Alibaba Cloud Object Storage System (OSS) formerly Aliyun
   \ "Alibaba"
 --- 생략 ---
provider> minio
Get AWS credentials from runtime (environment variables or EC2/ECS meta data if no env vars).
Only applies if access_key_id and secret_access_key is blank.
Enter a boolean value (true or false). Press Enter for the default ("false").
Choose a number from below, or type in your own value
 1 / Enter AWS credentials in the next step
   \ "false"
 2 / Get AWS credentials from the environment (env vars or IAM)
   \ "true"
env_auth> true
AWS Access Key ID.
Leave blank for anonymous access or runtime credentials.
Enter a string value. Press Enter for the default ("").
access_key_id> minio
AWS Secret Access Key (password)
Leave blank for anonymous access or runtime credentials.
Enter a string value. Press Enter for the default ("").
secret_access_key> minio1234
Region to connect to.
Leave blank if you are using an S3 clone and you don't have a region.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
 1 / Use this if unsure. Will use v4 signatures and an empty region.
   \ ""
 2 / Use this only if v4 signatures don't work, e.g. pre Jewel/v10 CEPH.
   \ "other-v2-signature"
region>
Endpoint for S3 API.
Required when using an S3 clone.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
endpoint> http://1.1.1.1:9001
Location constraint - must be set to match the Region.
Leave blank if not sure. Used when creating buckets only.
Enter a string value. Press Enter for the default ("").
location_constraint>
Canned ACL used when creating buckets and storing or copying objects.

This ACL is used for creating objects and if bucket_acl isn't set, for creating buckets too.

For more info visit https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl

Note that this ACL is applied when server-side copying objects as S3
doesn't copy the ACL from the source but rather writes a fresh one.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
 1 / Owner gets FULL_CONTROL. No one else has access rights (default).
   \ "private"
--- 생략 ---
Remote config
--------------------
[minio_test]
type = s3
provider = minio
env_auth = true
access_key_id = minio
secret_access_key = minio1234
endpoint = http://1.1.1.1:9001
--------------------
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
y/e/d>
Current remotes:

Name                 Type
====                 ====
minio_test           s3

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> q
[root@InfraDB137 E19143]# vim /root/.config/
abrt/          google-chrome/ htop/          rclone/
[root@InfraDB137 E19143]# vim /root/.config/rclone/rclone.conf
