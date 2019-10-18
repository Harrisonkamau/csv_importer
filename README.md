# csv data processor
## Introduction

A tutorial to demo how to speedily import huge CSV datasets from an SFTP server into a database.

# Structure of the app

You can find all the necessary logic inside of: `lib` folder.

You may want to have the following environment vars setup first before attempting to run the rake task:

```sh
# sftp credentials
'SFTP_HOST'
'SFTP_USERNAME'
'SFTP_PASSWORD'

# files pick_up & drop_off paths
'PICK_UP_PATH'
'ARCHIVE_PATH'

# regex - to be used to search for the file
'SRC_FILE_REGEX'
```

# Running the rake task
After cloning the repo, run the task with the following command
```rb
rake locations:download
```
