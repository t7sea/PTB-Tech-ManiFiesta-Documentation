From https://docs.expertflow.com/cx/4.6/admin-guide-for-bulk-user-upload-to-keycloak

# Admin Guide For Bulk User Upload To Keycloak
## Introduction
This document is an Admin Guide for the 'Bulk User Upload' functionality in 
Keycloak. This feature allows administrators to upload/add multiple users to 
Keycloak from a CSV file. The administrator provides a CSV file containing all 
the necessary details of the users to be uploaded. This CSV file is then 
converted to a JSON file using a shell script. The administrator uploads this 
JSON file to Keycloak via the 'Partial Import' feature to add all the users at 
once.

## Steps Required
Here is the step by step procedure to bulk upload users to Keycloak.

##Prepare the CSV File
First, you need to prepare a CSV file with the following specified format. It 
should contain all the mentioned details about the users. Here is the format of 
the CSV file with two example records:

```csv
username,firstName,lastName,email,credentials,realmRoles,groups
jdoe,John,Doe,jdoe@example.com,Password123,agent,agents_permission
asmith,Anna,Smith,asmith@example.com,Password456,supervisor;agent,agents_permission;senior_agents_permission
```

There are a total of 7 attributes of a user, 5 of which are single-valued and 2 
are multi-valued.

* __Single-valued attributes__ are those which contain only one value, like a 
user can have only one username, one first name, and so on.
* __Multi-valued attributes__ are those which may contain single or multiple 
values, like a user can have one or multiple roles.

### Single-valued attributes
* Username
* First Name
* Last Name
* Email
* Password

### Multi-valued attributes
* Realm Roles
* Groups

### Convert CSV to JSON
Once you have prepared a CSV file, you need to convert it to a JSON file. Follow
these steps:

1. Copy the Script File 
   1. Copy the `csvToJsonConverterScript.sh` file to the folder where the CSV 
    file is saved.

2. Allow Execute Permission
   1. Allow execute permission to the script file using the following command:
    ```
    chmod +x csvToJsonConverterScript.sh
    ```
   
3. Run the Script
   1. Run the script using the following command:
    ```
    ./csvToJsonConverterScript.sh <inputFile> <outputFile>
    ```
    Here, replace `<inputFile>` with the name of your CSV file and `<outputFile>` 
    with the desired name for the JSON file. For example, if the user data is in 
    `users.csv` and you want to create a JSON file named `users.json`, run the 
    following command:

    ```
    ./csvToJsonConverterScript.sh users.csv users.json
    ```
    Remember that there should not be any spaces in filenames.

After the script is run, a JSON file will be created with the specified output filename.

### Upload JSON File to Keycloak
Once the JSON file is generated, follow these steps to upload it to Keycloak:

1. Log in to Keycloak as Admin.
2. Select the realm in which you want to import/upload users.
3. Go to Realm Settings.
4. Click on the Actions button.
5. Select Partial Import.
6. Click Browse.
7. Select the JSON file generated with the script.
8. You will see the number of users in the file along with a checkbox. 
Click the checkbox.
9. Select Overwrite from drop-down menu.
10. Click Import.
11. Wait for 10 minutes.
12. After 10 minutes, your uploading/importing of users will be completed.
13. Please ensure that you have a good internet connection. Importing speed may 
vary depending on the internet connection. Ideally it takes almost 10 minutes.
14. Click Cancel.

Your users have been successfully uploaded/imported to Keycloak. You can verify 
this by going to Users tab.


#### IMPORTANT NOTE

You should only upload up to 1000 users at a time. The CSV file should not 
contain more than 1000 users. If you have more than 1000 users, you will need to
perform all the above steps for each batch of 1000 users.

If you upload 600 or fewer users at a time, you may see a dialog box (not always)
indicating successful import of users after 6-7 minutes (depending on the internet
connection). If you upload more than 600 users, no dialog box will be shown, and
you will need to wait for 10 minutes for the import to complete successfully.


#### Download Files
Click on the filenames to preview the files, then click the download button to 
download them.

1. CSV to JSON Converter Shell Script: [csvToJsonConverterScript.sh](csvToJsonConverterScript.sh)
2. Sample CSV File: [SampleCSV.csv](SampleCSV.txt)
3. Sample JSON File: [SampleJSON.json](SampleJSON.json)
