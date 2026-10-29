#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_csv_file> <output_json_file>"
    exit 1
fi

# Input CSV file from the first argument
input_file="$1"

# Output JSON file from the second argument
output_file="$2"

# Start of JSON output
echo "{" > "$output_file"
echo '    "users": [' >> "$output_file"

# Read each line of the CSV file and process it
first_line=true
sed 1d "$input_file" | while IFS=',' read -r username email emailVerified firstName lastName locale organisation credentials requiredActions realmRoles groups; do
    if [ "$first_line" = true ]; then
        first_line=false
    else
        echo '        },' >> "$output_file"
    fi
    
    # Start of user entry
    echo '        {' >> "$output_file"
    
    # User attributes
    echo '            "username": "'"$username"'",' >> "$output_file"
    echo '            "enabled": true,' >> "$output_file"
    echo '            "firstName": "'"$firstName"'",' >> "$output_file"
    echo '            "lastName": "'"$lastName"'",' >> "$output_file"
    echo '            "email": "'"$email"'",' >> "$output_file"
    echo '            "emailVerified": '$emailVerified',' >> "$output_file"

    # Attributes map
    echo '            "attributes": {' >> "$output_file"
    echo '                "locale": "'"$locale"'",' >> "$output_file"
    echo '                "organisation": "'"$organisation"'"' >> "$output_file"
    echo '            },' >> "$output_file"

    # Credentials array
    echo '            "credentials": [' >> "$output_file"
    echo '                {' >> "$output_file"
    echo '                    "type": "password",' >> "$output_file"
    echo '                    "value": "'"$credentials"'",' >> "$output_file"
    echo '                    "temporary": false' >> "$output_file"
    echo '                }' >> "$output_file"
    echo '            ],' >> "$output_file"

    # Required actions array
      echo '            "requiredActions": [' >> "$output_file"
      IFS=';' read -r -a requiredActions_array <<< "$requiredActions"
      for ((i=0; i<${#requiredActions_array[@]}; i++)); do
          if [ $i -eq $((${#requiredActions_array[@]}-1)) ]; then
              echo '                "'"${requiredActions_array[$i]}"'"' >> "$output_file"
          else
              echo '                "'"${requiredActions_array[$i]}"'",' >> "$output_file"
          fi
      done
      echo '            ],' >> "$output_file"

    # RealmRoles array
    echo '            "realmRoles": [' >> "$output_file"
    IFS=';' read -r -a realmRoles_array <<< "$realmRoles"
    for ((i=0; i<${#realmRoles_array[@]}; i++)); do
        if [ $i -eq $((${#realmRoles_array[@]}-1)) ]; then
            echo '                "'"${realmRoles_array[$i]}"'"' >> "$output_file"
        else
            echo '                "'"${realmRoles_array[$i]}"'",' >> "$output_file"
        fi
    done
    echo '            ],' >> "$output_file"

    # Groups array
    echo '            "groups": [' >> "$output_file"
    IFS=';' read -r -a groups_array <<< "$groups"
    for ((i=0; i<${#groups_array[@]}; i++)); do
        if [ $i -eq $((${#groups_array[@]}-1)) ]; then
            echo '                "'"${groups_array[$i]/[$'\t\r\n']}"'"' >> "$output_file"
        else
            echo '                "'"${groups_array[$i]}"'",' >> "$output_file"
        fi
    done
    echo '            ]' >> "$output_file"
done

# Closing last user entry without trailing comma
echo '        }' >> "$output_file"

# End of JSON output
echo '    ]' >> "$output_file"
echo "}" >> "$output_file"

echo "Conversion complete. JSON file generated: $output_file"
