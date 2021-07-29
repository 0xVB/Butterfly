# Butterfly
<p align="center">
  # Butterfly UI
  An **Advanced** Roblox User Interface Library
</p>

Butterfly UI, formerly known as **Veranium**, is an advanced, yet simple UIL for Roblox. It functions very similarly to the native Roblox UI elements, unlike most other UILs. This makes it very easy to pick up, however, it is a large library, and, while it is easy to pick up, it is exceptionally difficult to master.

You can view [UI Design Samples](/Samples) that use Butterfly UI. Looking at examples is the fastest way to get the hang of how it works.
If looking at examples isn't your thing, keep reading for the Butterfly UI Documentation.

## Table Of Contents
- [Loadstring](#loadstring)
- [Creating Objects](#create_obj)
- [All Butterfly UI Classes](#bui_classes)

## Loadstring <a name = "loadstring"></a>
In order to get started, we have to load Butterfly UI into our script. This could be done by using a loadstring for exploits or by using the code in the [Source](/Source/ButterflyUI.lua), putting it into a ModuleScript, and then requiring that ModuleScript. It is **NOT** recommended to require the module more than once; Butterfly UI is a heavy library, and loading it more than once is not optimal. Try managing all the UI from one central client-sided script.
```lua
loadstring(game:HttpGet(""))();```
