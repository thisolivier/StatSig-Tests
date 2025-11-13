#  Implementation Notes
This was built fast as a POC, it's strongly coupled to the concrete Statsig implementation.

## Support for Different Types
### Easy Wins - Scalars and Arrays
Being able to extract a range of scalar types from Statsig is pretty simple, and arrays of scalar types too.

### Ugly and Limited, but Automatic - Homogenous Dictionaries
Being able to extract a dictionary who's keys are strings and who's values are all a scalar or an array is possible automatically, and without too much boilerplate. See HelperBridgingHomogenousDict and HelperBridgingArray for when an object contains an array.
However, it does not support nested objects, the boilerplate feels very hacky and a pretty flaky way to deal with the data from statsig. Functional, but I would not recommend this approach.

### Safe and With Boilerplate - Codable Types
After some thought the real issue here is that Statsig rejected giving us raw JSON for objects, which is by far the most normal way to deal with JSON objects. And they are JSON objects, that's the format the web UI enforces.
The approach here (thanks GPT/Codex for the head start), is to have a small ammount of default implementation boilerplate included in a ExperimentValueCodable type. This allows us to automatically JSONify an input dict, and then decode our Codable type from it.

## Example Code
There's examples of reading Scalars, Arrays, Homogenous Dicts and Codable types in the ExperimentValueTests view. They all work.

## Further Thoughts
Statsig's Array support isn't fully mirrored, since it exposes any valid JSON array- meaning arbitrarily complex JSON objects can be added to an array, as well as heterogenious arrays (a mix of types).

What we aren't supporint currently is and arrays containing objects. Simple to support the current codable techniques in arrays.

I might get Codex to give it a shot.
