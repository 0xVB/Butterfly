# Butterfly TypeLock Library

The Butterfly TypeLock Library is used to define set value types in which certain properties can be. It allows for easy type-checking and prevents errors caused by passing the wrong value type to an attribute or a method.

## Table Of Contents
- [Format Of A TypeString](#tstring)
- [TypeString Examples](#examples)
- [Comparing TypeStrings](#cstring)
- [Using TypeString](#usage)

## Format Of A TypeString <a name = "tstring"></a>
A TypeString consists of 2 base bytes and the rest is considered a <b>parameter</b>.

The first byte indicates whether or not the value can be nil. If set to `\0`, the value cannot be nil. If set to `\1`, the value can be nil. Although this can be represented using a single bit, it becomes difficult to access it when it involves bitmath, which could cause lag on modification-intesive user interfaces.

The second byte represents the TypeCheck function. All the TypeCheck functions are listed in the table below and are accompanied by a brief explanation as to how they function. Use the code that fits your intended purpose. Keep in mind that all functions take whether or not the TypeLock is `NULLABLE` into consideration regardless of their `Parameterized` state.
| Code | Name | Parameterized | Description |
| ---- | ---- | ------------- | ----------- |
| `\0` | Object | No | Always returns true unless the value is nil and the TypeLock is not `NULLABLE`. |
| `\1` | Logical | No | Returns true for all values except false. The `NULLABLE` check still applies. |
| `\2` | BaseNumber | No | Returns true if the given value is a `number`, `NumberRange`, or `NumberSequence`. |
| `\3` | BaseColor | No | Returns true if the given value is a `Color3` or a `ColorSequence`. |
| `\4` | BEnum | Yes | Returns true if the given value is a ButterflyEnum that belongs to the library with the given parameter. |
| `\5` | BaseInstance | No | Returns true if the given value is either a ButterflyInstance or a Roblox Instance. This is mainly used for the `Parent` attribute. |
| `\5` | Type | Yes | Returns true if the given value's `type()` result matches the given parameter. |
| `\6` | TypeOf | Yes | Returns true if the given value's `typeof()` result matches the given parameter. |

## TypeString Examples <a name = "examples"></a>
| TypeString | Explanation |
| ---------- | ----------- |
| `\0\0` | This will accept all values except nil, because the first byte is `\0`. |
| `\1\0` | This will accept all values including nil. |
| `\0\6Instance` | The parameter here is `"Instance"`, so it will only return true when the object is a Roblox Instance. Will return false when the value is nil. |
| `\1\6Color3` | Will return true if the value is either a `Color3` or nil. |

## Comparing TypeStrings <a name = "cstring"></a>
Comparing TypeStrings is straight forward. You can use the `TypeLibrary.__EQ(Max, Min)` function to compare two TypeStrings. The function will return true if <b>all</b> the possible values for `Min` exist in `Max`. The opposite does not have to be true, so the order in which you pass the parameters matters.

If this seems complicated, here are some quick examples:
| Max | Min | Result | Explanation |
| --- | --- | ------ | ----------- |
| `\1\2` | `\0\2` | true | Since `Max` accepts <b>all</b> `BaseNumber` values <b>and</b> nil, and `Min` accepts <b>only</b> `BaseNumber` values, the result will be true. If you inverse `Max` and `Min`, the result will be false, since `Min` now accepts <b>more</b> values than `Max`. |
| `\0\0` | `\0\2` | true | Since `Max` accepts <b>all</b> values except nil, then `Min` is a subset of it. |
| `\0\0` | `\1\2` | false | Even though `Max` accepts more values than `Min` in this case, `Min` accepts nil, when `Max` does not. This means that `Min` is not a perfect subset of `Max`, hence the function returns false. |

## Using TypeString <a name = "usage"></a>
In order to use TypeStrings, you can use the `TypeLibrary.IsA(self, TypeString)` to check whether or not the object, `self`, is of the type `TypeString`.