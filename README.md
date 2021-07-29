# Butterfly
<p align="center">
  <img src="https://raw.githubusercontent.com/0xVB/Butterfly/main/ButterflyUI.png" alt="Butterfly UI"></a>
  An <b>Advanced</b> Roblox User Interface Library
</p>

Butterfly UI, formerly known as **Veranium**, is an advanced, yet simple UIL for Roblox made by V B. It functions very similarly to the native Roblox UI elements, unlike most other UILs. This makes it very easy to pick up, however, it is a large library, and, while it is easy to pick up, it is exceptionally difficult to master.

You can view [UI Design Samples](/Samples) that use Butterfly UI. Looking at examples is the fastest way to get the hang of how it works.
If looking at examples isn't your thing, keep reading for the Butterfly UI Documentation.

## Table Of Contents
- [Loadstring](#loadstring)
- [Different Butterfly Libraries](#libraries)
- [Creating Objects](#create_obj)
- [All Butterfly UI Classes](#bui_classes)

## Loadstring <a name = "loadstring"></a>
In order to get started, we have to load Butterfly UI into our script. This could be done by using a loadstring for exploits or by using the code in the [Source](/Source/ButterflyUI.lua), putting it into a ModuleScript, and then requiring that ModuleScript. It is **NOT** recommended to require the module more than once; Butterfly UI is a heavy library, and loading it more than once is not optimal. Try managing all the UI from one central client-sided script.
```lua
local ButterflySpace = loadstring(game:HttpGet("https://raw.githubusercontent.com/0xVB/Butterfly/main/Source/ButterflyUI.lua"))();
```
The local variable `ButterflySpace` is going to be used accross the documentation to refer to the loaded library. Name it as you please, but keep that in mind.

## Different Butterfly Libraries <a name = "loadstring"></a>
Butterfly consists of multiple libraries that work together in a network of interactions. It is critical to know what these libraries are and what they do.
**Keep in mind: You most won't be using any libraries marked as core libraries. They are *NOT* documented, so the only way to use them is to read the source code. Learning them would unlock certain features such as editing sub-components of UI elements, but it's not something an average user would realistically need.**
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
ButterflySpace.ButterflyUI.Create(string )
```
