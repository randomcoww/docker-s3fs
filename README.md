```
docker run -it --rm --device /dev/fuse --cap-add SYS_ADMIN \
  -e AWSACCESSKEYID=id \
  -e AWSSECRETACCESSKEY=secret \
  randomcoww/s3fs:1.84 \
    bucket_name /mnt
```
  
