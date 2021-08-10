# Butterfly
<p align="center">
  <img src="https://raw.githubusercontent.com/0xVB/Butterfly/main/ButterflyUILbl.png" alt="Butterfly UI"></a></br>
  An <b>Advanced</b> Roblox User Interface Library
</p>

Butterfly UI, formerly known as **Veranium**, is an advanced, yet simple UIL for Roblox made by V B. It functions very similarly to the native Roblox UI elements, unlike most other UILs. This makes it very easy to pick up, however, it is a large library, and, while it is easy to pick up, it is exceptionally difficult to master.

You can view [UI Design Samples](/Samples) that use Butterfly UI. Looking at examples is the fastest way to get the hang of how it works.
If looking at examples isn't your thing, keep reading for the Butterfly UI Documentation.

## Table Of Contents
- [Loadstring](#loadstring)
- [Different Butterfly Libraries](#libraries)
- [Creating Objects](#create_obj)
- [Types You Need To Understand](#vtypes)
- [All Butterfly UI Classes](#bui_classes)
- [Butterfly Enumerators](/Documentation/Enums.md)
- [Butterfly Defaults](/Documentation/Defaults.md)
- [Butterfly Math Library](/Documentation/Math.md)

## Loadstring <a name = "loadstring"></a>
In order to get started, we have to load Butterfly UI into our script. This could be done by using a loadstring for exploits or by using the code in the [Source](/Source/ButterflyUI.lua), putting it into a ModuleScript, and then requiring that ModuleScript. It is **NOT** recommended to require the module more than once; Butterfly UI is a heavy library, and loading it more than once is not optimal. Try managing all the UI from one central client-sided script.
```lua
local ButterflySpace = loadstring(game:HttpGet("https://raw.githubusercontent.com/0xVB/Butterfly/main/Source/ButterflyUI.lua"))();
```
The local variable `ButterflySpace` is going to be used accross the documentation to refer to the loaded library. Name it as you please, but keep that in mind.

## Different Butterfly Libraries <a name = "loadstring"></a>
Butterfly consists of multiple libraries that work together in a network of interactions. It is critical to know what these libraries are and what they do.
**Keep in mind: You most likely won't be using any libraries marked as core libraries. They are *NOT* documented, so the only way to use them is to read the source code. Learning them would unlock certain features such as editing sub-components of UI elements, but it's not something an average user would realistically need.**
# Butterfly Libraries

| Library | Description |
| ----------- | ----------- |
| ButterflyUI | The main library and the one you will be using the most. It handles the creation of all UI elements |
| ButterflyEnum | A library that contains all the custom Enumerator values used by Butterfly. It stores special value types that can't be expressed using numbers, strings, etc. |
| ButterflyDefaults | Contains default values and colors. It defines what the colors and specifications the objects created by ButterflyUI will be on creation. It could be used to easily make themes and reduce the amount of changes each UI element requires. |
| ButterflyEvents **(CORE)** | A core library used internally by Butterfly to create custom events. For some reason, Roblox BindableEvents do not allow transferring custom proxies (userdata values) through the event parameters, which is why this library exists. |

## Creating Objects <a name = "create_obj"></a>
In order to create objects using the library, we simply use the `Create` function located directly in the UI sub-library.
```lua
local Object = ButterflySpace.ButterflyUI.Create([string] ClassName, ([BaseInstance] Parent));
```
This is the function we will be using the most. The `Parent` parameter is optional.

## Creating Objects <a name = "vtypes"></a>
If you're wondering what a "BaseInstance" as mentioned in the codeblock above is, it is a value type that will be used in Butterfly to refer to something new. Here is a list of all value types in Butterfly.
| Value Type | Description |
| ---------- | ----------- |
| BaseInstance | An inclusive value type that includes *both* native Roblox Instances *and* Butterfly Instances. In the previous codeblock, it basically means you can parent your objects to *either* a native Roblox Instance, or another Butterfly Instance. |
| BaseNumber | An inclusive value type that includes Numbers, NumberRanges, and NumberSequences. It could be used for properties like a CheckBox's Transparency, whereas the Transparency is the first value in the set, and as the CheckBox is Checked by the user, it tweens to the last value in the set. This also works with values in-between the first and last in NumberSequences. |
| BaseColor | An inclusive value type that includes Color3 and ColorSequence. Much like BaseNumber, it could be used in a similar way, but of course, referring to colors instead of numbers. (Ex: CheckBox's Color before and after checking.) |

Different Classes deal with different value types in a different manner, so make sure to know how a property deals with being set to a number, as opposed to a range or a sequence. It should be documented in the Class' document page.

## All Butterfly UI Classes <a name = "bui_classes"></a>
In order to make a user interface using Butterfly UI, you have to know the different classes separately. First, let's know what are the ClassTypes.
| Class Type | Description |
| - | - |
| BaseClass | A collection of Attributes (Methods and Properties) that does **NOT** have a constructor. It cannot be created, and can only be inherited by other classes. |
| CoreClass | A class that has a constructor, but cannot be created through the regular `Create` function. This is usually because these classes require more parameters than the standard classes, and are not used by the average user. They are used by standard classes as sub-components of them. |
| StandardClass | Classes that have a constructor, and can be created by the regular `Create` function. They are the classes that most users will need. |

Now that we know the ClassTypes, let's get into the documentation by class.

## Standard Classes
- [Frame](/Documentation/StandardClasses/Frame.md)
- [Label](/Documentation/StandardClasses/Label.md)
- [Button](/Documentation/StandardClasses/Button.md)
- [TextBox](/Documentation/StandardClasses/TextBox.md)
- [Slider](/Documentation/StandardClasses/Slider.md)
- [ScrollBar](/Documentation/StandardClasses/ScrollBar.md)
- [ScrollingFrame](/Documentation/StandardClasses/ScrollingFrame.md)
- [CheckBox](/Documentation/StandardClasses/CheckBox.md)
- [AnimatedCheckBox](/Documentation/StandardClasses/AnimatedCheckBox.md)
- [Counter](/Documentation/StandardClasses/Counter.md)
- [Expander](/Documentation/StandardClasses/Expander.md)
- [DropDownBox](/Documentation/StandardClasses/DropDownBox.md)
- [ListBox](/Documentation/StandardClasses/ListBox.md)
- [GifPlayer](/Documentation/GifPlayer/ListBox.md)

## Base Classes
- [BaseInstance](/Documentation/BaseClasses/BaseInstance.md)
- [Base2D](/Documentation/BaseClasses/Base2D.md)
- [UIObject](/Documentation/BaseClasses/UIObject.md)
- [RedrawObject](/Documentation/BaseClasses/RedrawObject.md)
- [BackgroundObject](/Documentation/BaseClasses/BackgroundObject.md)
- [InputAttributes](/Documentation/BaseClasses/InputAttributes.md)
- [SizeManagement](/Documentation/BaseClasses/SizeManagement.md)
- [AppearanceManagement](/Documentation/BaseClasses/AppearanceManagement.md)
- [IntervalAttribute](/Documentation/BaseClasses/IntervalAttribute.md)

## Core Classes
- [SliceFragment](/Documentation/CoreClasses/SliceFragment.md)
- [Background](/Documentation/CoreClasses/Background.md)
- [TextRender](/Documentation/CoreClasses/TextRender.md)
- [ImageRender](/Documentation/CoreClasses/ImageRender.md)
- [TextBoxRender](/Documentation/CoreClasses/TextBoxRender.md)
- [Bar](/Documentation/CoreClasses/Bar.md)

Click on a class to see its in-depth documentation. It is recommended to start with Standard Classes, then move on to Base and Core Classes **if needed**.
