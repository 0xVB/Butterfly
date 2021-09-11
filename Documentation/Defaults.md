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

In the defaults library, there is one attribute that is not a default or a default library, that is `ImprintingEnabled`. It is a boolean property that, by default, is set to `false`. It can be used to easily make themes and change them without having to re-create the UI. Despite their great use, they could also be confusing and cause unwanted changes to those who do not want to use it or create themes, hence why it is set to `false` by default.

When `ImprintingEnabled` is set to `true`, Butterfly will start using the defaults themselves to assign them to their respective attributes when new instances are created. This might seem incredibly complicated, but it is quite simple. An easy analogy to understand that, is through Roblox's `ValuePlaceholder` instances, which look like this: 
<img src="https://raw.githubusercontent.com/0xVB/Butterfly/main/Documentation/ImageAssets/ValuePHold.png" alt="ValuePlaceholder"></a></br>
