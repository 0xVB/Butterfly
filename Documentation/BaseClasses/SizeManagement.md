# SizeManagement

## Properties

| Property | Expected Value Type | Mode | Description |
| -------- | ------------------- | ---- | ----------- |
| Size | Varying Type | Varying Accesibility | A flexible size property that could be a BaseNumber, a Vector2, or a UDim2. It could also be Read Only or Read & Write. It changes in accordance to the inherited object. |
| SizeType | [SizeType](/Documentation/Enums.md#SizeType) | Read Only | Determines how the `Size` property will deal with values, and whether or not it will accept certain value types. Read the [SizeType](/Documentation/Enums.md#SizeType) Enum documentation for more details. |
| SizeLocked | Boolean | Read Only | If set to true, the `Size` property becomes temporarily or permenantly Read Only. This could change in accordance to the inherited object. |
| SizeScaling | Varying Type | Varying Accesibility | Another parameter to the [SizeType](/Documentation/Enums.md#SizeType) operator. |

## Methods

This class does not contain any methods.

## Events

This class does not contain any events.
