--[[ Butterfly UI Made by @0xVB ]]--
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

pcall(function ()
    MainUI.Parent = CoreGui;
end);
--#endregion Declarations

--#region Error System
--[[Error System Expalnation:
    The error system is simply a bunch of functions that lead to common errors.
    Some take certain parameters, others don't.
    Regardless, the point of this system is to have consistency in errors.
    It also helps reduce the number of constants, although mostly irrelevant, is still present.
]]--
local Read_Only_NDX = function () error("This Proxy is Read-Only."); end;
local SELFCALL_Expected = function () error("Unable to get meta. Make sure you used ':' instead of '.' to call this function."); end;
local Destroyed_Object = function() error("This object has been destroyed."); end;
local Invalid_Type = function (Parameter, Expected)
    error("Invalid type for " .. Parameter .. ". (" .. Expected .. " Expected.)");
end;
--[[ TypeString Structure:
    The TypeString starts with a byte (either 0 or 1).
    1 -> The type is nullable .(Can be NULL.)
    0 -> Cannot be NULL. Must be of the provided type.
    
    The Nullable byte is then followed by the provided type, as a string from indices 2 to -1 (string extension.)
    ButterflyUI has "BaseColor" & "BaseNumber" types added.
    They are used to set certain attributes that are supposed to vary according to time or other factors.
    Read the documentation for a more detailed expalnation.

    Ex: ButterflySpace.ButterflyUI.Button.Properties.RippleColor -> Could be a Color3 or a ColorSequence.
    Color3 -> The Ripple is the provided Color3 at all times.
    ColorSequence -> The Ripple follows the ColorSequence from start to finish. This is useful for effortless blend effects.
    
    IMPORTANT: ButterflyMath is responsible for parsing Color/NumberSequence(s) values.
]]--
local TCTable = {
    BaseColor = {"Color3", "ColorSequence"},
    BaseNumber = {"number", "NumberRange", "NumberSequence"}
};
local function TypeCheck(Value, Type)
    if (not Type) then return true; end;
    local Nullable = (Type:byte() == 1);
    if (Nullable and (Value == nil)) then return true; end;
    Type = Type:sub(2, -1);
    if (Type == "PTInstance") then
        return (typeof(Value) == "Instance" and Value:IsA("GuiBase")) or ButterflySpace.ButterflyUI.IsA(Value, "ButterflyInstance");
    end;
    if (TCTable[Type]) then
        for _, TS in pairs(TCTable[Type]) do
            if (typeof(Value) == TS) then return true; end;
        end;
        return false;
    end;
    if (typeof(Value) == Type) then return true; end;
    if (ButterflySpace.ButterflyEnum.IsA(Value, Type)) then return true; end;
    if (ButterflySpace.ButterflyDefaults.IsA(Value, Type)) then return true; end;
    if (ButterflySpace.ButterflyEvents.IsA(Value, Type)) then return true; end;
    if (ButterflySpace.ButterflyUI.IsA(Value, Type)) then return true; end;
    return false;
end;

local function AssertTypeCheck(Value, Type, Attribute)
    if (not TypeCheck(Value, Type)) then
        Invalid_Type(Attribute or Type:sub(2, -1), Type:sub(2, -1));
    end;
end;
--#endregion Error System

--#region Butterfly Math Library
--[[ Butterfly Math Library Expalnation:
    A library that contains various math functions that do not exist in Vanilla Lua's math library.
    Check the documentation for a more detailed expalnation on each function.
    
    This is not an initiated (Proxy-handled) library.
    It simply declares local functions for later use.
]]--
local function Map(Number, Start1, Stop1, Start2, Stop2)
    return ((Number - Start1) / (Stop1 - Start1)) * (Stop2 - Start2) + Start2;
end;

local function GetLargeAxis(Main)
    if (Main.AbsoluteSize.X >= Main.AbsoluteSize.Y) then
        return "X";
    end;
    return "Y";
end;

local function Round(Number)
    local FDiff = Number - math.floor(Number);
    local CDiff = math.ceil(Number) - Number;
    return ((FDiff > CDiff) and math.ceil(Number)) or math.floor(Number);
end;

local function MapColor(StartColor, EndColor, StartFrame, EndFrame, Frame)
    return Color3.new(
        Map(Frame, StartFrame, EndFrame, StartColor.r, EndColor.r),
        Map(Frame, StartFrame, EndFrame, StartColor.g, EndColor.g),
        Map(Frame, StartFrame, EndFrame, StartColor.b, EndColor.b)
    );
end;

local function MapUDim2(Frame, StartFrame, EndFrame, StartUDim2, EndUDim2)
    return UDim2.new(
        Map(Frame, StartFrame, EndFrame, StartUDim2.X.Scale, EndUDim2.X.Scale),
        Map(Frame, StartFrame, EndFrame, StartUDim2.X.Offset, EndUDim2.X.Offset),
        Map(Frame, StartFrame, EndFrame, StartUDim2.Y.Scale, EndUDim2.Y.Scale),
        Map(Frame, StartFrame, EndFrame, StartUDim2.Y.Offset, EndUDim2.Y.Offset)
    );
end;

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

local function TotalTweenTime(Info)
    return Info.Time + Info.DelayTime;
end;

local function DirectionalMagnitude(V0, V1)
    local Magnitude = V1 - V0;
    local X1, Y1 = (Magnitude.X == 0 and 1) or 0, (Magnitude.Y == 0 and 1) or 0;
    return (X1 == 0 and 1) or 0, X1, (Y1 == 0 and 1) or 0, Y1;
end;
--#endregion Butterfly Math Library

--#region Enumerator System
--[[
    Handles special value types, "Enumerator".
    They are used to declare values such as BackgroundType & so on.
    Basically, values too complicated to be expressed as simple values, such as numbers & strings.
    They do not exist in the Vanilla RLua EnumItems.
    Users can create custom Butterfly Enumerators using the function, CoreLibrary.CreateEnum().
    Read the documentation for a more detailed expalnation.
]]--

local function Init_ButterflyEnum()
    if (ButterflySpace.ButterflyEnum) then return; end;--The library is already loaded.
    local MetaRef = {};--Keys: ButterflyEnum Proxies | Values: the metatable of said Proxy.
    --[[ ButterflyEnum Meta Structure:
        [0] -> Name
        [1] -> Parent (Could be nil.)
        [2] -> Value
        [3] -> ByteValue
        [4] -> Children/SubEnums
    ]]

    --#region Functions
    local GetPath;
    GetPath = function(self)
        local Meta = MetaRef[self];
        if (not Meta) then SELFCALL_Expected(); end;
        if (not Meta["\1"]) then return Meta["\0"]; end;
        return GetPath(Meta["\1"]) .. "." .. Meta["\0"];
    end;

    local function IsA(self, Type)
        if (type(self) ~= "userdata") then return false; end;
        local Meta = MetaRef[self];
        if (not Meta) then return false; end;
        local PType = Meta["\1"];
        if (PType and MetaRef[PType]) then PType = MetaRef[PType]["\0"]; else PType = Meta["\0"] end;
        if (not Meta) then SELFCALL_Expected(); end;
        return (Type == "EnumItem" or Type == "ButterflyEnum") or (Type == Meta["\0"] or Type == PType) or (Type == "ButterflyProxy");
    end;

    local function GetValue(self)
        local Meta = MetaRef[self];
        if (not Meta) then SELFCALL_Expected(); end;
        return Meta["\2"];
    end;

    local function ParseEnum(Value, ExpectedType)
        if (MetaRef[Value]) then return Value; end;
        local Meta = MetaRef[ExpectedType];
        return Meta["\4"][Value];
    end;
    --#endregion Functions

    --#region Meta
    local Meta_ButterflyEnum;
    Meta_ButterflyEnum = {
        KeyTranslation = {Name = "\0", Path = "\0", Parent = "\1", Container = "\1", Type = "\1", Value = "\3", ByteValue = "\3",
        GetPath = GetPath, GetValue = GetValue, IsA = IsA},
        __tostring = function (self)
            return GetPath(self);
        end,
        __index = function (self, Attribute)
            local Meta = MetaRef[self];
            local KeyTranslation = Meta_ButterflyEnum.KeyTranslation[Attribute]
            if (type(KeyTranslation) == "string") then
                return Meta[KeyTranslation];
            elseif (type(KeyTranslation) == "function") then
                return KeyTranslation;
            elseif (Meta["\4"][Attribute]) then
                return Meta["\4"][Attribute];
            end;
            error("Unable to find Attribute '" .. tostring(Attribute) .."'.");
        end,
        __newindex = Read_Only_NDX,
        __metatable = "Konrushi!"
    };
    --#endregion Meta

    --#region Construction
    local function Constructor_ButterflyEnum(Name, Parent, Value, ByteValue)
        local Proxy = newproxy(true);
        local Meta = getmetatable(Proxy);
        MetaRef[Proxy] = Meta;
        --#region Attributes
        Meta["\0"] = Name;
        Meta["\1"] = Parent;
        Meta["\2"] = Value;
        Meta["\3"] = ByteValue;
        Meta["\4"] = {};
        --#endregion Attributes
        --#region Meta Methods
        Meta.__tostring = Meta_ButterflyEnum.__tostring;
        Meta.__index = Meta_ButterflyEnum.__index;
        Meta.__newindex = Meta_ButterflyEnum.__newindex;
        Meta.__metatable = Meta_ButterflyEnum.__metatable;
        --#endregion Meta Methods
        if (Parent and MetaRef[Parent]) then
            Meta = MetaRef[Parent];
            if (Name) then Meta["\4"][Name] = Proxy; end;
            if (ByteValue) then Meta["\4"][ByteValue] = Proxy; end;
        end;
        return Proxy;
    end;
    local ButterflyEnum = Constructor_ButterflyEnum("ButterflyEnum");
    --#endregion Construction

    CoreButterflySpace.MetaRef.ButterflyEnum = MetaRef;
    CoreButterflySpace.Meta.ButterflyEnum = Meta_ButterflyEnum;
    CoreButterflySpace.Functions.ParseEnum = ParseEnum;
    CoreButterflySpace.Constructors.Enum = Constructor_ButterflyEnum;
    ButterflySpace.ButterflyEnum = ButterflyEnum;
    return ButterflyEnum;
end;
--#endregion Enumerator System

--#region Default System
--[[ Default System Expalnation:
    A system used to store values for certain attributes.
    Essentially, it is used to define the default appearance of newly-created ButterflyUI Objects.
    It was also created with the intent of making different themes an easy job with ButterflyUI, &
    to reduce the number of modifications needed to customize an Object.
    Changing the settings in this library BEFORE creating ButterflyUI Objects could save a lot of time.
    Read the documentation for a more detailed expalnation.
]]--

