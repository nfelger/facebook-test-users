* Write README
* Error handling for:
  - FB bad responses
  - backend unavailable
  - bad secret
* Allow specifying whether app should be installed on user create.
* Allow specifying custom permissions on user create.
* Visual progress feedback when doing async calls.
* Better FBC auth: e.g., don't show button when connected, don't require reload after initial connection.
* Bug: deleting multiple rows at once doesn't seem to quite work without jitter (user list blanking every now and then).
* Make cookie-caching of app secrets opt-out with a checkbox.
* Don't send plain-text secrets in the cookie.
