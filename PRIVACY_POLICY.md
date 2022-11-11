## Travel Distance: Privacy policy

This is an open source Android app developed by Julian Vos. The source code is available on GitHub under the MIT license; the app is also available on Google Play.

I hereby state, to the best of my knowledge and belief, that I have not programmed this app to collect any personally identifiable information. All data (tracked journeys) created by you (the user) is stored on your device only, and can be simply erased by clearing the app's data or uninstalling it.

### Explanation of permissions requested in the app

The list of permissions required by the app can be found in the `AndroidManifest.xml` file:

https://github.com/Ghoelian/travel_distance/blob/d5f77f5b5ef806a9ea35c5afe77281c523b5ee50/android/app/src/main/AndroidManifest.xml#L3-L4

<br/>

|                   Permission                    | Why it is required                                                                                                                                                                               |
|:-----------------------------------------------:|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `android.permission.ACCESS_BACKGROUND_LOCATION` | Enables the app to access your location data while the app is in the background through the foreground service. You can revoke this permission at any time, but the app will not function without it. |
|     `android.permission.FOREGROUND_SERVICE`     | Enables the app to create foreground services that will send location updates to the app. Permission automatically granted by the system; can't be revoked by user.                              |

<hr style="border:1px solid gray">

If you find any security vulnerability that has been inadvertently caused by me, or have any question regarding how the app protects your privacy, please [open an issue](https://github.com/Ghoelian/travel_distance/issues/new).
