# User Import

The import process is based on the [tutorial](tutorial), but modified to our
needs:

1. Columns in the CSV are reordered
2. Added colums
   1. emailVerified: value must be `true` or `false`
   2. locale: value any of `en`, `fr` or `nl`
   3. organisation: value any of the Organisation names as displayed in Keycloak.
3. Fix for newlines appearing for the last group value in the JSON.

## Import file

Prepare an import CSV file based on [user-import__test-users.csv](user-import__test-users.csv).
Depending on the actual users to import, there are a few things to consider:

* If the users need to be aware of their account being created?
  Then 
  * require the VERIFY_EMAIL and TERMS_AND_CONDITIONS actions.
  * set `emailVerified` to false.
* What actions they need to perform after first login:
  * Do they need to set their own password?
    Then
    * require the UPDATE_PASSWORD action.
    * provide a strong password in the CSV, but it can be the same for all.
  * Are we creating users with __Administrator__ or other roles that have access
    to sensitive or other user's data?
    Then require the CONFIGURE_TOTP action.

To prevent stupid mistakes and keep things managable:
* Bulk import only users with the same requirements.
* Do a test with a single test user and mail address (or alias) in your own 
control first, so you can verify the result.  
Delete this user afer import.

### Required actions

* CONFIGURE_TOTP: A must have for users with access to sensitive or other user's
data. For example any user with a group that contains __Administrator__.
* TERMS_AND_CONDITIONS: Recommended for all users
* UPDATE_PASSWORD: Recommended for all non-test users
* update_user_locale: recommended for all user
* VERIFY_EMAIL: recommended for all non-test user


### Conversion to JSON

Use our version of the conversion script: [csvToJsonConverter.sh](csvToJsonConverter.sh).
The command is the same as in the tutorial:

```
   ./csvToJsonConverter.sh [file_name].csv [file_name].json
```

with `[file_name]` something representative for the users it contains.

### Actual import

See section 'Upload JSON File to Keycloak' in the [tutorial](tutorial). Easy
enough to remember, after doing it once.
