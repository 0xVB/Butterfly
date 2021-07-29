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
