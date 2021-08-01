## BaseInstance

# Properties

| Property | Expected Value Type | Mode | Description |
| -------- | ------------------- | ---- | ----------- |
| Parent | BaseInstance | Read & Write | Sets or gets the parent for the inherited object. It could be provided with a Roblox instance or a Butterfly UI instance. |
| Class | ButterflyClass | Read Only | A property that contains the direct class the inherited object belongs to. This refers to the actual class, not a string that resembles its name. |
| ClassName | String | Read Only | Contains the name of the class the inherited object belongs to. |
| Name | String | Read & Write | Contains the name of the inherited object. |
| ParentLocked | Read Only **(CORE)** | If set to true, the `Parent` property becomes Read Only. This is a core property that can only be modified by Butterfly UI internally. |

# Methods

| Method | Parameters | Description |
| ------ | ---------- | ----------- |
| Destroy | N/A | Removes all internal references to the inherited object and destroys the Roblox elements that display it. Make sure to clear the variable that references the object after usage to ensure garbage collection. |

# Events

| Event | Parameters | Description |
| ----- | ---------- | ----------- |
| AttributeSet | `String` Attribute | Fired when a property in the inherited object changes. The Attribute parameter is the name of the property that changed. |
