# UIObject

## Properties

| Property | Expected Value Type | Mode | Description |
| -------- | ------------------- | ---- | ----------- |
| Position | UDim2 | Read & Write | The position of the inherited object. |
| Size | UDim2 | Read & Write | The size of the inherited object. |
| Rotation | Number | Read & Write | The rotation of the inherited object.
| AnchorPoint | Vector2 | Read & Write | Sets the origin point of the inherited object, where both X and Y are between 0 and 1, respectively. |
| ClipsDescendants | Boolean | Read & Write | When set to true, any descendants outside of the aboslute size of the inherited object will not render completely or at all. |
| LayoutOrder | Number | Read & Write | The layout order of the inherited object. |
| SizeConstraint | Enum.SizeConstraint | Read & Write | The size constraint of the inherited object. |
| Visible | Boolean | Read & Write | The visibility of the inherited object. |
| Active | Boolean | Read & Write | When set to true, the inherited object will sense input events such as mouse clicks. Buttons are active by default, while most other UI objects aren't. |
| ZIndex | Number | Read & Write | The render order of the inherited object. The higher it is, the later the object will be rendered. |

## Methods

This class does not contain any methods.

## Events

This class does not contain any events.
