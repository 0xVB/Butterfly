# Butterfly Math Library

The ButterflyMath Library is a library that contains various math functions that do not exist in the vanilla lua math library. They are used frequently by Butterfly.

## ButterflyMath Functions

| Function | Parameters | Returns | Description |
| - | - | - | - |
| Map | `Number` Number, `Number` Start1, `Number` Stop1, `Number` Start2, `Number`, Stop2 | `Number` | Maps the `Number` from between `Start1` and `Stop1` to being between `Start2` and `Stop2`. |
| MapColor | `Number` StartFrame, `Number` EndFrame, `Number` Frame, `Color3` StartColor, `Color3` EndColor | `Color3` | Returns a color mapped between `StartColor` and `EndColor` by using `StartFrame` and `EndFrame` as refernces. |
| MapUDim2 | `Number` StartFrame, `Number` EndFrame, `Number` Frame, `UDim2` StartUDim2, `UDim2` EndUDim2 | `UDim2` | Returns a UDim2 mapped between `StartUDim2` and `EndUDim2` by using `StartFrame` and `EndFrame` as refernces. |
| GetMajorAxis | `UIObject` Main | `String` | Returns `"X"` if the X absolute size of `Main` is greater than the Y. Otherwise, returns `"Y"` |
| ParseNumber | `BaseNumber` Value, `Number` Interval | `Number` | If `Value` is a number, it returns it. If `Value` is a NumberRange, it returns a number mapped between the indices by the ratio of `Interval`. If `Value` is a NumberSequence, it returns a value mapped between all the sub-indices by the ratio of `Interval`. Note that Interval is between 0-1. |