local function Init_ButterflyDefaults()
    if (not ButterflySpace.ButterflyEnum) then error("ButterflyEnum is required to initiate ButterflyDefaults."); end;
    if (ButterflySpace.ButterflyDefaults) then return; end;--The library is already loaded.
    local MetaRef = {};--Keys: ButterflyDefault Proxies | Values: the metatable of said Proxy.
    --[[ ButterflyDefault Meta Structure:
        [0] -> Name
        [1] -> Parent (Could be nil.)
        [2] -> Value
        [3] -> TypeLock
        [4] -> Children/SubDefaults
    ]]

    --#region Functions
    local function IsA(self, Type)
        if (type(self) ~= "userdata") then return false; end;
        local Meta = MetaRef[self];
        if (not Meta) then return false; end;
        local PType = Meta["\1"];
        if (PType and MetaRef[PType]) then PType = MetaRef[PType]["\0"]; else PType = Meta["\0"] end;
        if (not Meta) then SELFCALL_Expected(); end;
        return (Type == "ButterflyDefault") or (Type == Meta["\0"] or Type == PType) or (Type == "ButterflyProxy");
    end;

    local function GetValue(self)
        local Meta = MetaRef[self];
        if (not Meta) then SELFCALL_Expected(); end;
        return Meta["\2"];
    end;
    --#endregion Functions

    --#region Meta
    local Meta_ButterflyDefaults;
    Meta_ButterflyDefaults = {
        KeyTranslation = {Name = "\0", Parent = "\1", Type = "\1", Value = "\2",
        GetValue = GetValue, IsA = IsA},
        __tostring = function (self)
            return MetaRef[self]["\0"];
        end,
        __index = function (self, Attribute)
            local Meta = MetaRef[self];
            local KeyTranslation = Meta_ButterflyDefaults.KeyTranslation[Attribute]
            if (type(KeyTranslation) == "string") then
                return Meta[KeyTranslation];
            elseif (type(KeyTranslation) == "function") then
                return KeyTranslation;
            elseif (Meta["\4"][Attribute]) then
                return Meta["\4"][Attribute];
            end;
            error("Unable to find Attribute '" .. tostring(Attribute) .."'.");
        end,
        __newindex = function (self, Attribute, Value)
            if (Attribute ~= "Value") then error("Only 'Value' Attribute can be modified in ButterflyDefaults."); end;
            local Meta = MetaRef[self];
            if (not Meta["\3"]) then error("Unable to change Value in a DefaultLibrary."); end;
            AssertTypeCheck(Value, Meta["\3"], "Value");
            Meta["\2"] = Value;
        end,
        __metatable = "Konrushi!"
    };
    --#endregion Meta

    --#region Construction
    local function Constructor_ButterflyDefault(Name, Parent, Value, TypeLock)
        local Proxy = newproxy(true);
        local Meta = getmetatable(Proxy);
        MetaRef[Proxy] = Meta;
        --#region Attributes
        Meta["\0"] = Name;
        Meta["\1"] = Parent;
        Meta["\2"] = Value;
        Meta["\3"] = TypeLock;
        Meta["\4"] = {};
        --#endregion Attributes
        --#region Meta Methods
        Meta.__tostring = Meta_ButterflyDefaults.__tostring;
        Meta.__index = Meta_ButterflyDefaults.__index;
        Meta.__newindex = Meta_ButterflyDefaults.__newindex;
        Meta.__metatable = Meta_ButterflyDefaults.__metatable;
        --#endregion Meta Methods
        if (Parent and MetaRef[Parent]) then
            Meta = MetaRef[Parent];
            if (Name) then Meta["\4"][Name] = Proxy; end;
        end;
        return Proxy;
    end;
    local ButterflyDefaults = Constructor_ButterflyDefault("ButterflyDefaults");
    --#endregion Construction
    
    CoreButterflySpace.MetaRef.ButterflyDefaults = MetaRef;
    CoreButterflySpace.Meta.ButterflyDefaults = Meta_ButterflyDefaults;
    CoreButterflySpace.Constructors.Defaults = Constructor_ButterflyDefault;
    ButterflySpace.ButterflyDefaults = ButterflyDefaults;

    return ButterflyDefaults;
end;
--#endregion Default System

--#region Butterfly Events
--[[ Butterfly Events Expalnation:
    The reason ButterflyUI has its own Event System is due to Vanilla RLua's
    Instance, "BindableEvent" lacking the ability to pass custom userdata
    when firing the event.
    This led to the creation of this library.
    It is a wrapped version of RLua's BindableEvent.
]]--
local function Init_ButterflyEvents()
    if (ButterflySpace.ButterflyEvents) then return; end;--The library is already loaded.
    local MetaRef = {};--Keys: ButterflyEvents Proxies | Values: the metatable of said Proxy.
    --[[ ButterflyEvents Meta Structure:
        [0] -> Name
        [1] -> Container (Could be nil.)
        [2] -> Instance (or Function)
        [3] -> Connections (Only in Events)
        [4] -> Parameters (Only in Events)
    ]]

    local function IsA(self, Type)
        if (type(self) ~= "userdata") then return false; end;
        local Meta = MetaRef[self];
        if (not Meta) then return false; end;
        return (Type == Meta["\0"]) or (Type == "ButterflyEvent" and not Meta["\0"] == "ButterflyConnection") or (Type == "ButterflyProxy");
    end;

    local function Destructor_ButterflyEvent(Proxy)
        if (not Proxy) then SELFCALL_Expected(); end;
        local Meta = MetaRef[Proxy];
        if (not Meta) then return; end;
        if (Meta["\0"] == "ButterflyConnection" and Meta["\1"]) then
            for _, Connection in pairs(MetaRef[Meta["\1"]]["\3"])do
                if (Connection == Proxy) then
                    table.remove(MetaRef[Meta["\1"]]["\3"], _);
                end;
            end;
        end;
        MetaRef[Proxy] = nil;
        Meta["\0"], Meta["\1"], Meta["\2"], Meta["\4"] = nil, nil, nil, nil;
        if (type(Meta["\3"]) ~= "table") then Meta["\3"] = nil; return; end;
        for _, Connection in pairs(Meta["\3"]) do
            Connection:Destroy();
            Meta["\3"][_] = nil;
        end;
    end;

    local function GetConnections(self)
        if (not self) then SELFCALL_Expected(); end;
        local Meta = MetaRef[self];
        if (not Meta) then error("DestroyedObject"); end;
        if (type(Meta["\3"]) ~= "table") then error("Unable to get Connections."); end;
        local Connections = {};
        for _, Connection in pairs(Meta["\3"])do
            Connections[_] = Connection;
        end;
        return Connections;
    end

    local function Fire(self, ...)
        if (not self) then SELFCALL_Expected(); end;
        local Meta = MetaRef[self];
        if (not Meta) then error("DestroyedObject"); end;
        if (type(Meta["\2"]) == "function") then
            return Meta["\2"](...);
        elseif (typeof(Meta["\2"]) == "Instance") then
            Meta["\4"] = {...};
            Meta["\2"]:Fire();
            for _, Connection in pairs(Meta["\3"])do
                Connection:Fire(...);
            end;
        end;
    end;

    local function Await(self)
        if (not self) then SELFCALL_Expected(); end;
        local Meta = MetaRef[self];
        if (not Meta) then error("DestroyedObject"); end;
        if (Meta["\0"] == "ButterflyConnection") then error("Unable to Await ButterflyConnection."); end;
        Meta["\2"].Event:Wait();
        return table.unpack(Meta["\4"]);
    end;

    local Meta_ButterflyEvents;
    Meta_ButterflyEvents = {
        KeyTranslation = {Name = "\0", Container = "\1", Function = "\1",
        IsA = IsA, Await = Await, Fire = Fire, Wait = Await, Disconnect = Destructor_ButterflyEvent, GetConnections = GetConnections, Destroy = Destructor_ButterflyEvent, Remove = Destructor_ButterflyEvent},
        __tostring = function (self)
            return (MetaRef[self]) and MetaRef[self]["\0"] or "<DestroyedObject>";
        end,
        __index = function (self, Attribute)
            local Meta = MetaRef[self];
            if (not Meta) then return; end;
            local KeyTranslation = Meta_ButterflyEvents.KeyTranslation[Attribute];
            if (type(KeyTranslation) == "string") then
                return Meta[KeyTranslation];
            elseif (type(KeyTranslation) == "function") then
                return KeyTranslation;
            end;
            error("Unable to find Attribute '" .. tostring(Attribute) .."'.");
        end,
        __newindex = Read_Only_NDX,
        __metatable = "Konrushi!"
    };

    local function Constructor_ButterflyEvent(Name, Parent)
        local Proxy = newproxy(true);
        local Meta = getmetatable(Proxy);
        local Event = Instance.new("BindableEvent");
        MetaRef[Proxy] = Meta;
        --#region Attributes
        Meta["\0"] = Name;
        Meta["\1"] = Parent;
        Meta["\2"] = Event;
        Meta["\3"] = {};
        --#endregion Attributes
        --#region Meta Methods
        Meta.__tostring = Meta_ButterflyEvents.__tostring;
        Meta.__index = Meta_ButterflyEvents.__index;
        Meta.__newindex = Meta_ButterflyEvents.__newindex;
        Meta.__metatable = Meta_ButterflyEvents.__metatable;
        --#endregion Meta Methods
        return Proxy;
    end;

    local function Constructor_ButterflyConnection(Event, Function)
        local Proxy = newproxy(true);
        local Meta = getmetatable(Proxy);
        MetaRef[Proxy] = Meta;
        --#region Attributes
        Meta["\0"] = "ButterflyConnection";
        Meta["\1"] = Event;
        Meta["\2"] = Function;
        --#endregion Attributes
        --#region Meta Methods
        Meta.__tostring = Meta_ButterflyEvents.__tostring;
        Meta.__index = Meta_ButterflyEvents.__index;
        Meta.__newindex = Meta_ButterflyEvents.__newindex;
        Meta.__metatable = Meta_ButterflyEvents.__metatable;
        --#endregion Meta Methods
        if (Event and MetaRef[Event]) then table.insert(MetaRef[Event]["\3"], Proxy); end;
        return Proxy;
    end;
    Meta_ButterflyEvents.KeyTranslation.Connect = Constructor_ButterflyConnection;

    CoreButterflySpace.MetaRef.ButterflyEvent = MetaRef;
    CoreButterflySpace.Meta.ButterflyEvent = Meta_ButterflyEvents;
    CoreButterflySpace.Constructors.Event = Constructor_ButterflyEvent;
    CoreButterflySpace.Constructors.Connection = Constructor_ButterflyConnection;
    ButterflySpace.ButterflyEvents = {
        IsA = IsA,
        GetConnections = GetConnections,
        Fire = Fire,
        Await = Await,
        Create = Constructor_ButterflyEvent
    };
    return ButterflySpace.ButterflyEvents;
end;
--#endregion Butterfly Events

