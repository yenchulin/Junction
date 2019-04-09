##  File Descriptions

### Models
>  A data model group, which includes `User` and `WorkExperience`.

*Note: `WorkExperience` is one of a property type of  `User`*.


###  CustomUI
>  A group that contains every UI component that is customed due to convenience (`@IBDesignable` and `@IBInspectable`) and requirements.


###  Extensions
>  A group that extends the functionality of some native classes in Swift.


###  Fonts
>  A group that contains the font styles which is not system built-in but is used in this whole project.


###  linkedin-sdk.framework
>  It is a framework for using LinkedIn APIs throughout the APP.

*Note: Downloaded and guided from [Getting Started with the Mobile SDK for iOS](https://developer.linkedin.com/docs/ios-sdk)*


###  AppDelegate
>  It is a Swift file that controls how app react when in different states.
  *  `application(_:,didFinishLaunchingWithOptions:)` :  It is called when the app finished launching. Besides, the status bar is adjusted here, making a white color when the navigation bar is dark styled.
  *  `application(_:,open:,options:)` :  It is used for deep linking, providing the ability to get back to the app automatically when the app has been redirect to somewhere else.
  

###  SignInViewController
>  It is a `ViewController` that controls the functionality of the sign in page. This includes sign in, and check if the user is already a member. Currently, there is only one sign in option, LinkedIn.


###  BasicInfoViewController
>  It is a `ViewController` that shows the registration form for user to fill in. Basically, this page (page 1) only includes name, gender, education, email, and phone.


###  SkillViewController
>  It is a `ViewController` that shows the registration form for user to fill in. This page (page 2) includes working experiences, self introduction, and skill fields.


###  InterestViewController
>  It is a `ViewController` that shows the registration form for user to fill in. This page (page 3) includes project descrpitions that the user is satisfied with and that the user want to work with in the future.
  

###  MainTabController
>  It is a `ViewController` that is subclassed to `TabController`, and is responsible for the functionality of the tabs on the bottom of the screen. It is the primary entry point of the app, thus it is responsible for checking whether the user is logged into LinkedIn or not.


###  DrawCardViewController
>  It is a `ViewController` that draws and shows the card on the screen. It also provides user interactions such as tinder-like swipe.


###  CardTableViewController
>  It is a `ViewController` that is subclassed to `TableViewController`, and lists the friends that the user have got. The prototype of how each `cell` looks like and includes is defined in `Main.storyboard` and `CardTableViewCell`.


###  CardDetailViewController
>  It is a `ViewController` that shows the detail of `cell` when the user selects it in the `CardDetailViewController`. Typically, it includes the info of the friend.


###  SettingsTableViewController
>  It is a `ViewController` that is subclassed to `TableViewController`, and provides the functionality of modifying profile, preferences, and information of Dots.

