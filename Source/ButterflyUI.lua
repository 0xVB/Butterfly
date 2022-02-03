---@diagnostic disable: undefined-global
--[[ Butterfly UI Made by V B#5841 ]]--
--Konrushi!
--Version 2.0

--#region Declarations
--#region Services
local Players = game:GetService("Players");
local Debris = game:GetService("Debris");
local TweenService = game:GetService("TweenService");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local CoreGui = game:GetService("CoreGui");
--#endregion Services
local PlayerGui = Players.LocalPlayer.PlayerGui;
local CoreButterflySpace = {Constructors = {}, Meta = {}, MetaRef = {}, Functions = {}};
local ButterflySpace = {};
local MainUI = Instance.new("ScreenGui", PlayerGui);
MainUI.Name = "ButterflyUIMain";

--#region Math Library
ButterflySpace.Math = {};

local function Map(Number, Start1, Stop1, Start2, Stop2)
    return ((Number - Start1) / (Stop1 - Start1)) * (Stop2 - Start2) + Start2;
end;
ButterflySpace.Math.Map = Map;

local function GetMajorAxis(Main)
    if (Main.AbsoluteSize.X >= Main.AbsoluteSize.Y) then
        return "X";
    end;
    return "Y";
end;
ButterflySpace.Math.GetMajorAxis = GetMajorAxis;

local function Round(Number)
    local FDiff = Number - math.floor(Number);
    local CDiff = math.ceil(Number) - Number;
    return ((FDiff > CDiff) and math.ceil(Number)) or math.floor(Number);
end;
ButterflySpace.Math.Round = Round;

local function MapColor(Frame, StartFrame, EndFrame, StartColor, EndColor)
    return Color3.new(
        Map(Frame, StartFrame, EndFrame, StartColor.r, EndColor.r),
        Map(Frame, StartFrame, EndFrame, StartColor.g, EndColor.g),
        Map(Frame, StartFrame, EndFrame, StartColor.b, EndColor.b)
    );
end;
ButterflySpace.Math.MapColor = MapColor;

local function MapUDim2(Frame, StartFrame, EndFrame, StartUDim2, EndUDim2)
    return UDim2.new(
        Map(Frame, StartFrame, EndFrame, StartUDim2.X.Scale, EndUDim2.X.Scale),
        Map(Frame, StartFrame, EndFrame, StartUDim2.X.Offset, EndUDim2.X.Offset),
        Map(Frame, StartFrame, EndFrame, StartUDim2.Y.Scale, EndUDim2.Y.Scale),
        Map(Frame, StartFrame, EndFrame, StartUDim2.Y.Offset, EndUDim2.Y.Offset)
    );
end;
ButterflySpace.Math.MapUDim2 = MapUDim2;

local function ParseNumber(Value, Interval)
    if (type(Interval) ~= "number") then error("Expected number for argument #1."); end;
    if (typeof(Value) == "number") then
        return Value;
    elseif (typeof(Value) == "NumberRange") then
        local Min, Max = Value.Min, Value.Max;
        return Map(Interval, 0, 1, Min, Max);
    elseif (typeof(Value) == "NumberSequence") then
        local MinTime, MaxTime, MinNumber, MaxNumber;
        for i = 1, #Value.Keypoints do
            local v = Value.Keypoints[i];
            local Number, Time = v.Value, v.Time;
            if (Time > Interval) then
                MaxNumber = Number;
                MaxTime = Time;
                break;
            elseif (Time < Interval) then
                MinNumber = Number;
                MinTime = Time;
            elseif (Time == Interval) then
                return Number;
            end;
        end;
        local RelativeInterval = Map(Interval, MinTime, MaxTime, 0, 1);
        return Map(RelativeInterval, 0, 1, MinNumber, MaxNumber);
    end;
    error("Expected BaseNumber for argument #2.");
end;
ButterflySpace.Math.ParseNumber = ParseNumber;

local function ParseColor(Value, Interval)
    if (type(Interval) ~= "number") then error("Expected number for argument #1."); end;
    if (typeof(Value) == "Color3") then
        return Value;
    elseif (typeof(Value) == "ColorSequence") then
        local MinTime, MaxTime, MinColor, MaxColor;
        for i = 1, #Value.Keypoints do
            local v = Value.Keypoints[i];
            local Number, Time = v.Value, v.Time;
            if (Time > Interval) then
                MaxColor = Number;
                MaxTime = Time;
                break;
            elseif (Time < Interval) then
                MinColor = Number;
                MinTime = Time;
            elseif (Time == Interval) then
                return Number;
            end;
        end;
        local RelativeInterval = Map(Interval, MinTime, MaxTime, 0, 1);
        return Color3.new(
            Map(RelativeInterval, 0, 1, MinColor.R, MaxColor.R),
            Map(RelativeInterval, 0, 1, MinColor.G, MaxColor.G),
            Map(RelativeInterval, 0, 1, MinColor.B, MaxColor.B)
        );
    end;
end;
ButterflySpace.Math.ParseColor = ParseColor;

local function TotalTweenTime(Info)
    return Info.Time + Info.DelayTime;
end;
ButterflySpace.Math.TotalTweenTime = TotalTweenTime;
--#endregion Math Library

--#region TypeLock System
ButterflySpace.TypeLibrary = {};
ButterflySpace.TypeLibrary.TypeDictionary = {
    [2] = {
        ["number"] = true;
        ["NumberRange"] = true;
        ["NumberSequence"] = true;
    };
    [3] = {
        ["Color3"] = true;
        ["ColorSequence"] = true;
    };
};
ButterflySpace.TypeLibrary.Operators = {
    [0] = function (self)
        return (self ~= nil);
    end;
    [1] = function (self)
        if (self) then return true; end; return false;
    end;
    [2] = function (self)
        return (ButterflySpace.TypeLibrary.TypeDictionary[2][typeof(self)]) or false;
    end;
    [3] = function (self)
        return (ButterflySpace.TypeLibrary.TypeDictionary[3][typeof(self)]) or false;
    end;
    [4] = function (self, Parameter)
        return (ButterflySpace.EnumLibrary.IsA(self, Parameter)) or false;
    end;
    [5] = function (self)
        return (typeof(self) == "Instance" or ButterflySpace.Butterfly.IsA(self, "ButterflyInstance"));
    end;
    [6] = function (self, Parameter)
        return (type(self) == Parameter);
    end;
    [7] = function (self, Parameter)
        return (typeof(self) == Parameter);
    end;
}

function ButterflySpace.TypeLibrary.IsA(self, TypeString)
    local Nullable = TypeString:byte() == 1;
    local Operator = TypeString:byte(2);
    local Parameter = TypeString:sub(3);
    if (self == nil and Nullable) then return true; end;
    Operator = ButterflySpace.TypeLibrary.Operators[Operator];
    if (not Operator) then error("Invalid TypeString Operator."); end;
    return Operator(self, Parameter);
end;

function ButterflySpace.TypeLibrary.__EQ(Max, Min)
    if (type(Max) ~= "string" or type(Min) ~= "string") then error("Max and Min must be TypeStrings."); end;
    if (Max:byte() < Min:byte()) then return false; end;
    local OP0, OP1 = Max:byte(2), Min:byte(2);
    local Param0, Param1 = Max:sub(3), Min:sub(3);

    if (OP0 == 0 or (OP0 == OP1 and Param0 == Param1)) then return true; end;
    if (OP0 == 1 and OP1 >= 2) then return true; end;

    if (OP0 == 2 and (((OP1 == 6 or OP01 == 7) and Param1 == "number") or (OP1 == 7 and (Param1 == "NumberSequence" or Param1 == "NumberRange")))) then return true; end;

    if (OP0 == 4 and ((OP1 == 6 or OP1 == 7) and Param1 == "userdata")) then return true; end;

    if (OP0 == 5 and ((OP1 == 6 or OP1 == 7) and (Param1 == "userdata" or Param1 == "Instance"))) then  return true; end;

    return false;
end;
--#endregion TypeLock System