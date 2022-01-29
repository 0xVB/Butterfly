# RedrawObject
A BaseClass inherited by ButterflyInstances that either redraw per heartbeat or have hybrid redrawing schedules.

## Properties

| Property | Expected Value Type | Mode | Description |
| -------- | ------------------- | ---- | ----------- |
| AutoRedraw | Boolean | Read & Write | When set to true, the inherited object will redraw on every new frame (Heartbeat). When set to false, redrawing should be handled manually using the `Redraw` method. |

## Methods

| Method | Parameters | Description |
| ------ | ---------- | ----------- |
| Redraw | Varying Parameters | Redraws the inherited object. |

## Events

This class does not contain any events.
