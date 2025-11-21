#  Implementation Notes
This was built fast as a POC, it's strongly coupled to the concrete Statsig implementation.
1. Look at the file ´LayerValueRequest.swift´, it shows how we define a request for a layer. One is designed to be fed into the ´HelperGetValue.swift´ utilities, and requires the requested value is a bool, string, number, array, codable object, or limited dictionary, this is represented by the ExperimentValue protocol, defined in ´ExperimentValue.swift´.

Using HelperGetValue means as long as your type conforms, you don't need any additional per-request code, and you remain decoupled from statsig. However, there is a lot of code handling the mapping, and it's limited.

On the other hand in LayerValueRequest there's another struct which accept any type of return value, and it leaves each request to define how you map from StatSig's types, to the desired return value. I quite like this.

In HelperGetValue you can see how we map from ExperimentValue to Statsig's DynamicConfig, and in ExperimentValueCodable you see the boilerplate to let the interface work with any codable JSON type.

## Support for Different Types
### Easy Wins - Scalars and Arrays
Being able to extract a range of scalar types from Statsig is pretty simple, and arrays of scalar types too.

### Ugly and Limited, but Automatic - Homogenous Dictionaries
Being able to extract a dictionary who's keys are strings and who's values are all a scalar or an array is possible automatically, and without too much boilerplate. See HelperBridgingHomogenousDict and HelperBridgingArray for when an object contains an array.
However, it does not support nested objects, the boilerplate feels very hacky and a pretty flaky way to deal with the data from statsig. Functional, but I would not recommend this approach.

### Safe and With Boilerplate - Codable Types
After some thought the real issue here is that Statsig rejected giving us raw JSON for objects, which is by far the most normal way to deal with JSON objects. And they are JSON objects, that's the format the web UI enforces.
The approach here (thanks GPT/Codex for the head start), is to have a small ammount of default implementation boilerplate included in a ExperimentValueCodable type. This allows us to automatically JSONify an input dict, and then decode our Codable type from it.
I've also gone and enabled arrays of codable types, though it will fail if you have an empty array as the default value, since we need an array element to get the type from. We could used a typed overload to get around this.

## A different approach
If you look at LayerValueRequest, you'll see two request wrappers. The CustomLayerValueRequest actually never needs any of the above boilerplate because you pass it a custom handler. It can also handle any type. 
This makes extracting info from StatSig much simpler and flexible by using concrete case-by-case information. But we do expose the Layer object to the consumer, leaking Statsig semantics. Maybe we could write a simple wrapper?

## Example Code
There's examples of reading Scalars, Arrays, Homogenous Dicts and Codable types in the ExperimentValueTests view. They all work.
