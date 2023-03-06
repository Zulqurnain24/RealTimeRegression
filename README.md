# RealTimeRegression #

RealTimeRegression is a framework that helps you perform realtime regression based on attributes of the model like time spent in viewing, image histogram, and title

<img width="645" alt="image" src="https://user-images.githubusercontent.com/6280238/222984389-501e9dc6-610a-4819-9b1c-76b63e06651e.png">


Usage:

## Import framework like this ##

```
import RealTimeRegression
```

You can use FavoriteWrapper<T> class with any object and populate the wrappers in it.
For Example:

#### For struct ####

```    
struct PlanetModel: Identifiable, Codable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
    let date: String
}
```

#### You can use it like this ####

```
let mars = FavoriteWrapper<PlanetModel>()
```

#### Actual data ####

```
mars.model.image = "www.imageurl.com"
mars.model.title = "Mars"
mars.model.description = "Mars is the fourth planet from the Sun – a dusty, cold, desert world with a very thin atmosphere."
mars.model.date = Date()
```

#### Meta data for ML ####

```   
mars.title = mars.model.title
mars.imageHistogram = UIImage(named: "mars.png").imageHistogram()
mars.timeSpent = 10000000 //duation seconds
```

#### when the user opens the detail view for this object do ####

```    
mars.hasOpened = true
```

#### While exiting from detailview do this ####

```
mars.hasClosed = true
```

#### Once you do this timeSpent will be populated and fed into the datagram for this specific object in timespent attribute ####

```   
mars.timeSpent
```

#### Finally you will receive the inference in the form of result which you can assign to the recommendations ####

```   
 var recommendations: [PlanetModel] = []
 var allPlanets: [FavoriteWrapper<PlanetModel>] = []
 .
 .
 .
 let result = try await RealTimeRegression.shared.computeRecommendations(basedOn: allPlanets)
 recommendations = result
```

#### You can adjust the recommendations by setting recommendations parameter like this ####

```   
RealTimeRegression.shared.set(recommendations: 4)
```

#### If you want further help you can consider the code example in which I have used this framework ####

```    
https://github.com/Zulqurnain24/NasaPlanetaryImages/tree/main
```

### Note: This framework can only work with iOS 15 and beyond as it is built on top of CreateML which is only supported for iOS 15 and beyond ###

