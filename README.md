# GitHoop
## _Sample `MVVM-C` + `CLEAN` implementation for GitHub 'users' API._

### Features

This app lists up all users by querying the username, and includes the unit tests for the view models.
By binding multiple Views with a single View Model, the user list can be displayed as table view, and collection view as well.

### Architecture

As CLEAN architecture provides the separation by responsibilities as layers, the MVVM components can be placed in the corresponding layers.

You can find..
- `Model` in Data Layer
- `View Model` in Domain Layer
- `View` in Presentation Layer( GitHoop )

Each layers interact via the interfaces( -ProviderType, -ViewModelType ) that are provided by Domain Layer. 

- Domain Layer is responsibile for all the business logics as forms of View Model, so other two layers can stay decoupled and be replaced with any component if it confirms the Domain Layer's requirements( interfaces ). 
- Data Layer is responsible for the data models and its mapping to the abstracted business models in the Domain Layer.
- The Views in Presentation Layer( GitHoop ) bind the inputs and outputs of the View Models in Domain Layer, and provide the user interactions. 

### TODO
- SwiftUI + Combine version
- Swift Packages instead of CocoaPods
