* Write README
* I want hosted access, so I don't have to install this thing.
* Make it so test users load for an app on click,
  which triggers a input for the apps secret, (persist in cookie)
  upon whose submission an app access token fetch request goes off,
  upon whose return the test user fetch goes off,
  upon whose return shit gets rendered
* Error handling for:
  - FB bad responses
  - backend unavailable
  - bad secret
* Cache secret
* Get test users from the ruby backend, so their attributes can be inter-filled with db-stored fields like email & password
