# ButterflyDefaults Library

The Butterfly Defaults Library contains an array of default values that the main BUI Library uses to set colors and other values in ButterflyInstances upon creation. This is an understatement to what the Defaults Library really does, but, for a base-level of knowledge, this is all you need to know.

## Table Of Contents
- [All Defaults](#defvals)
- [ImprintingEnabled](#imprint)
- <b>CORE: </b> [Defaults Meta Structure](#metastruct)
- <b>CORE: </b> [Creating Your Own Defaults (Themes)](#themes)


## All Defaults <a name = "defvals"></a>
* `Background` | Contains a list of defaults used when creating a [`Background`](/Documentation/CoreClasses/Background.md) for Butterfly Instances.
| Name | Type | Description |
| ---- | ---- | ----------- |
| Color | `Color3` | The default `Background.Color` value. |
| Transparency | `Number` | The default `Background.Transparency` value. |
| CornerType | `CornerType` | The default `Background.CornerType` value. A list of all the CornerTypes could be found [here](/Documentation/Enums.md#cornertype). |
| CornerSize | `Number` | The default `Background.CornerSize` value. |

* `Text` | Contains a list of defaults used when creating 
