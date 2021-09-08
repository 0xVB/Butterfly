# ButterflyEnum Library

The ButterflyEnum Library contains special values cannot be represented using simple values such as numbers or strings. It is possible to heavily modify ButterflyUI by simply creating new Enumerators and setting properties to them. Every enum has a numerical value. You can use this to simplify recalling it, so instead of typing ouy the enum's path, you can just use its numerical value instead.

## Table Of Contents
- [List Of ButterflyEnums](#benums)
- <b>CORE</b>: [ButterflyEnum Meta Structure](#mtstruct)
- <b>CORE: </b> [How To Create Your Own Enums](#htcreate)

## List Of ButterflyEnums <a name = "benums"></a>
- [CornerType]

### CornerType Values <a name = "cornertype"></a>
All CornerTypes shown in the preview below have the `CornerSize` property set to 25(px). The total image size is 200x100px, so do not take this for a standard look. For example, a Background with the CornerType `Round` could look like a perfect circle if the `CornerSize` property was set to half of its actual size, as demonstrated here:
<img="Documentation/ImageAssets/A7uqjkW4q1.gif">
| Name | Shape |
| ---- | ----- |
| Round | |

## ButterflyEnum Meta Structure <a name = "mtstruct"></a>

The metatable of ButterflyEnums is as follows:

| Index | Value Type | Value | Description |
| - | - | - | - |
| "\0" | `String` | Name | The name of the enumerator. |
| "\1" | `ButterflyEnum (NULLABLE)` | Parent | The parent of the enumerator. It could be nil. |
| "\2" | `Object (NULLABLE)` | Value | The value of the enumerator. It could be nil, and represents the data that the enumerator holds. It is most likely a function or a table. |
| "\3" | `Byte` | ByteValue | The ByteValue (NumericalValue) that represents this enum. If the enum has a parent, the ByteValue will be its index in the parent's children table. |
| "\4" | `Table` | Children | A table that contains all the children/sub-enums of this enum. They are indexed according the ByteValue of its children. |

## How To Create Your Own Enums <a name = "htcreate"></a>

In order to create your own enums, you will have to use the ButterflyCore library. The ButterflyEnum constructor function exists in the following location:
```lua
ButterflySpace.Core.Constructors.Enum
```
It takes the following parameters. If a parameter is marked with `(NULLABLE)`, that means it's optional.
| Type | Parameter | Description |
| - | - | - |
| `String` | Name | The name of the enumerator. |
| `ButterflyEnum (NULLABLE)` | Parent | The parent (container) of the enumerator. |
| `Object (NULLABLE)` | Value | The value (contents) of the enumerator. They could be any value. |
| `Byte (NULLABLE)` | ByteValue | The byte that will represent the key of enumerator in its parent's children table. It could be used to overwrite previously existing enums by using their ByteValue. |
It returns a proxy, which is going to be the enum value itself. You can later use it to create other sub-enums inside it if you need to.

Looking at how the original ButterflyUI creates its enums is the best way to learn how to use this function. Here is a quick example:
```lua
local Create = ButterflySpace.Core.Constructors.Enum;
local ButterflyEnum = ButterflySpace.ButterflyEnum;

local Library = Create("EnumLibrary", ButterflyEnum);--Creates an enum called "EnumLibrary" located directly in ButterflyEnum. We then store it in a variable.

Create("Value0", Library, "Konrushi!");--We can create new enums inside of it by using the value it returned.
Create("Value1", ButterflyEnum.EnumLibrary, "Konrushi!!");--We can also create them by indexing it again, in case we didn't save a variable.

print(Library.Value0);--We can print the enum by indexing it from the library.
print(ButterflyEnum.EnumLibrary.Value1:GetValue());--We can also print its value, and index it indirectly, too!
```

Of course, different attributes treat the `Value` of an enumerator differently. You will have to see the separate documentation on an individual [ButterflyEnum type](#benums) in order to learn how it treats different values.