--#region ButterflyUI
local function Init_ButterflyUI()
    if (not ButterflySpace.ButterflyEvents) then error("ButterflyEvents is required to initiate ButterflyUI."); end;
    if (not ButterflySpace.ButterflyEnum) then error("ButterflyEnum is required to initiate ButterflyUI."); end;
    if (not ButterflySpace.ButterflyDefaults) then error("ButterflyDefaults is required to initiate ButterflyUI."); end;
    if (ButterflySpace.ButterflyUI) then return; end;--The library is already loaded.
    local MetaRef = {};
    --[[ ButterflyUI Meta Structure:
    Class:
    {
        [0] -> Name
        [1] -> ClassType
        [2] -> Attributes.Properties
        [3] -> Attributes.Methods
        [4] -> Attributes.Events
        [5] -> Constructor

        [9] -> Type
        [10] -> Proxy
    }
    Instance: 
    {
        [0] -> Name
        [1] -> Class
        [2] -> Properties
        [3] -> Components (0: Main | 1: Parent)
        [4] -> Connections

        [9] -> Type
        [10] -> Proxy
    }
    Attribute:
    {
        [0] -> Name (PME)
        [1] -> AttributeType (PME)
        [2] -> Value (Property -> DefaultValue | Method -> Function | Event -> nil) (PM)
        [3] -> Get (P)
        [4] -> Set (Could be nil, which translates to this Attribute being Read-Only.) (P)
        [5] -> TypeLock (Could be nil, which disabled calling AssertTypeCheck before calling Set.) (P)

        [9] -> Type (PME)
        [10] -> Proxy (PME)
        
        PME -> Exists in Properties, Methods & Events.
        PM  -> Exists in Properties & Methods only.
        P   -> Exists in Properties only.
    }
    ]]
    --#region Enum Creation
    local PTClass, PTInstance, PTAttribute;
    local CTBase, CTCore, CTStandard;
    local ATProperty, ATMethod, ATEvent;
    --Wrapped inside a do end in order to save local variables from clumping up in autocomplete suggestions.
    do
        local Create = CoreButterflySpace.Constructors.Enum;
        local ButterflyEnum = ButterflySpace.ButterflyEnum;
        --#region Libraries
        local BackgroundType = Create("BackgroundType", ButterflyEnum);
        local ProxyType = Create("ProxyType", ButterflyEnum);
        local ClassType = Create("ClassType", ButterflyEnum);
        local AttributeType = Create("AttributeType", ButterflyEnum);
        local BarType = Create("BarType", ButterflyEnum);
        local SizeType = Create("SizeType", ButterflyEnum);
        --#endregion Libraries
        --#region BackgroundType
        Create("Sharp", BackgroundType, {3457842171, 400, 0}, 0);
        Create("Round", BackgroundType, {3457843087, 400, 0}, 1);
        Create("Tilted", BackgroundType, {3457843868, 400, 0}, 2);
        Create("Shadow", BackgroundType, {4793740839, 400, 0}, 3);
        --#endregion BackgroundType
        --#region BarType
        Create("Rectangle", BarType, {3457842171, Rect.new(400, 400, 400, 400)}, 0);
        Create("Capsule", BarType, {3457843087, Rect.new(400, 400, 400, 400)}, 1);
        Create("Tilted", BarType, {3457843868, Rect.new(400, 400, 400, 400)}, 2);
        Create("Shadow", BarType, {4793740839, Rect.new(400, 400, 400, 400)}, 3);
        --#endregion BarType
        --#region SizeType
        Create("UDim2", SizeType, function (Main, Value)
            AssertTypeCheck(Value, "\0UDim2", "Size");
            Main.Size = Value;
        end, 0);
        Create("Vector2", SizeType, function (Main, Value, SizeScaling)
            AssertTypeCheck(Value, "\0Vector2", "Size");
            Main.Size = UDim2.new(
                SizeScaling.X.Scale,
                SizeScaling.X.Offset * Value.X,
                SizeScaling.Y.Scale,
                SizeScaling.Y.Offset * Value.Y
            );
        end, 1);
        Create("Scale", SizeType, function (Main, Value, SizeScaling)
            AssertTypeCheck(Value, "\0number", "Size");
            Main.Size = UDim2.new(
                SizeScaling.X.Scale * Value,
                SizeScaling.X.Offset,
                SizeScaling.Y.Scale * Value,
                SizeScaling.Y.Offset
            );
        end, 2);
        Create("Offset", SizeType, function (Main, Value, SizeScaling)
            AssertTypeCheck(Value, "\0number", "Size");
            Main.Size = UDim2.new(
                SizeScaling.X.Scale,
                SizeScaling.X.Offset * Value,
                SizeScaling.Y.Scale,
                SizeScaling.Y.Offset * Value
            );
        end, 2);
        Create("BaseNumber", SizeType, function (Main, Value, SizeScaling, Interval)
            AssertTypeCheck(Value, "\0BaseNumber", "Size");
            Interval = Interval or 0;
            Interval = ParseNumber(Value, Interval)
            Main.Size = UDim2.new(
                SizeScaling.X.Scale,
                SizeScaling.X.Offset * Interval,
                SizeScaling.Y.Scale,
                SizeScaling.Y.Offset * Interval
            );
        end, 3);
        --#endregion SizeType
        --#region ProxyType
        PTClass = Create("Class", ProxyType, "ButterflyClass", 0);
        PTInstance = Create("Instance", ProxyType, "ButterflyInstance", 1);
        PTAttribute = Create("Attribute", ProxyType, "ButterflyAttribute", 2);
        --#endregion ProxyType
        --#region ProxyType
        CTBase = Create("Base", ClassType, "BaseClass", 0);
        CTCore = Create("Core", ClassType, "CoreClass", 1);
        CTStandard = Create("Standard", ClassType, "StandardClass", 2);
        --#endregion ProxyType
        --#region AttributeType
        ATProperty = Create("Property", AttributeType, "\2", 0);
        ATMethod = Create("Method", AttributeType, "\3", 1);
        ATEvent = Create("Event", AttributeType, "\4", 2);
        --#endregion AttributeType
    end;
    --#endregion Enum Creation
    --#region Default Creation
    local BackgroundDefaults, TextDefaults, TextBoxDefaults, GeneralDefaults;
    --Wrapped inside a do end in order to save local variables from clumping up in autocomplete suggestions.
    do
        local Create = CoreButterflySpace.Constructors.Defaults;
        local ButterflyDefaults = ButterflySpace.ButterflyDefaults;
        --#region Libraries
        local Background = Create("Background", ButterflyDefaults);
        local Text = Create("Text", ButterflyDefaults);
        local TextBox = Create("TextBox", ButterflyDefaults);
        local General = Create("General", ButterflyDefaults);
        BackgroundDefaults, TextDefaults, TextBoxDefaults, GeneralDefaults = Background, Text, TextBox, General;
        --#endregion Libraries
        --#region Background
        Create("Color", Background, Color3.fromRGB(19, 22, 22), "\0Color3");
        Create("Transparency", Background, 0, "\0number");
        Create("BackgroundType", Background, ButterflySpace.ButterflyEnum.BackgroundType.Round, "\0BackgroundType");
        Create("CornerSize", Background, 8, "\0number");
        --#endregion Background
        --#region Text
        Create("Color", Text, Color3.fromRGB(229, 249, 255), "\0Color3");
        Create("Transparency", Text, 0, "\0number");
        Create("StrokeColor", Text, Color3.new(), "\0Color3");
        Create("StrokeTransparency", Text, 1, "\0number");
        --#endregion Text
        --#region TextBox
        Create("BackColor", TextBox, Color3.fromRGB(38, 44, 43), "\0Color3");
        Create("TextColor", TextBox, Color3.fromRGB(229, 249, 255), "\0Color3");
        Create("TextTransparency", TextBox, 0, "\0number");
        Create("BackTransparency", TextBox, 0, "\0number");
        Create("StrokeColor", TextBox, Color3.new(), "\0Color3");
        Create("StrokeTransparency", TextBox, 1, "\0number");
        Create("PlaceholderColor", TextBox, Color3.fromRGB(76, 87, 87), "\0Color3");
        Create("Placeholder", TextBox, "Konrushi!", "\0string");
        --#endregion TextBox
        --#region General
        Create("PrimaryColor", General, Color3.fromRGB(154, 150, 166), "\0Color3");
        Create("SecondaryColor", General, Color3.fromRGB(28, 33, 33), "\0Color3");
        Create("IndentColor", General, Color3.fromRGB(47, 55, 54), "\0Color3");
        Create("InactiveColor", General, Color3.fromRGB(76, 87, 87), "\0Color3");
        Create("InactiveBackColor", General, Color3.fromRGB(19, 22, 22), "\0Color3");
        Create("HighlightColor", General, Color3.fromRGB(26, 158, 153), "\0Color3");
        Create("HighlightBackColor", General, Color3.fromRGB(23, 60, 59), "\0Color3");
        --#endregion General
    end;
    --#endregion Default Creation

    --#region Functions
    local GetEnumValue = ButterflySpace.ButterflyEnum.GetValue;
    local function IsA(self, Type)
        if (not self) then return false; end;
        if (not MetaRef[self]) then return false; end;
        return (MetaRef[self]["\9"]:GetValue() == Type) or (Type == "ButterflyProxy") or (Type == "ButterflyInstance");
    end;

    local function DefaultGet(Meta, Attribute)
        return Meta["\2"][Attribute];
    end;

    local function DefaultSet(Meta, Attribute, Value)
        Meta["\2"][Attribute] = Value;
    end;

    local function AttributeExists(Proxy, Attribute)
        if (not Proxy) then return; end;
        local Meta = MetaRef[Proxy];
        if (not Meta) then return; end;
        return (Meta["\2"][Attribute] ~= nil);
    end;
    --#endregion Functions
    
    --[[
    Get:
        Function -> Calls with (self, Attribute)
        string -> Components[string:sub(1, 1)][string:sub(2, -1)]
    Get
        nil -> Read-Only
        Function -> Calls with (self, Attribute, Value) | Asserts TypeCheck if TypeLock exists.
        string -> Components[string:sub(1, 1)][string:sub(2, -1)] = Value
    ]]--
    --#region Meta
    local Meta_ButterflyUI;
    Meta_ButterflyUI = {
        __tostring = function (self)
            return (MetaRef[self]) and MetaRef[self]["\0"] or "<DestroyedObject>";
        end,
        __index = function (self, Attribute)-- Methods >> Events >> Properties
            local Meta = MetaRef[self];
            if (not Meta) then return; end;
            local Class = MetaRef[Meta["\1"]];

            if (Class["\3"][Attribute]) then
                return MetaRef[Class["\3"][Attribute]]["\2"];
            elseif (Class["\4"][Attribute]) then
                return Meta["\2"][Attribute];
            elseif (Class["\2"][Attribute]) then
                Class = MetaRef[Class["\2"][Attribute]]["\3"];
                if (type(Class) == "function") then
                    return Class(Meta, Attribute);
                elseif (type(Class) == "string") then
                    return Meta["\3"][Class:sub(1, 1)][Class:sub(2, -1)];
                end;
            end;

            error("Unable to get Attribute " .. tostring(Attribute) .. ".");
        end,
        __newindex = function (self, Attribute, Value)
            local Meta = MetaRef[self];
            if (not Meta) then return; end;
            local Class = MetaRef[Meta["\1"]];

            if (Class["\2"][Attribute]) then
                Class = MetaRef[Class["\2"][Attribute]];
                local Set = Class["\4"];
                if (not Set) then error(tostring(Attribute) .. " is Read-Only."); end;
                local TypeLock = Class["\5"];
                if (TypeLock) then AssertTypeCheck(Value, TypeLock, tostring(Attribute)); end;
                
                if (type(Set) == "function") then
                    Set(Meta, Attribute, Value);
                    if (Meta["\2"].AttributeSet) then
                        Meta["\2"].AttributeSet:Fire(Attribute);
                    end;
                    return;
                elseif (type(Set) == "string") then
                    Meta["\3"][Set:sub(1, 1)][Set:sub(2, -1)] = Value;
                    return;
                end;
            end;

            error("Unable to set Attribute " .. tostring(Attribute) .. ".");
        end,
        __metatable = "Konrushi!"
    };
    --#endregion Meta

    --#region Constructors
    local function Constructor_ButterflyProxy(Name, Type, SetMeta)
        --#region Declarations
        local Proxy = newproxy(true);
        local Meta = getmetatable(Proxy);
        local Pointer = tostring(Proxy);
        MetaRef[Proxy] = Meta;
        Meta["\0"] = Name;
        Meta["\9"] = Type;
        Meta["\10"] = Proxy;
        --#endregion Declarations

        --#region Meta Methods
        Meta.__tostring = Meta_ButterflyUI.__tostring;
        if (not SetMeta) then return Proxy, Meta, Pointer; end;
        Meta.__index = Meta_ButterflyUI.__index;
        Meta.__newindex = Meta_ButterflyUI.__newindex;
        Meta.__metatable = Meta_ButterflyUI.__metatable;
        --#endregion Meta Methods

        return Proxy, Meta, Pointer;
    end;

    local Classes = {};
    local function Constructor_ButterflyClass(Name, ClassType, Constructor, ...)
        local Proxy, Meta, Pointer = Constructor_ButterflyProxy(Name, PTClass);
        local Inherits = {...};
        --#region Meta
        Meta["\1"] = ClassType;
        Meta["\2"] = {};
        Meta["\3"] = {};
        Meta["\4"] = {};
        Meta["\5"] = Constructor;
        Classes[Name] = Proxy;
        --#endregion Meta
        --#region Inheritance
        for _, Class in pairs(Inherits) do
            Class = MetaRef[Class];
            
            for _, Property in pairs(Class["\2"]) do
                Meta["\2"][_] = Property;
            end;

            for _, Method in pairs(Class["\3"]) do
                Meta["\3"][_] = Method;
            end;

            for _, Event in pairs(Class["\4"]) do
                Meta["\4"][_] = Event;
            end;
        end;
        --#endregion Inheritance
        return Proxy, Meta, Pointer;
    end;

    local function Construct_ButterflyAttribute(Name, Class, AttributeType, ...)
        local Proxy, Meta, Pointer = Constructor_ButterflyProxy(Name, PTAttribute);
        Class = MetaRef[Class];
        local AttributeParams = {...};
        --#region Meta
        if (AttributeType == ATMethod) then
            Meta["\2"] = AttributeParams[1];
            Class["\3"][Name] = Proxy;--Function
        elseif (AttributeType == ATProperty) then
            Meta["\2"] = AttributeParams[1];--Value
            Meta["\3"] = AttributeParams[2];--Get
            Meta["\4"] = AttributeParams[3];--Set
            Meta["\5"] = AttributeParams[4];--TypeLock
            Class["\2"][Name] = Proxy;
        end;
        Meta["\0"] = Name;
        Meta["\1"] = AttributeType;
        Class[GetEnumValue(AttributeType)][Name] = Proxy;
        --#endregion Meta
        return Proxy, Meta, Pointer;
    end;

    local function Constructor_ButterflyInstance(Class)
        Class = MetaRef[Class];
        local Proxy, Meta, Pointer = Constructor_ButterflyProxy(Class["\0"], PTInstance, true);
        --#region Meta
        Meta["\1"] = Class["\10"];
        Meta["\2"] = {};
        Meta["\3"] = {};
        Meta["\4"] = {};
        --#endregion Meta
        --#region Properties
        for _, Property in pairs(Class["\2"]) do
            Property = MetaRef[Property];
            if (ButterflySpace.ButterflyDefaults.IsA(Property["\2"], "ButterflyDefault")) then
                Meta["\2"][_] = Property["\2"].Value;
            else
                Meta["\2"][_] = Property["\2"];
            end;
        end;
        --#endregion Properties
        --#region Events
        for _, Event in pairs(Class["\4"]) do
            Event = MetaRef[Event];
            Meta["\2"][_] = CoreButterflySpace.Constructors.Event(Event["\0"], Proxy);
        end;
        --#endregion Events
        return Proxy, Meta, Pointer;
    end;

    local function RemoveAttribute(Class, Name, AttributeType)
        MetaRef[Class][GetEnumValue(AttributeType)][Name] = nil;
    end;

    local function ConstructClass(Class, ...)
        Class = MetaRef[Class];
        if (Class["\1"] == CTBase) then error(Class["\0"] .. " is a BaseClass (Used for inheritance, has no Constructors.)"); end;
        if (type(Class["\5"]) ~= "function") then error("This class is corrupted or incorrectly created."); end;
        return Class["\5"](...);
    end;

    local function CreateInstance(Class, ...)
        Class = Classes[Class];
        if (not Class) then error("Invalid class."); end;
        Class = MetaRef[Class];
        if (not Class) then error("Unable to create class."); end;
        if (Class["\1"] == CTCore) then error("This class is a CoreClass (Can only be created internally through ConstructClass.)"); end;
        return ConstructClass(Class["\10"], ...);
    end;

    local function Deconstructor_ButterflyUI(Proxy)
        local Meta = MetaRef[Proxy];
        if (not Meta) then return false; end;
        --#region Meta Methods
        Meta.__index = Destroyed_Object;
        Meta.__newindex = Destroyed_Object;
        --#endregion Meta Methods
        --#region Meta
        local Class = MetaRef[Meta["\1"]];
        Meta["\0"] = nil;
        Meta["\1"] = nil;
        Meta["\9"] = nil;
        Meta["\10"] = nil;
        for _, Component in pairs(Meta["\3"]) do pcall(function ()
            Component:Destroy();
            Meta["\3"][_] = nil;
        end) end;
        Meta["\3"] = nil
        for _, Connection in pairs(Meta["\4"]) do pcall(function ()
            Connection:Disconnect();
            Meta["\4"][_] = nil;
        end) end;
        Meta["\4"] = nil;
        for _, Event in pairs(Class["\4"]) do pcall(function ()
            Event = MetaRef[Event]["\0"];
            Event = Meta["\2"][Event];
            if (Event) then Event:Destroy(); end;
            Meta["\2"][Event] = nil;
        end) end;
        Meta["\2"] = nil;
        MetaRef[Proxy] = nil;
        --#endregion Meta

        return true;
    end;
    --#endregion Constructors

    --#region Classes
    local Temp;
    --#region BaseClass
    --#region BaseInstance
    local BaseInstance = Constructor_ButterflyClass("BaseInstance", CTBase);
    local function LockParent(Proxy)
        MetaRef[Proxy]["\2"].ParentLocked = true;
    end;
    Construct_ButterflyAttribute("Parent", BaseInstance, ATProperty, nil, DefaultGet, function (Meta, _, Value)
        if (Meta["\2"].ParentLocked) then error("The Parent is locked."); end;
        Meta["\2"].Parent = Value;
        if (Value == nil) then
            Meta["\3"]["\0"].Parent = nil;
            return;
        end;
        Meta["\3"]["\0"].Parent = (MetaRef[Value] and MetaRef[Value]["\3"]["\1"]) or Value;
    end, "\1PTInstance");
    Construct_ButterflyAttribute("Class", BaseInstance, ATProperty, nil, function (Meta)
        return Meta["\1"];
    end);
    Construct_ButterflyAttribute("ClassName", BaseInstance, ATProperty, nil, function (Meta)
        return MetaRef[Meta["\1"]]["\0"];
    end);
    Construct_ButterflyAttribute("Name", BaseInstance, ATProperty, nil, function (Meta)
        return Meta["\0"];
    end, function (Meta, _, Value)
        Meta["\0"] = Value;
    end, "\0string");
    Construct_ButterflyAttribute("ParentLocked", BaseInstance, ATProperty, false, DefaultGet);
    Construct_ButterflyAttribute("Destroy", BaseInstance, ATMethod, Deconstructor_ButterflyUI);
    Construct_ButterflyAttribute("Destroy", BaseInstance, ATMethod, AttributeExists);
    Construct_ButterflyAttribute("AttributeSet", BaseInstance, ATEvent);
    --#endregion BaseInstance
    --#region Base2D
    local Base2D = Constructor_ButterflyClass("Base2D", CTBase);
    Construct_ButterflyAttribute("AbsolutePosition", Base2D, ATProperty, nil, "\0AbsolutePosition");
    Construct_ButterflyAttribute("AbsoluteSize", Base2D, ATProperty, nil, "\0AbsoluteSize");
    Construct_ButterflyAttribute("AbsoluteRotation", Base2D, ATProperty, nil, "\0AbsoluteRotation");
    Construct_ButterflyAttribute("AbsoluteVisibility", Base2D, ATProperty, false, DefaultGet);
    --#endregion Base2D
    --#region UIObject
    local UIObject = Constructor_ButterflyClass("UIObject", CTBase);
    Construct_ButterflyAttribute("Position", UIObject, ATProperty, nil, "\0Position", "\0Position");
    Construct_ButterflyAttribute("Size", UIObject, ATProperty, nil, "\0Size", "\0Size");
    Construct_ButterflyAttribute("Rotation", UIObject, ATProperty, nil, "\0Rotation", "\0Rotation");
    Construct_ButterflyAttribute("AnchorPoint", UIObject, ATProperty, nil, "\0AnchorPoint", "\0AnchorPoint");
    Construct_ButterflyAttribute("ClipsDescendants", UIObject, ATProperty, nil, "\1ClipsDescendants", "\1ClipsDescendants");
    Construct_ButterflyAttribute("LayoutOrder", UIObject, ATProperty, nil, "\0LayoutOrder", "\0LayoutOrder");
    Construct_ButterflyAttribute("SizeConstraint", UIObject, ATProperty, nil, "\0SizeConstraint", "\0SizeConstraint");
    Construct_ButterflyAttribute("Visible", UIObject, ATProperty, nil, "\0Visible", "\0Visible");
    Construct_ButterflyAttribute("Active", UIObject, ATProperty, nil, "\0Active", "\0Active");
    Construct_ButterflyAttribute("AbsoluteVisibility", UIObject, ATProperty, false, DefaultGet);
    Construct_ButterflyAttribute("ZIndex", UIObject, ATProperty, nil, "\0ZIndex", function (Meta, _, Value)
        for _, Component in pairs(Meta["\3"]) do pcall(function ()
            Component.ZIndex = Value;
        end) end;
    end, "\0number");
    local function ObjectAVStep(Object)
        if (typeof(Object) == "Instance" and Object:IsA("GuiBase")) then
            if (Object:IsA("GuiObject")) then
                return Object.Visible;
            end;
            return Object.Enabled;
        elseif (IsA(Object, "ButterflyInstance") and AttributeExists(Object, "AbsoluteVisibility")) then
            return Object.AbsoluteVisibility;
        end;
        return false;
    end;
    --#endregion UIObject
    --#region RedrawObject
    local RedrawObject = Constructor_ButterflyClass("RedrawObject", CTBase);
    Construct_ButterflyAttribute("AutoRedraw", RedrawObject, ATProperty, true, DefaultGet, DefaultSet);
    Construct_ButterflyAttribute("Redraw", RedrawObject, ATMethod);
    --#endregion RedrawObject
    --#region BackgroundObject
    local BackgroundObject = Constructor_ButterflyClass("BackgroundObject", CTBase);
    Construct_ButterflyAttribute("Background", BackgroundObject, ATProperty, nil, DefaultGet);
    --#endregion BackgroundObject
    --#region InputAttributes
    local InputAttributes = Constructor_ButterflyClass("InputAttributes", CTBase);
    Construct_ButterflyAttribute("InputBegan", InputAttributes, ATProperty, nil, "\0InputBegan");
    Construct_ButterflyAttribute("InputChanged", InputAttributes, ATProperty, nil, "\0InputBegan");
    Construct_ButterflyAttribute("InputEnded", InputAttributes, ATProperty, nil, "\0InputBegan");
    --#endregion InputAttributes
    --#region SizeManagement
    local SizeManagement;
    local function LockSize(Proxy)
        MetaRef[Proxy]["\2"].SizeLocked = true;
        return Proxy;
    end;
    SizeManagement = Constructor_ButterflyClass("SizeManagement", CTBase);
    Construct_ButterflyAttribute("Size", SizeManagement, ATProperty, nil, DefaultGet, function (Meta, _, Value)
        if (Meta["\2"].SizeLocked) then error("This Object is SizeLocked."); end;
        GetEnumValue(Meta["\2"].SizeType)(Meta["\3"]["\0"], Value, Meta["\2"].SizeScaling, Meta["\2"].Interval);
        Meta["\2"].Size = Value;
    end);
    Construct_ButterflyAttribute("SizeType", SizeManagement, ATProperty, ButterflySpace.ButterflyEnum.SizeType.UDim2, DefaultGet);
    Construct_ButterflyAttribute("SizeLocked", SizeManagement, ATProperty, false, DefaultGet);
    Construct_ButterflyAttribute("SizeScaling", SizeManagement, ATProperty, nil, DefaultGet);
    --#endregion SizeManagement
    --#region AppearanceManagement
    --[[ Meta["\2"] ->
        0: Color Instance
        1: Transparency Instance
        2: Color Attribute
        3: Transparency Attribute
    ]]
    local AppearanceManagement;
    AppearanceManagement = Constructor_ButterflyClass("AppearanceManagement", CTBase);
    Construct_ButterflyAttribute("Color", AppearanceManagement, ATProperty, nil, DefaultGet, function (Meta, _, Value)
        Meta["\2"].Color = Value;
        Meta["\3"][Meta["\2"]["\0"]][Meta["\2"]["\2"]] = ParseColor(Value, (Meta["\2"].Interval or 0));
    end);
    Construct_ButterflyAttribute("Transparency", AppearanceManagement, ATProperty, 0, DefaultGet, function (Meta, _, Value)
        Meta["\2"].Transparency = Value;
        Meta["\3"][Meta["\2"]["\1"]][Meta["\2"]["\3"]] = ParseNumber(Value, (Meta["\2"].Interval or 0));
    end);
    --#endregion AppearanceManagement
    --#region IntervalAttribute
    local IntervalAttribute;
    IntervalAttribute = Constructor_ButterflyClass("IntervalAttribute", CTBase);
    Construct_ButterflyAttribute("Interval", IntervalAttribute, ATProperty, nil, DefaultGet);
    --#endregion IntervalAttribute
    --#endregion BaseClass
    --#region CoreClass
    --#region SliceFragment
    local SliceFragment;
    SliceFragment = Constructor_ButterflyClass("SliceFragment", CTCore, function (Background, PositionIndex)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(SliceFragment);
        local Main = Instance.new("ImageLabel");

        --#region Setup
        local XC, YC, ZC, RS, RO;
        YC = math.floor(PositionIndex / 3);
        XC = PositionIndex - (YC * 3);
        ZC = UDim2.new(
            (XC == 1 and 1) or 0,
            (XC == 1 and -2) or 1,
            (YC == 1 and 1) or 0,
            (YC == 1 and -2) or 1
        );
        RO = UDim2.new(
            (XC == 2 and 1) or 0,
            (XC >= 1 and 1) or 0,
            (YC == 2 and 1) or 0,
            (YC >= 1 and 1) or 0
        );
        RS = UDim2.new(
            (XC == 1 and 1) or 0,
            (XC ~= 1 and 1) or 0,
            (YC == 1 and 1) or 0,
            (YC ~= 1 and 1) or 0
        );
        Meta["\2"].XC, Meta["\2"].YC, Meta["\2"].ZC, Meta["\2"].RO, Meta["\2"].RS = XC, YC, ZC, RO, RS;
        Meta["\2"].PositionalIndex = PositionIndex;
        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        Proxy.Parent = Background;
        LockParent(Proxy);
        Main.BackgroundTransparency = 1;
        Main.BorderSizePixel = 0;
        Main.Name = Pointer;
        Main.AnchorPoint = Vector2.new(XC / 2, YC / 2);
        Main.Position = UDim2.new(XC / 2, 0, YC / 2, 0);
        Main.ImageColor3 = BackgroundDefaults.Color.Value;
        Main.ImageTransparency = BackgroundDefaults.Transparency.Value;
        Proxy.Type = BackgroundDefaults.BackgroundType.Value;
        --#endregion Setup

        return Proxy, Main;
    end, Base2D, BaseInstance);
    Temp = function (Meta, Attribute, Value)
        if (Attribute == "Type") then Value = CoreButterflySpace.Functions.ParseEnum(Value, "BackgroundType"); end;
        Meta["\2"][Attribute] = Value;
        local EnumData, CornerSize = GetEnumValue(Meta["\2"].Type), Meta["\2"].CornerSize;
        local CS, BS, ZC, RO, RS = EnumData[2], EnumData[3], Meta["\2"].ZC, Meta["\2"].RO, Meta["\2"].RS;
        local Main = Meta["\3"]["\0"];

        Main.Image = "rbxassetid://" .. tostring(EnumData[1]);
        Main.Size = UDim2.new(ZC.X.Scale, ZC.X.Offset * CornerSize, ZC.Y.Scale, ZC.Y.Offset * CornerSize);
        Main.ImageRectSize = Vector2.new((RS.X.Scale * BS) + (RS.X.Offset * CS), (RS.Y.Scale * BS) + (RS.Y.Offset * CS));
        Main.ImageRectOffset = Vector2.new((RO.X.Scale * BS) + (RO.X.Offset * CS), (RO.Y.Scale * BS) + (RO.Y.Offset * CS));
    end;
    Construct_ButterflyAttribute("Type", SliceFragment, ATProperty, nil, DefaultGet, Temp, "\0BackgroundType");
    Construct_ButterflyAttribute("CornerSize", SliceFragment, ATProperty, BackgroundDefaults.CornerSize, DefaultGet, Temp, "\0number");
    Construct_ButterflyAttribute("Color", SliceFragment, ATProperty, nil, "\0ImageColor3","\0ImageColor3");
    Construct_ButterflyAttribute("Transparency", SliceFragment, ATProperty, nil, "\0ImageTransparency","\0ImageTransparency");
    --#endregion SliceFragment
    --#region Background
    local Background;
    Background = Constructor_ButterflyClass("Background", CTCore, function (Parent)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(Background);
        local Main = Instance.new("Frame");
        
        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        Proxy.Parent = Parent;
        LockParent(Proxy);
        local TopLeft = ConstructClass(SliceFragment, Proxy, 0);
        local TopCenter = ConstructClass(SliceFragment, Proxy, 1);
        local TopRight = ConstructClass(SliceFragment, Proxy, 2);
        local CenterLeft = ConstructClass(SliceFragment, Proxy, 3);
        local CenterCenter = ConstructClass(SliceFragment, Proxy, 4);
        local CenterRight = ConstructClass(SliceFragment, Proxy, 5);
        local BottomLeft = ConstructClass(SliceFragment, Proxy, 6);
        local BottomCenter = ConstructClass(SliceFragment, Proxy, 7);
        local BottomRight = ConstructClass(SliceFragment, Proxy, 8);

        Meta["\3"]["\2"] = TopLeft;
        Meta["\3"]["\3"] = TopCenter;
        Meta["\3"]["\4"] = TopRight;
        Meta["\3"]["\5"] = CenterLeft;
        Meta["\3"]["\6"] = CenterCenter;
        Meta["\3"]["\7"] = CenterRight;
        Meta["\3"]["\8"] = BottomLeft;
        Meta["\3"]["\9"] = BottomCenter;
        Meta["\3"]["\10"] = BottomRight;

        Meta["\2"].TopLeft = TopLeft;
        Meta["\2"].TopCenter = TopCenter;
        Meta["\2"].TopRight = TopRight;
        Meta["\2"].CenterLeft = CenterLeft;
        Meta["\2"].CenterCenter = CenterCenter;
        Meta["\2"].CenterRight = CenterRight;
        Meta["\2"].BottomLeft = BottomLeft;
        Meta["\2"].BottomCenter = BottomCenter;
        Meta["\2"].BottomRight = BottomRight;

        Main.Name = Pointer;
        Main.BackgroundTransparency = 1;
        Main.BorderSizePixel = 0;
        Main.Size = UDim2.new(1, 0, 1, 0);
        Main.Position = UDim2.new(0.5, 0, 0.5, 0);
        Main.AnchorPoint = Vector2.new(0.5, 0.5);

        return Proxy, Main;
    end, Base2D, BaseInstance);
    Temp = function (Meta, _, Value)
        Meta["\2"][_] = Value;
        for i = 2, 10 do
            local Corner = Meta["\3"][string.char(i)];
            Corner[_] = Value;
        end;
    end;
    Construct_ButterflyAttribute("Color", Background, ATProperty, BackgroundDefaults.Color, DefaultGet, Temp, "\0Color3");
    Construct_ButterflyAttribute("Transparency", Background, ATProperty, BackgroundDefaults.Transparency, DefaultGet, Temp, "\0number");
    Construct_ButterflyAttribute("CornerSize", Background, ATProperty, BackgroundDefaults.CornerSize, DefaultGet, Temp, "\0number");
    Construct_ButterflyAttribute("Type", Background, ATProperty, BackgroundDefaults.BackgroundType, DefaultGet, Temp, "\0BackgroundType");
    Construct_ButterflyAttribute("TopLeft", Background, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("TopCenter", Background, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("TopRight", Background, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("CenterLeft", Background, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("CenterCenter", Background, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("CenterRight", Background, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("BottomLeft", Background, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("BottomCenter", Background, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("BottomRight", Background, ATProperty, nil, DefaultGet);
    --#endregion Background
    --#region TextRender
    local TextRender;
    TextRender = Constructor_ButterflyClass("TextRender", CTCore, function (Parent)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(TextRender);
        local Main = Instance.new("TextLabel");
        
        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        Proxy.Parent = Parent;
        LockParent(Proxy);

        Main.Name = Pointer;
        Main.BackgroundTransparency = 1;
        Main.BorderSizePixel = 0;
        Main.Position = UDim2.new(0.5, 0, 0.5, 0);
        Main.AnchorPoint = Vector2.new(0.5, 0.5);
        Main.TextColor3 = TextDefaults.Color.Value;
        Main.TextTransparency = TextDefaults.Transparency.Value;
        Main.TextStrokeColor3 = TextDefaults.StrokeColor.Value;
        Main.TextStrokeTransparency = TextDefaults.StrokeTransparency.Value;
        Main.Text = "Konrushi!";
        Meta["\2"]["\0"], Meta["\2"]["\1"] = "\0", "\0";
        Meta["\2"]["\2"], Meta["\2"]["\3"] = "TextColor3", "TextTransparency";
        Proxy.Size = UDim2.new(1, 0, 1, 0);

        return Proxy, Main;
    end, Base2D, BaseInstance, AppearanceManagement, SizeManagement);
    Construct_ButterflyAttribute("Text", TextRender, ATProperty, nil, "\0Text", "\0Text");
    Construct_ButterflyAttribute("Font", TextRender, ATProperty, nil, "\0Font", "\0Font");
    Construct_ButterflyAttribute("StrokeColor", TextRender, ATProperty, nil, "\0TextStrokeColor3", "\0TextStrokeColor3");
    Construct_ButterflyAttribute("StrokeTransparency", TextRender, ATProperty, nil, "\0TextStrokeTransparency", "\0TextStrokeTransparency");
    Construct_ButterflyAttribute("XAlignment", TextRender, ATProperty, nil, "\0TextXAlignment", "\0TextXAlignment");
    Construct_ButterflyAttribute("YAlignment", TextRender, ATProperty, nil, "\0TextYAlignment", "\0TextYAlignment");
    Construct_ButterflyAttribute("Wrapped", TextRender, ATProperty, nil, "\0TextWrapped", "\0TextWrapped");
    Construct_ButterflyAttribute("Truncate", TextRender, ATProperty, nil, "\0TextTruncate", "\0TextTruncate");
    Construct_ButterflyAttribute("TextSize", TextRender, ATProperty, nil, "\0TextSize", "\0TextSize");
    Construct_ButterflyAttribute("TextScaled", TextRender, ATProperty, nil, "\0TextScaled", "\0TextScaled");
    Construct_ButterflyAttribute("RichText", TextRender, ATProperty, nil, "\0RichText", "\0RichText");
    Construct_ButterflyAttribute("LineHeight", TextRender, ATProperty, nil, "\0LineHeight", "\0LineHeight");
    Construct_ButterflyAttribute("TextBounds", TextRender, ATProperty, nil, "\0TextBounds");
    Construct_ButterflyAttribute("TextFits", TextRender, ATProperty, nil, "\0TextFits");
    --#endregion TextRender
    --#region ImageRender
    local ImageRender;
    ImageRender = Constructor_ButterflyClass("ImageRender", CTCore, function (Parent)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(ImageRender);
        local Main = Instance.new("ImageLabel");
        
        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        Proxy.Parent = Parent;
        LockParent(Proxy);

        Main.Name = Pointer;
        Main.BackgroundTransparency = 1;
        Main.BorderSizePixel = 0;
        Main.Position = UDim2.new(0.5, 0, 0.5, 0);
        Main.AnchorPoint = Vector2.new(0.5, 0.5);
        Main.ImageColor3 = Color3.new(1, 1, 1);
        Main.Image = "";
        Meta["\2"]["\0"], Meta["\2"]["\1"] = "\0", "\0";
        Meta["\2"]["\2"], Meta["\2"]["\3"] = "ImageColor3", "ImageTransparency";
        Proxy.Size = UDim2.new(1, 0, 1, 0);

        return Proxy, Main;
    end, Base2D, BaseInstance, SizeManagement, AppearanceManagement);
    Construct_ButterflyAttribute("Texture", ImageRender, ATProperty, nil, "\0Image", "\0Image");
    Construct_ButterflyAttribute("ImageRectOffset", ImageRender, ATProperty, nil, "\0ImageRectOffset", "\0ImageRectOffset");
    Construct_ButterflyAttribute("ImageRectSize", ImageRender, ATProperty, nil, "\0ImageRectSize", "\0ImageRectSize");
    Construct_ButterflyAttribute("IsLoaded", ImageRender, ATProperty, nil, "\0IsLoaded");
    Construct_ButterflyAttribute("ScaleType", ImageRender, ATProperty, nil, "\0ScaleType", "\0ScaleType");
    Construct_ButterflyAttribute("SliceCenter", ImageRender, ATProperty, nil, "\0SliceCenter", "\0SliceCenter");
    Construct_ButterflyAttribute("SliceScale", ImageRender, ATProperty, nil, "\0SliceScale", "\0SliceScale");
    Construct_ButterflyAttribute("TileSize", ImageRender, ATProperty, nil, "\0TileSize", "\0TileSize");
    --#endregion ImageRender
    --#region TextBoxRender
    local TextBoxRender;
    TextBoxRender = Constructor_ButterflyClass("TextBoxRender", CTCore, function (Parent)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(TextBoxRender);
        local Main = Instance.new("TextBox");
        
        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        Proxy.Parent = Parent;
        LockParent(Proxy);

        Main.Name = Pointer;
        Main.BackgroundTransparency = 1;
        Main.BorderSizePixel = 0;
        Main.Size = UDim2.new(1, 0, 1, 0);
        Main.Position = UDim2.new(0.5, 0, 0.5, 0);
        Main.AnchorPoint = Vector2.new(0.5, 0.5);
        Main.TextColor3 = TextBoxDefaults.TextColor.Value;
        Main.TextTransparency = TextBoxDefaults.TextTransparency.Value;
        Main.TextStrokeColor3 = TextBoxDefaults.StrokeColor.Value;
        Main.TextStrokeTransparency = TextBoxDefaults.StrokeTransparency.Value;
        Main.Text = "";
        Main.ClearTextOnFocus = false;
        Main.Changed:Connect(function (Attribute)
            if (Attribute ~= "Text") then return; end;
            Meta["\2"].TextChanged:Fire();
        end);

        return Proxy, Main;
    end, Base2D, BaseInstance);
    Construct_ButterflyAttribute("Text", TextBoxRender, ATProperty, nil, "\0Text", "\0Text");
    Construct_ButterflyAttribute("Font", TextBoxRender, ATProperty, nil, "\0Font", "\0Font");
    Construct_ButterflyAttribute("Color", TextBoxRender, ATProperty, nil, "\0TextColor3", "\0TextColor3");
    Construct_ButterflyAttribute("Transparency", TextBoxRender, ATProperty, TextBoxDefaults.TextTransparency, DefaultGet, function (Meta, _, Value)
        Meta["\2"].Transparency = Value;
        if (Meta["\2"].TextHidden) then return; end;
        Meta["\3"]["\0"].TextTransparency = Value;
    end, "\0number");
    Construct_ButterflyAttribute("TextHidden", TextBoxRender, ATProperty, false, DefaultGet, function (Meta, _, Value)
        Meta["\2"].TextHidden = Value;
        if (Value) then Meta["\3"]["\0"].TextTransparency = 1; return; end;
        Meta["\3"]["\0"].TextTransparency = Meta["\2"].Transparency;
    end, "\0boolean");
    Construct_ButterflyAttribute("StrokeColor", TextBoxRender, ATProperty, nil, "\0TextStrokeColor3", "\0TextStrokeColor3");
    Construct_ButterflyAttribute("StrokeTransparency", TextBoxRender, ATProperty, nil, "\0TextStrokeTransparency", "\0TextStrokeTransparency");
    Construct_ButterflyAttribute("XAlignment", TextBoxRender, ATProperty, nil, "\0TextXAlignment", "\0TextXAlignment");
    Construct_ButterflyAttribute("YAlignment", TextBoxRender, ATProperty, nil, "\0TextYAlignment", "\0TextYAlignment");
    Construct_ButterflyAttribute("Wrapped", TextBoxRender, ATProperty, nil, "\0TextWrapped", "\0TextWrapped");
    Construct_ButterflyAttribute("Truncate", TextBoxRender, ATProperty, nil, "\0TextTruncate", "\0TextTruncate");
    Construct_ButterflyAttribute("Size", TextBoxRender, ATProperty, nil, "\0TextSize", "\0TextSize");
    Construct_ButterflyAttribute("TextScaled", TextBoxRender, ATProperty, nil, "\0TextScaled", "\0TextScaled");
    Construct_ButterflyAttribute("RichText", TextBoxRender, ATProperty, nil, "\0RichText", "\0RichText");
    Construct_ButterflyAttribute("LineHeight", TextBoxRender, ATProperty, nil, "\0LineHeight", "\0LineHeight");
    Construct_ButterflyAttribute("TextBounds", TextBoxRender, ATProperty, nil, "\0TextBounds");
    Construct_ButterflyAttribute("TextFits", TextBoxRender, ATProperty, nil, "\0TextFits");
    Construct_ButterflyAttribute("MultiLine", TextBoxRender, ATProperty, nil, "\0MultiLine", "\0MultiLine");
    Construct_ButterflyAttribute("SelectionStart", TextBoxRender, ATProperty, nil, "\0SelectionStart", "\0SelectionStart");
    Construct_ButterflyAttribute("ShowNativeInput", TextBoxRender, ATProperty, nil, "\0ShowNativeInput", "\0ShowNativeInput");
    Construct_ButterflyAttribute("TextEditable", TextBoxRender, ATProperty, nil, "\0TextEditable", "\0TextEditable");
    Construct_ButterflyAttribute("CaptureFocus", TextBoxRender, ATProperty, nil, "\0CaptureFocus");
    Construct_ButterflyAttribute("IsFocused", TextBoxRender, ATProperty, nil, "\0IsFocused");
    Construct_ButterflyAttribute("ReleaseFocus", TextBoxRender, ATProperty, nil, "\0ReleaseFocus");
    Construct_ButterflyAttribute("FocusLost", TextBoxRender, ATProperty, nil, "\0FocusLost");
    Construct_ButterflyAttribute("Focused", TextBoxRender, ATProperty, nil, "\0Focused");
    Construct_ButterflyAttribute("ReturnPressedFromOnScreenKeyboard", TextBoxRender, ATProperty, nil, "\0ReturnPressedFromOnScreenKeyboard");
    Construct_ButterflyAttribute("TextChanged", TextBoxRender, ATEvent);
    --#endregion TextBoxRender
    --#region Bar
    local Bar;
    Bar = Constructor_ButterflyClass("Bar", CTCore, function (Parent, SizeType, SizeLocked, SizeScaling)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(Bar);
        local Main = Instance.new("ImageLabel");

        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        Main.Name = Pointer;
        Main.BackgroundTransparency = 1;
        Main.BorderSizePixel = 0;
        Main.ScaleType = Enum.ScaleType.Slice;
        Main.ImageColor3 = GeneralDefaults.SecondaryColor.Value;
        Main.Size = UDim2.new(0, 100, 0, 12);
        Proxy.Type = ButterflySpace.ButterflyEnum.BarType.Capsule;
        Proxy.Parent = Parent;
        LockParent(Proxy);
        Meta["\2"].SizeType = SizeType;
        Meta["\2"].SizeLocked = SizeLocked;
        Meta["\2"].SizeScaling = SizeScaling;
        Meta["\2"]["\0"], Meta["\2"]["\1"] = "\0", "\0";
        Meta["\2"]["\2"], Meta["\2"]["\3"] = "ImageColor3", "ImageTransparency";
        Proxy.Color = GeneralDefaults.IndentColor.Value;

        return Proxy, Bar, Meta;
    end, Base2D, BaseInstance, InputAttributes, IntervalAttribute, SizeManagement, AppearanceManagement);
    Construct_ButterflyAttribute("TypeLocked", Bar, ATProperty, false, DefaultGet);
    Construct_ButterflyAttribute("Type", Bar, ATProperty, nil, DefaultGet, function (Meta, _, Value)
        if (Meta["\2"].TypeLocked) then error("This Bar is TypeLocked."); end;
        local Main = Meta["\3"]["\0"];
        local EnumData = GetEnumValue(Value);
        Main.Image = "rbxassetid://" .. tostring(EnumData[1]);
        Main.SliceCenter = EnumData[2];
    end, "\0BarType");
    --#endregion Bar
    --#endregion CoreClass
    --#region StandardClass
    --#region Frame
    local Frame;
    Frame = Constructor_ButterflyClass("Frame", CTStandard, function (Parent)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(Frame);
        local Main = Instance.new("Frame");
        Main.Name = Pointer;

        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        Meta["\3"]["\2"] = ConstructClass(Background, Proxy);
        Meta["\2"].Background = Meta["\3"]["\2"];
        Proxy.Parent = Parent;

        Main.Size = UDim2.new(0, 100, 0, 100);
        Main.BackgroundTransparency = 1;
        Main.BorderSizePixel = 0;

        Meta["\4"][1] = RunService.Heartbeat:Connect(function ()
            Meta["\2"].AbsoluteVisibility = (ObjectAVStep(Main) and ObjectAVStep(Meta["\2"].Parent));
        end);

        return Proxy;
    end, BaseInstance, Base2D, UIObject, BackgroundObject, InputAttributes);
    --#endregion Frame
    --#region Label
    local Label;
    Label = Constructor_ButterflyClass("Label", CTStandard, function (Parent)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(Label);
        local Main = Instance.new("Frame");
        Main.Name = Pointer;

        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        Meta["\3"]["\2"] = ConstructClass(Background, Proxy);
        Meta["\3"]["\3"] = LockSize(ConstructClass(ImageRender, Proxy));
        Meta["\3"]["\4"] = LockSize(ConstructClass(TextRender, Proxy));
        Meta["\2"].Background = Meta["\3"]["\2"];
        Meta["\2"].ImageRender = Meta["\3"]["\3"];
        Meta["\2"].TextRender = Meta["\3"]["\4"];
        Proxy.Parent = Parent;

        Main.Size = UDim2.new(0, 100, 0, 25);
        Main.BackgroundTransparency = 1;
        Main.BorderSizePixel = 0;

        Meta["\4"][1] = RunService.Heartbeat:Connect(function ()
            Meta["\2"].AbsoluteVisibility = (ObjectAVStep(Main) and ObjectAVStep(Meta["\2"].Parent));
        end);

        return Proxy;
    end, BaseInstance, Base2D, UIObject, BackgroundObject, InputAttributes);
    Construct_ButterflyAttribute("TextRender", Label, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("ImageRender", Label, ATProperty, nil, DefaultGet);
    --#endregion Label
    --#region Button
    local Button;
    Button = Constructor_ButterflyClass("Button", CTStandard, function (Parent)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(Button);
        local Main = Instance.new("Frame");
        Main.Name = Pointer;

        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        Meta["\3"]["\2"] = ConstructClass(Background, Proxy);
        Meta["\3"]["\3"] = LockSize(ConstructClass(ImageRender, Proxy));
        Meta["\3"]["\4"] = LockSize(ConstructClass(TextRender, Proxy));
        Meta["\2"].Background = Meta["\3"]["\2"];
        Meta["\2"].ImageRender = Meta["\3"]["\3"];
        Meta["\2"].TextRender = Meta["\3"]["\4"];
        Proxy.Parent = Parent;

        Main.Size = UDim2.new(0, 100, 0, 25);
        Main.BackgroundTransparency = 1;
        Main.BorderSizePixel = 0;
        local RippleFrame = Instance.new("Frame", Main);
        RippleFrame.Size = UDim2.new(1, 0, 1, 0);
        RippleFrame.BackgroundTransparency = 1;
        RippleFrame.BorderSizePixel = 0;
        RippleFrame.AnchorPoint = Vector2.new(0.5, 0.5);
        RippleFrame.Position = UDim2.new(0.5, 0, 0.5, 0);
        RippleFrame.ClipsDescendants = true;
        RippleFrame.Name = "RippleFrame";

        Meta["\4"][1] = RunService.Heartbeat:Connect(function ()
            Meta["\2"].AbsoluteVisibility = (ObjectAVStep(Main) and ObjectAVStep(Meta["\2"].Parent));
        end);
        Main.InputEnded:Connect(function (InputObject)
            if (not Meta["\2"].RippleEffect or InputObject.UserInputType ~= Enum.UserInputType.MouseButton1) then return; end;
            local Ripple = Instance.new("ImageLabel", RippleFrame);
            local RippleBase = Instance.new("NumberValue", Ripple);
            local Tween = TweenService:Create(RippleBase, Meta["\2"].RippleTween, {Value = 1});
            local TotalTime = TotalTweenTime(Meta["\2"].RippleTween);
            
            Ripple.Name = "RippleEffect";
            Ripple.BackgroundTransparency = 1;
            Ripple.BorderSizePixel = 0;
            Ripple.Position = UDim2.new(0, InputObject.Position.X - Main.AbsolutePosition.X, 0, InputObject.Position.Y - Main.AbsolutePosition.Y);
            Ripple.AnchorPoint = Vector2.new(0.5, 0.5);
            Ripple.Image = "rbxassetid://3457843087";

            RippleBase.Name = "RippleBase";
            RippleBase.Value = 0;

            Tween:Play();

            Debris:AddItem(Tween, TotalTime);
            Debris:AddItem(Ripple, TotalTime);
            Debris:AddItem(RippleBase, TotalTime);
            repeat RunService.Heartbeat:Wait();
                local Interval = RippleBase.Value;
                Ripple.ImageColor3 = ParseColor(Meta["\2"].RippleColor, Interval);
                Ripple.ImageTransparency = ParseNumber(Meta["\2"].RippleTransparency, Interval);
                Temp = ParseNumber(Meta["\2"].RippleSize, Interval);
                Ripple.Size = UDim2.new(0, Temp, 0, Temp);
            until not RippleBase.Parent;
            Tween, Ripple, RippleBase = nil, nil, nil;
        end);

        return Proxy;
    end, BaseInstance, Base2D, UIObject, BackgroundObject, InputAttributes);
    Construct_ButterflyAttribute("TextRender", Button, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("ImageRender", Button, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("RippleEffect", Button, ATProperty, true, DefaultGet, DefaultSet, "\0boolean");
    Construct_ButterflyAttribute("RippleColor", Button, ATProperty, GeneralDefaults.HighlightColor, DefaultGet, DefaultSet, "\0BaseColor");
    Construct_ButterflyAttribute("RippleTransparency", Button, ATProperty, NumberSequence.new(0.25, 1), DefaultGet, DefaultSet, "\0BaseNumber");
    Construct_ButterflyAttribute("RippleSize", Button, ATProperty, NumberSequence.new(0, 100), DefaultGet, DefaultSet, "\0BaseNumber");
    Construct_ButterflyAttribute("RippleTween", Button, ATProperty, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), DefaultGet, DefaultSet, "\0TweenInfo");
    --#endregion Button
    --#region TextBox
    local TextBox;
    TextBox = Constructor_ButterflyClass("TextBox", CTStandard, function (Parent)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(TextBox);
        local Main = Instance.new("Frame");
        local TweenBase = Instance.new("NumberValue", Main);

        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        Proxy.Parent = Parent;
        Meta["\3"]["\2"] = LockSize(ConstructClass(Background, Proxy));
        Meta["\3"]["\3"] = LockSize(ConstructClass(ImageRender, Proxy));
        Meta["\3"]["\4"] = LockSize(ConstructClass(TextRender, Proxy));
        Meta["\3"]["\5"] = ConstructClass(TextBoxRender, Proxy);
        Meta["\3"]["\6"] = LockSize(ConstructClass(TextRender, Proxy));
        Meta["\3"]["\7"] = LockSize(ConstructClass(TextRender, Proxy));
        Meta["\3"]["\8"] = MetaRef[Meta["\3"]["\4"]]["\3"]["\0"];
        Meta["\3"]["\9"] = MetaRef[Meta["\3"]["\6"]]["\3"]["\0"];
        Meta["\3"]["\10"] = MetaRef[Meta["\3"]["\7"]]["\3"]["\0"];
        Meta["\3"]["\11"] = MetaRef[Meta["\3"]["\5"]]["\3"]["\0"];
        Meta["\3"]["\15"] = TweenBase;
        Meta["\3"]["\16"] = MetaRef[Meta["\3"]["\2"]]["\3"]["\0"];
        local LineFrame = Instance.new("Frame", Main);
        local _, Line = ConstructClass(Background, Proxy);
        Line.Parent = LineFrame;
        Meta["\3"]["\12"] = _;
        Meta["\3"]["\13"] = Line;
        Meta["\3"]["\14"] = LineFrame;
        Meta["\2"].Background = Meta["\3"]["\2"];
        Meta["\2"].Image = Meta["\3"]["\3"];
        Meta["\2"].Suggestion = Meta["\3"]["\4"];
        Meta["\2"].Text = Meta["\3"]["\5"];
        Meta["\2"].Placeholder = Meta["\3"]["\6"];
        Meta["\2"].TextChanged = Meta["\2"].Text.TextChanged;

        Main.BackgroundTransparency = 1;
        Main.BorderSizePixel = 0;
        Main.Name = Pointer;
        Main.Size = UDim2.new(0, 100, 0, 25);
        TweenBase.Name = "TweenBase";
        TweenBase.Value = 0;
        LineFrame.BackgroundTransparency = 1;
        LineFrame.BorderSizePixel = 0;
        LineFrame.Name = "LineFrame";
        LineFrame.ClipsDescendants = true;
        _ = Meta["\2"].Background
        _.Color = TextBoxDefaults.BackColor.Value;
        _.Transparency = TextBoxDefaults.BackTransparency.Value;
        _ = Meta["\2"].Placeholder
        _.Color = TextBoxDefaults.PlaceholderColor.Value;
        _.Text = TextBoxDefaults.Placeholder.Value;
        _.XAlignment = Enum.TextXAlignment.Left;
        _ = Meta["\2"].Suggestion
        _.Transparency = 0.5;
        _.Color = TextBoxDefaults.TextColor.Value;
        _.Text = "";
        _.XAlignment = Enum.TextXAlignment.Left;
        _ = Meta["\2"].Text;
        _.Color = TextBoxDefaults.TextColor.Value;
        _.Transparency = TextBoxDefaults.TextTransparency.Value;
        _.StrokeColor = TextBoxDefaults.StrokeColor.Value;
        _.StrokeTransparency = TextBoxDefaults.StrokeTransparency.Value;
        _.Text = "";
        _.XAlignment = Enum.TextXAlignment.Left;
        Meta["\3"]["\7"].XAlignment = Enum.TextXAlignment.Left;


        Meta["\4"][1] = RunService.Heartbeat:Connect(function ()
            Meta["\2"].AbsoluteVisibility = (ObjectAVStep(Main) and ObjectAVStep(Meta["\2"].Parent));
            if (Meta["\2"].AutoRedraw and Meta["\2"].AbsoluteVisibility) then
                Proxy:Redraw();
            end;
        end);
        Meta["\2"].Text.Focused:Connect(function ()
            local Tween = TweenService:Create(TweenBase, Meta["\2"].LineTween, {Value = 1});
            Tween:Play();
            Debris:AddItem(Tween, TotalTweenTime(Meta["\2"].LineTween));
            Tween = nil;
        end);
        Meta["\2"].Text.FocusLost:Connect(function ()
            local Tween = TweenService:Create(TweenBase, Meta["\2"].LineTween, {Value = 0});
            Tween:Play();
            Debris:AddItem(Tween, TotalTweenTime(Meta["\2"].LineTween));
            Tween = nil;
        end);
        Proxy.Padding = Vector2.new(6, 0);

        return Proxy;
    end, BaseInstance, Base2D, UIObject, BackgroundObject, InputAttributes, RedrawObject);
    Construct_ButterflyAttribute("Text", TextBox, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("Suggestion", TextBox, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("Image", TextBox, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("Placeholder", TextBox, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("PasswordChar", TextBox, ATProperty, "\226\128\162", DefaultGet, DefaultSet, "\0string");
    Construct_ButterflyAttribute("IsPassword", TextBox, ATProperty, false, DefaultGet, DefaultSet, "\0boolean");
    Construct_ButterflyAttribute("LineEffect", TextBox, ATProperty, true, DefaultGet, DefaultSet, "\0boolean");
    Construct_ButterflyAttribute("StartPoint", TextBox, ATProperty, Vector2.new(0.5, 1), DefaultGet, DefaultSet, "\0Vector2");
    Construct_ButterflyAttribute("EndPoint", TextBox, ATProperty, Vector2.new(1, 1), DefaultGet, DefaultSet, "\0Vector2");
    Construct_ButterflyAttribute("LineThickness", TextBox, ATProperty, 4, DefaultGet, DefaultSet, "\0number");
    Construct_ButterflyAttribute("LineColor", TextBox, ATProperty, GeneralDefaults.HighlightColor, DefaultGet, DefaultSet, "\0BaseColor");
    Construct_ButterflyAttribute("LineTransparency", TextBox, ATProperty, 0, DefaultGet, DefaultSet, "\0BaseNumber");
    Construct_ButterflyAttribute("LineTween", TextBox, ATProperty, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), DefaultGet, DefaultSet, "\0TweenInfo");
    Construct_ButterflyAttribute("Padding", TextBox, ATProperty, nil, DefaultGet, function (Meta, _, Value)
        Meta["\2"].Padding = Value;
        local TBox, Suggestion, Placeholder, PasswordDisplay;-- 11 8 9 10
        TBox = Meta["\3"]["\11"];
        Suggestion = Meta["\3"]["\8"];
        Placeholder = Meta["\3"]["\9"];
        PasswordDisplay = Meta["\3"]["\10"];
        TBox.Size = UDim2.new(1, -Value.X, 1, -Value.Y);
        Suggestion.Size, PasswordDisplay.Size, Placeholder.Size = TBox.Size, TBox.Size, TBox.Size;
    end, "\0Vector2");
    Construct_ButterflyAttribute("Redraw", TextBox, ATMethod, function (self)
        if (not self) then SELFCALL_Expected(); end;
        local Meta = MetaRef[self];
        if (not Meta) then SELFCALL_Expected(); end;
        --#region Visibility
        local TBox, Placeholder, PasswordDisplay;-- 5 9 10
        TBox = Meta["\3"]["\5"];
        Placeholder = Meta["\3"]["\9"];
        PasswordDisplay = Meta["\3"]["\10"];
        local Pwd = "";
        if (Meta["\2"].IsPassword and Meta["\2"].PasswordChar ~= "") then
            TBox.TextHidden = true;
            for _ = 1, #TBox.Text do
                Pwd = Pwd .. Meta["\2"].PasswordChar;
            end;
        end;
        PasswordDisplay.Text = Pwd;
        Placeholder.Visible = (TBox.Text == "");
        TBox, Placeholder, PasswordDisplay = nil, nil, nil;
        --#endregion Visibility
        --#region LineEffect
        local Line, LineFrame, TweenBase = Meta["\3"]["\13"], Meta["\3"]["\14"], Meta["\3"]["\15"];-- 13 14 15 16
        local LineBG = Meta["\3"]["\12"];
        local Main = Meta["\3"]["\0"];
        LineFrame.Visible = Meta["\2"].LineEffect;
        if (not Meta["\2"].LineEffect) then return; end;
        LineFrame.AnchorPoint = Meta["\2"].StartPoint;
        Line.AnchorPoint = Meta["\2"].StartPoint;
        LineFrame.Position = UDim2.new(Meta["\2"].StartPoint.X, 0, Meta["\2"].StartPoint.Y, 0);
        Line.Position = LineFrame.Position;
        local X0, X1, Y0, Y1, LineThickness = DirectionalMagnitude(Meta["\2"].StartPoint, Meta["\2"].EndPoint);
        LineThickness = Meta["\2"].LineThickness;
        LineFrame.Size = UDim2.new(X0 * TweenBase.Value, X1 * LineThickness, Y0 * TweenBase.Value, Y1 * LineThickness);
        LineBG.Color = ParseColor(Meta["\2"].LineColor, TweenBase.Value);
        LineBG.Transparency = ParseNumber(Meta["\2"].LineTransparency, TweenBase.Value);
        Line.Size = UDim2.new(0, Main.AbsoluteSize.X, 0, Main.AbsoluteSize.Y);
        LineBG.Type = Meta["\3"]["\2"].Type;
        LineBG.CornerSize = Meta["\3"]["\2"].CornerSize;
        --#endregion LineEffect
    end);
    Construct_ButterflyAttribute("TextChanged", TextBox, ATProperty, nil, DefaultGet);
    --#endregion TextBox
    --#region Slider
    local Slider;
    Slider = Constructor_ButterflyClass("Slider", CTStandard, function (Parent)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(Slider);
        local Main = Instance.new("Frame");
        local ValueBase = Instance.new("NumberValue", Main);

        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        Meta["\3"]["\2"] = ConstructClass(Bar, Proxy);
        Meta["\3"]["\3"] = ConstructClass(Bar, Proxy);
        Meta["\3"]["\4"] = ConstructClass(ImageRender, Proxy);
        Meta["\3"]["\5"] = ValueBase;
        Meta["\2"].Bar = Meta["\3"]["\2"];
        Meta["\2"].FillBar = Meta["\3"]["\3"];
        Meta["\2"].Markup = Meta["\3"]["\4"];
        ValueBase.Name = "TweenBase";
        Main.Name = Pointer;
        Main.Size = UDim2.new(0, 100, 0, 12);
        Main.BackgroundTransparency = 1;
        Main.BorderSizePixel = 0;
        Proxy.Parent = Parent;

        local PMeta, PMain;
        PMeta = MetaRef[Meta["\3"]["\2"]];
        PMain = PMeta["\3"]["\0"];
        LockSize(Meta["\3"]["\2"]);
        PMeta["\2"].Size = UDim2.new(1, 0, 1, 0);
        PMain.Size = UDim2.new(1, 0, 1, 0);

        PMeta = MetaRef[Meta["\3"]["\3"]];
        PMain = PMeta["\3"]["\0"];
        PMeta["\2"].TypeLocked = true;
        LockSize(Meta["\3"]["\3"]);
        Meta["\3"]["\3"].Color = GeneralDefaults.HighlightColor.Value;

        PMeta = MetaRef[Meta["\3"]["\4"]];
        PMain = PMeta["\3"]["\0"];
        PMeta["\2"].SizeLocked = false;
        PMeta["\2"].SizeType = ButterflySpace.ButterflyEnum.SizeType.Offset;
        PMeta["\2"].SizeScaling = UDim2.new(0, 1, 0, 1);
        Meta["\3"]["\4"].Size = 8;
        Meta["\3"]["\4"].Color = GeneralDefaults.SecondaryColor.Value;
        PMain.Image = "rbxassetid://3457843087";
        PMain.AnchorPoint = Vector2.new(0.5, 0.5);

        local IsDown = false;
        Meta["\4"][1] = RunService.Heartbeat:Connect(function ()
            Meta["\2"].AbsoluteVisibility = (ObjectAVStep(Main) and ObjectAVStep(Meta["\2"].Parent));
            if (Meta["\2"].AutoRedraw and Meta["\2"].AbsoluteVisibility) then
                Proxy:Redraw();
            end;
        end);
        Main.InputBegan:Connect(function (InputObject)
            if (InputObject.UserInputType ~= Enum.UserInputType.MouseButton1) then return; end;
            local Axis = GetLargeAxis(Main);
            IsDown = true;
            Proxy.Value = Map(
                InputObject.Position[Axis],
                Main.AbsolutePosition[Axis],
                Main.AbsolutePosition[Axis] + Main.AbsoluteSize[Axis],
                Meta["\2"].MinValue,
                Meta["\2"].MaxValue
            );
        end);
        Meta["\4"]["\0"] = UserInputService.InputChanged:Connect(function (InputObject)
            if (InputObject.UserInputType ~= Enum.UserInputType.MouseMovement or not IsDown) then return; end;
            local Axis = GetLargeAxis(Main);
            Proxy.Value = Map(
                InputObject.Position[Axis],
                Main.AbsolutePosition[Axis],
                Main.AbsolutePosition[Axis] + Main.AbsoluteSize[Axis],
                Meta["\2"].MinValue,
                Meta["\2"].MaxValue
            );
        end);
        Main.InputEnded:Connect(function (InputObject)
            if (InputObject.UserInputType ~= Enum.UserInputType.MouseButton1) then return; end;
            IsDown = false;
        end);
        Proxy.Value = 5;

        return Proxy;
    end, BaseInstance, Base2D, UIObject, InputAttributes, RedrawObject);
    Construct_ButterflyAttribute("MinValue", Slider, ATProperty, 0, DefaultGet, DefaultSet, "\0number");
    Construct_ButterflyAttribute("MaxValue", Slider, ATProperty, 10, DefaultGet, DefaultSet, "\0number");
    Construct_ButterflyAttribute("Value", Slider, ATProperty, 5, DefaultGet, function (Meta, _, Value)
        if (Meta["\2"].Step > 0) then Value = Round(Value / Meta["\2"].Step) * Meta["\2"].Step; end;
        Value = math.min(Meta["\2"].MaxValue, math.max(Meta["\2"].MinValue, Value));
        local Tween = TweenService:Create(Meta["\3"]["\5"], Meta["\2"].ValueTween, {
            Value = Map(Value, Meta["\2"].MinValue, Meta["\2"].MaxValue, 0, 1)
        });
        Tween:Play();
        local OldValue = Meta["\2"].Value;
        Meta["\2"].Value = Value;
        if (Value ~= OldValue) then
            Meta["\2"].ValueChanged:Fire(Value, OldValue);
        end;
        Debris:AddItem(Tween, TotalTweenTime(Meta["\2"].ValueTween));
    end, "\0number");
    Construct_ButterflyAttribute("Step", Slider, ATProperty, 0, DefaultGet, DefaultSet, "\0number");
    Construct_ButterflyAttribute("Markup", Slider, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("Bar", Slider, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("FillBar", Slider, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("ValueTween", Slider, ATProperty, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), DefaultGet, DefaultSet, "\0TweenInfo");
    Construct_ButterflyAttribute("ValueChanged", Slider, ATEvent);
    Construct_ButterflyAttribute("Redraw", Slider, ATMethod, function (self)
        local Meta = MetaRef[self];
        local Main = Meta["\3"]["\0"];
        local TweenBase = Meta["\3"]["\5"];
        local Bar, FillBar, Markup = Meta["\2"].Bar, Meta["\2"].FillBar, Meta["\2"].Markup;
        local PMeta, PMain, A0, A1, Side;
        local Value = Meta["\2"].Value;

        Value = math.min(Meta["\2"].MaxValue, math.max(Meta["\2"].MinValue, Value));
        if (Value ~= Meta["\2"].Value) then self.Value = Value; end;

        Side = math.min(Main.AbsoluteSize.X, Main.AbsoluteSize.Y) / 2;
        if (Main.AbsoluteSize.X >= Main.AbsoluteSize.Y) then
            A0 = Vector2.new(1, 0);
            A1 = Vector2.new(0, 1);
        else
            A0 = Vector2.new(0, 1);
            A1 = Vector2.new(1, 0);
        end;
        
        PMeta = MetaRef[Bar];
        PMain = PMeta["\3"]["\0"];
        PMeta["\2"].Interval = TweenBase.Value;
        PMain.ImageColor3 = ParseColor(PMeta["\2"].Color, TweenBase.Value);
        PMain.ImageTransparency = ParseNumber(PMeta["\2"].Transparency, TweenBase.Value);
        
        PMeta = MetaRef[FillBar];
        PMain = PMeta["\3"]["\0"];
        PMeta["\2"].Interval = TweenBase.Value;
        PMain.ImageColor3 = ParseColor(PMeta["\2"].Color, TweenBase.Value);
        PMain.ImageTransparency = ParseNumber(PMeta["\2"].Transparency, TweenBase.Value);
        local Axis = GetLargeAxis(Main);
        local UnitSize = (Side * 2) + (TweenBase.Value * (Main.AbsoluteSize[Axis] - (Side * 2)));
        PMain.Size = UDim2.new(
            A1.X,
            A0.X * UnitSize,
            A1.Y,
            A0.Y * UnitSize
        );

        PMeta = MetaRef[Markup];
        PMain = PMeta["\3"]["\0"];
        PMeta["\2"].Interval = TweenBase.Value;
        PMain.ImageColor3 = ParseColor(PMeta["\2"].Color, TweenBase.Value);
        PMain.ImageTransparency = ParseNumber(PMeta["\2"].Transparency, TweenBase.Value);
        UnitSize = Side + (TweenBase.Value * (Main.AbsoluteSize[Axis] - (Side * 2)));
        PMain.Position = UDim2.new(
            A1.X / 2,
            A0.X * UnitSize,
            A1.Y / 2,
            A0.Y * UnitSize
        );
    end);
    --#endregion Slider
    --#region ScrollBar
    local ScrollBar;
    ScrollBar = Constructor_ButterflyClass("ScrollBar", CTStandard, function (Parent)
        local Proxy, Meta, Pointer = Constructor_ButterflyInstance(ScrollBar);
        local Main = Instance.new("Frame");
        local ValueBase = Instance.new("NumberValue", Main);

        Meta["\3"]["\0"], Meta["\3"]["\1"] = Main, Main;
        local Canvas, Bar = ConstructClass(Bar, Proxy), ConstructClass(Bar, Proxy);
        Meta["\2"].Canvas = Canvas;
        Meta["\2"].Bar = Bar;
        Meta["\3"]["\2"] = Canvas;
        Meta["\3"]["\3"] = Bar;
        Meta["\3"]["\4"] = ValueBase;

        
    end, BaseInstance, Base2D, UIObject, InputAttributes, RedrawObject);
    Construct_ButterflyAttribute("CanvasSize", ScrollBar, ATProperty, 200, DefaultGet, DefaultSet, "\0number");
    Construct_ButterflyAttribute("ScreenSize", ScrollBar, ATProperty, 100, DefaultGet, DefaultSet, "\0number");
    Construct_ButterflyAttribute("ScreenOffset", ScrollBar, ATProperty, 0, DefaultGet, DefaultSet, "\0number");
    Construct_ButterflyAttribute("Canvas", ScrollBar, ATProperty, nil, DefaultGet);
    Construct_ButterflyAttribute("Bar", ScrollBar, ATProperty, nil, DefaultGet);
    --#endregion ScrollBar
    --#endregion StandardClass
    --#endregion Classes

    ButterflySpace.ButterflyUI = {
        IsA = IsA,
        Create = CreateInstance,
        Destroy = Deconstructor_ButterflyUI
    };
    CoreButterflySpace.Functions.LockParent = LockParent;
    CoreButterflySpace.MetaRef.ButterflyUI = MetaRef;
    CoreButterflySpace.Meta.ButterflyUI = Meta_ButterflyUI;
    CoreButterflySpace.Constructors.Proxy = Constructor_ButterflyProxy;
    CoreButterflySpace.Constructors.Class = Constructor_ButterflyClass;
    CoreButterflySpace.Constructors.Attribute = Construct_ButterflyAttribute;
    CoreButterflySpace.Constructors.Instance = Constructor_ButterflyInstance;
    CoreButterflySpace.Functions.RemoveAttribute = RemoveAttribute;
    CoreButterflySpace.Functions.ConstructClass = ConstructClass;
    ButterflySpace.Core = CoreButterflySpace;
    return ButterflySpace;
end;
--#endregion ButterflyUI

--#region Imports
Init_ButterflyEnum();
Init_ButterflyDefaults();
Init_ButterflyEvents();
Init_ButterflyUI();
--#endregion Imports

local f = ButterflySpace.ButterflyUI.Create("Frame", MainUI);
f.Size = UDim2.new(0.5, 0, 0.5, 0);
f.Position = UDim2.new(0.5, 0, 0.5, 0);
f.AnchorPoint = Vector2.new(0.5, 0.5);

local x = ButterflySpace.ButterflyUI.Create("Slider", f);
x.Position = UDim2.new(0.5, 0, 0.5, 0);
x.AnchorPoint = Vector2.new(0.5, 0.5);
x.Size = UDim2.new(0, 12, 0, 100);
x.ValueChanged:Connect(print);
--return ButterflySpace;
