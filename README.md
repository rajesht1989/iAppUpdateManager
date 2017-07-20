# iAppUpdateManager


iAppUpdateManager helps your users to update app to latest version available on appstore by prompting an alert.
* Easy integration
* No additial libraries are required
* Drag and drop iAppUpdateManager class into your project
* One time process as the appstore version is taken from itunes api
* Minimal code change in existing code as below


```
iAppUpdateManager *manager = [iAppUpdateManager manager];
[manager evaluateAndShow];
```
Generally this code is recommended to have in ```-application:didFinishLaunchingWithOptions:``` after a delay.

![alt tag](https://github.com/rajesht1989/PublicAssets/raw/master/iAppUpdateManager/DefaultOption.png)

Configure options by setting simple properties. iAppUpdateManager takes care of rest when user selecting an option

```
iAppUpdateManager *manager = [iAppUpdateManager manager];
[manager setShowFromLaunch:2];
[manager setShowType:kOnFirstLaunchOfAWeek];
[manager setShouldShowSkipThisUpdate:YES];
[manager setShouldShowLater:YES];
[manager setShouldShowNever:YES];
[manager evaluateAndShow];
```

![alt tag](https://github.com/rajesht1989/PublicAssets/raw/master/iAppUpdateManager/MoreOptions.png)


