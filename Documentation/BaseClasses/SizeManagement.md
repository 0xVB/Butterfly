# SizeManagement
A BaseClass that manages how objects are sized.

## Properties

| Property | Expected Value Type | Mode | Description |
| -------- | ------------------- | ---- | ----------- |
| Size | Varying Type | Varying Accesibility | A flexible size property that could be a BaseNumber, a Vector2, or a UDim2. It could also be Read Only or Read & Write. It changes in accordance to the inherited object. |
| SizeType | `BEnum.SizeType` | Read Only | Determines how the `Size` property will deal with values, and whether or not it will accept certain value types. |
| SizeLocked | Boolean | Read Only | If set to true, the `Size` property becomes temporarily or permenantly Read Only. This could change in accordance to the inherited object. |
| Interval | number | Read-Only | A parameter used by the `BEnum.SizeType` operator. |
| Axis | string | Read-Only | A parameter used by the `BEnum.SizeType` operator. |

## Methods

| Method | Parameters | Returns | Description |
| ------ | ---------- | ------- | ----------- |
| Resize | N/A | N/A | Applies the `BEnum.SizeType` operator. |

## Events

This class does not contain any events.

## Enumeration
| SizeType | Expected Value Type | Description |
| -------- | ------------------- | ----------- |
| Raw | `UDim2` | Sets the size to the UDim2 value. |
| Vector | `Vector2` | Sets the size to the Vector2 values using only pixels. |
| Scalar | `Vector2` | Sets the size to the Vector2 values using only scalars. |
| SinglePixel | `BaseNumber` | Sets the pixel size to the BaseNumber using the `Interval` attribute. The axis is determined by the `Axis` attribute. |