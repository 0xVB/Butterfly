# ButterflyDefaults Library

The Butterfly Defaults Library contains an array of default values that the main BUI Library uses to set colors and other values in ButterflyInstances upon creation. This is an understatement to what the Defaults Library really does, but, for a base-level of knowledge, this is all you need to know.

## Table Of Contents
- [All Defaults](#defvals)
- [ImprintingEnabled](#imprint)
- <b>CORE: </b> [Creating Your Own Defaults (Themes)](#themes)
- <b>CORE: </b> [Defaults' Meta Structure](#metastruct)



## All Defaults <a name = "defvals"></a>
* `Background` | Contains a list of defaults used when creating a [`Background`](/Documentation/CoreClasses/Background.md) for Butterfly Instances.

| Name | Type | Description |
| ---- | ---- | ----------- |
| Color | `Color3` | The default `Background.Color` value. |
| Transparency | `Number` | The default `Background.Transparency` value. |
| CornerType | `CornerType` | The default `Background.CornerType` value. A list of all the CornerTypes could be found [here](/Documentation/Enums.md#cornertype). |
| CornerSize | `Number` | The default `Background.CornerSize` value. |

* `Text` | Contains a list of defaults used when creating [`TextRender`](/Documentation/CoreClasses/TextRender.md) or other text objects for Butterfly Instances.

| Name | Type | Description |
| ---- | ---- | ----------- |
| Color | `Color3` | The default `TextRender.TextColor` value. |
| Transparency | `Number` | The default `TextRender.TextTransparency` value. |
| StrokeColor | `Color3` | The default `TextRender.TextStrokeColor` value. |
| StrokeTransparency | `Number` | The default `TextRender.TextStrokeTransparency` value. |

* `TextBox` | Contains a list of defaults used when creating [`TextBoxRender`](/Documentation/CoreClasses/TextBoxRender.md) for Butterfly Instances.

| Name | Type | Description |
| ---- | ---- | ----------- |
| BackColor | `Color3` | The default `TextBoxRender.Background.Color` value. |
| TextColor | `Color3` | The default `TextBoxRender.TextColor` value. |
| StrokeColor | `Color3` | The default `TextBoxRender.TextStrokeColor` value.|
| PlaceholderColor | `Color3` | The default `TextBoxRender.Placeholder.TextColor` value. |
| PlaceholderStrokeColor | `Color3` | The default `TextBoxRender.Placeholder.TextStrokeColor` value. |
| BackTransparency  | `Number` | The default `TextBoxRender.Background.Transparency` value. |
| TextTransparency | `Number` | The default `TextBoxRender.TextTransparency` value. |
| StrokeTransparency | `Number` | The default `TextBoxRender.TextStrokeTransparency` value.|
| PlaceholderTransparency | `Number` | The default `TextBoxRender.Placeholder.TextTransparency` value. |
| PlaceholderStrokeTransparency | `Number` | The default `TextBoxRender.Placeholder.TextStrokeTransparency` value. |

* `General` | Contains a list of defaults used for general use.

| Name | Type | Description |
| ---- | ---- | ----------- |
| PrimaryColor | `Color3` | The dominant color. [Labels](/Documentation/StandardClasses/Label.md), [Buttons](/Documentation/StandardClasses/Button.md), uncheked [CheckBoxes](/Documentation/StandardClasses/Button.md), and so on will take on this color. |
| SecondaryColor | `Color3` | The color that will be used for secondary backgrounds. [ScrollBars](/Documentation/StandardClasses/ScrollBar.md) and [Windows](/Documentation/StandardClasses/Window.md) will use this property. |
| IndentColor | `Color3` | This color will be used for indented elements. Things like [DropDownBoxes](/Documentation/StandardClasses/DropDownBoxe.md) will use this color. |
| InactiveColor | `Color3` | This color will be used for **text** when interactive (aka input-recieving) elements have the `Enabled` attribute set to `false`. |
| InactiveBackColor | `Color3` | This color will be used for **backgrounds** when interactive elements have the `Enabled` attribute set to `false`. |
| HighlightColor | `Color3` | This color will be used for highlights such as a [Button's](/Documentation/StandardClasses/Button.md) `RippleColor` atrribute. |
| HighlightBackColor | `Color3` | This color will be used for selectable elements such as the items in a  [DropDownBoxe](/Documentation/StandardClasses/DropDownBoxe.md). |

## ImprintingEnabled <a name = "imprint"></a>

In the defaults library, there is one attribute that is not a default or a default library, which is `ImprintingEnabled`. It is a boolean property that, by default, is set to `false`. It can be used to easily make themes and change them without having to re-create the UI. Despite their great use, they could also be confusing and cause unwanted changes to those who do not want to use it or create themes, hence why it is set to `false` by default.

When `ImprintingEnabled` is set to `true`, Butterfly will start using the defaults themselves to assign them to their respective attributes when new instances are created. This might seem incredibly complicated, but it is quite simple. An easy analogy to understand that, is through Roblox's `ValuePlaceholder` instances, which look like this: 

<img src="https://raw.githubusercontent.com/0xVB/Butterfly/main/Documentation/ImageAssets/ValuePHold.png" alt="ValuePlaceholder"></a></br>
As you can see, the instance is simply a shell. It hold a number value, and has no other purpose. It just has a `Value` property that could be set. Now, imagine if you have multiple scripts in your workspace and you want them all to share one number value. When the value is changed, it is changed for all the scripts. This is the exact use for value placeholders in Roblox.

Defaults function very similarly. You can think of the default itself as the value placeholder that simply holds a value. When `ImprintingEnabeld` is `true`, Butterfly will set the attributes to the default **itself**. When it is `false`, Butterfly will set the attributes to the **value** of the default, not the default itself.

In other words, in a normal case scenario, if you create a Butterfly instance called "X", and then change the defaults, and make another one called "Y", if `ImprintingEnabled` is `false`, X will have the old defaults and Y will have the new defaults. If `ImprintingEnabled` is true, both X **and** Y will have the new defaults.

If you wish to stop imprinting on one instance without having to go through its every attribute, you can do that by using the `DisableImprinting` method, which will set all the attributes to their default values. If you wish to turn it on for one instance, you can use the `EnableImprinting` method, which will set all of the attributes to the defaults.
`DisableImprinting` and `EnableImprinting` both work regardless of what `ImprintingEnabled` is set to.

## Creating Your Own Defaults <a name = "themes"></a>

Now that you know how imprinting works, you might want to make your own defaults. Doing so will make you have more control over your themes, and you will have to set them only once. This is helpful because you do not have to recreate the UI in order for the theme changes to apply. In order to create a default, you use the function `ButterflySpace.Core.Constructors.Defaults`. The function takes 4 parameters:
1. `String` Name
2. `Default (NULLABLE)` Parent
3. `Any` Value
4. `String` TypeLock

In case you are creating a new default library, the parent could be `nil`, in which case it will be subsituted with `ButterflySpace.Defaults`. You also cannot provide a Value or a TypeLock if it is a library. If any were provided, they will be ignored. The name is what determines how the default will be reached. For instance, if you provided `"Konrushi"` for the name, and the `nil` for the parent, you will be able to access the default through `ButterfySpace.ButterflyDefaults.Konrushi`. `Value` could be anything, however it has to be consistent with the `TypeLock`. The `TypeLock` will determine what values does this default accept. If you do not know how TypeLock strings are formed, you can use the [TypeLock](/Documentation/TypeLock.md) documentation.

After creating your defaults, you will have to set them to attributes. Keep in mind that the TypeLock has to be either the exact same, or stricter than that of the attribute you are trying to set the default to. Imagine an attribute that could be either a boolean or nil; if you set it to a default that could **only** be a boolean, that would work. However, if you set it to a default that could be either a number or nil, it will cause an error.

If you want to set the attributes automatically every time an instance is created, you can do that by using the following code:
```lua
ButterflySpace.ButterflyUI.Classes["SAMPLE_CLASS"]["SAMPLE_ATTRIBUTE"]:SetDefault(SAMPLE_DEFAULT)
```
In this code, "SAMPLE_CLASS" is replaced with the class you want to change. Assume you wanted to change the default TextColor of a Button to the Konrushi default we made above. The code would be as follows:
```lua
ButterflySpace.ButterflyUI.Classes.Button.TextColor:SetDefault(ButterfySpace.ButterflyDefaults.Konrushi)
```

## Defaults' Meta Structure <a name = "metastruct"></a>

| Index | ValueType | Value | Description |
| - | - | - | - |
| "\0" | `String` | Name | - |
| "\1" | `Default (NULLABLE)` | Parent | The default library that contains this default. It is nil when the default in question is `ButterflySpace.ButterflyDefaults`. |
| "\2" | `Any (NULLABLE)` | Value | The value of the default. |
| "\3" | `String` | TypeLock | The TypeLock string. |
| "\4" | `Table` | Children/SubDefaults | A table containing all the children or sub-defaults in this default. |
