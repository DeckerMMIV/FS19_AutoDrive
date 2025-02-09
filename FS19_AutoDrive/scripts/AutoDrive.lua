AutoDrive = {}
AutoDrive.Version = "1.0.7.0-5"
AutoDrive.experimentalFeatures = {}
AutoDrive.experimentalFeatures.smootherDriving = true
AutoDrive.configChanged = false
AutoDrive.handledRecalculation = true

AutoDrive.directory = g_currentModDirectory
AutoDrive.actions = {
	{"ADToggleMouse", true, 1},
	{"ADToggleHud", true, 1},
	{"ADEnDisable", true, 1},
	{"ADSelectTarget", false, 0},
	{"ADSelectPreviousTarget", false, 0},
	{"ADSelectTargetUnload", false, 0},
	{"ADSelectPreviousTargetUnload", false, 0},
	{"ADActivateDebug", false, 0},
	{"ADDebugShowClosest", false, 0},
	{"ADDebugSelectNeighbor", false, 0},
	{"ADDebugChangeNeighbor", false, 0},
	{"ADDebugCreateConnection", false, 0},
	{"ADDebugCreateMapMarker", false, 0},
	{"ADDebugDeleteWayPoint", false, 0},
	{"ADDebugForceUpdate", false, 0},
	{"ADDebugDeleteDestination", false, 3},
	{"ADSilomode", false, 0},
	{"ADOpenGUI", true, 2},
	{"ADCallDriver", false, 3},
	{"ADSelectNextFillType", false, 0},
	{"ADSelectPreviousFillType", false, 0},
	{"ADRecord", false, 0},
	{"AD_export_routes", false, 0},
	{"AD_import_routes", false, 0},
	{"AD_upload_routes", false, 0},
	{"ADGoToVehicle", false, 3},
	{"ADNameDriver", false, 0},
	{"ADRenameMapMarker", false, 0},
	{"ADSwapTargets", false, 0}
}

AutoDrive.drawHeight = 0.3

AutoDrive.MODE_DRIVETO = 1
AutoDrive.MODE_PICKUPANDDELIVER = 2
AutoDrive.MODE_DELIVERTO = 3
AutoDrive.MODE_LOAD = 4
AutoDrive.MODE_UNLOAD = 5
AutoDrive.MODE_BGA = 6

AutoDrive.WAYPOINTS_PER_PACKET = 100
AutoDrive.SPEED_ON_FIELD = 38

AutoDrive.DC_NONE = 0
AutoDrive.DC_VEHICLEINFO = 1
AutoDrive.DC_COMBINEINFO = 2
AutoDrive.DC_TRAILERINFO = 4
AutoDrive.DC_DEVINFO = 8
AutoDrive.DC_PATHINFO = 16
AutoDrive.DC_SENSORINFO = 32
AutoDrive.DC_NETWORKINFO = 64
AutoDrive.DC_EXTERNALINTERFACEINFO = 128
AutoDrive.DC_ALL = 65535

AutoDrive.currentDebugChannelMask = AutoDrive.DC_NONE --AutoDrive.DC_ALL;

AutoDrive.SD_MAX_SPEED_FACTOR = 35
AutoDrive.SD_MIN_SPEED_FACTOR = 1
AutoDrive.SD_RETURN_SPEED_FACTOR_MULTIPLIER = 6

function AutoDrive:loadMap(name)
	source(Utils.getFilename("scripts/AutoDriveFunc.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveTrailerUtil.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveXML.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveInputFunctions.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveGraphHandling.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveLineDraw.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveDriveFuncs.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveTrigger.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveDijkstra.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveUtilFuncs.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveMultiplayer.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveCombineMode.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDrivePathFinder.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveSettings.lua", AutoDrive.directory))
	source(Utils.getFilename("gui/enterDriverNameGUI.lua", AutoDrive.directory))
	source(Utils.getFilename("gui/enterGroupNameGUI.lua", AutoDrive.directory))
	source(Utils.getFilename("gui/enterTargetNameGUI.lua", AutoDrive.directory))
	source(Utils.getFilename("gui/enterDestinationFilterGUI.lua", AutoDrive.directory))
	source(Utils.getFilename("gui/AutoDriveGUI.lua", AutoDrive.directory))
	source(Utils.getFilename("gui/settingsPage.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveExternalInterface.lua", AutoDrive.directory))
	source(Utils.getFilename("gui/settings.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/AutoDriveBGAUnloader.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/Sensors/AutoDriveVirtualSensors.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/Sensors/ADCollSensor.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/Sensors/ADFruitSensor.lua", AutoDrive.directory))
	source(Utils.getFilename("scripts/Sensors/ADFieldSensor.lua", AutoDrive.directory))
	AutoDrive:loadGUI()

	g_logManager:devInfo("[AutoDrive] Map title: %s", g_currentMission.missionInfo.map.title)

	AutoDrive.loadedMap = g_currentMission.missionInfo.map.title
	AutoDrive.loadedMap = string.gsub(AutoDrive.loadedMap, " ", "_")
	AutoDrive.loadedMap = string.gsub(AutoDrive.loadedMap, "%.", "_")
	AutoDrive.loadedMap = string.gsub(AutoDrive.loadedMap, ",", "_")
	AutoDrive.loadedMap = string.gsub(AutoDrive.loadedMap, ":", "_")
	AutoDrive.loadedMap = string.gsub(AutoDrive.loadedMap, ";", "_")

	g_logManager:devInfo("[AutoDrive] Parsed map title: %s", AutoDrive.loadedMap)

	AutoDrive.mapWayPoints = {}
	AutoDrive.mapWayPointsCounter = 0
	AutoDrive.mapMarker = {}
	AutoDrive.mapMarkerCounter = 0
	AutoDrive.showMouse = false

	AutoDrive.groups = {}
	AutoDrive.groups["All"] = 1
	AutoDrive.groupCounter = 1

	AutoDrive.pullDownListExpanded = 0
	AutoDrive.pullDownListDirection = 0

	AutoDrive.lastSetSpeed = 50

	AutoDrive.print = {}
	AutoDrive.print.currentMessage = nil
	AutoDrive.print.referencedVehicle = nil
	AutoDrive.print.nextMessage = nil
	AutoDrive.print.showMessageFor = 12000
	AutoDrive.print.currentMessageActiveSince = 0

	AutoDrive.requestedWaypoints = false
	AutoDrive.requestedWaypointCount = 1
	AutoDrive.playerSendsMapToServer = false

	AutoDrive.mouseWheelActive = false

	AutoDrive.requestWayPointTimer = 10000

	AutoDrive.loadStoredXML()

	if g_server ~= nil then
		AutoDrive.usersData = {}
		AutoDrive.loadUsersData()
	end

	AutoDrive:initLineDrawing()

	AutoDrive.Hud = AutoDriveHud:new()
	AutoDrive.Hud:loadHud()

	-- Save Configuration when saving savegame
	FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, AutoDrive.saveSavegame)

	LoadTrigger.onActivateObject = Utils.overwrittenFunction(LoadTrigger.onActivateObject, AutoDrive.onActivateObject)
	LoadTrigger.getIsActivatable = Utils.overwrittenFunction(LoadTrigger.getIsActivatable, AutoDrive.getIsActivatable)
	LoadTrigger.onFillTypeSelection = Utils.overwrittenFunction(LoadTrigger.onFillTypeSelection, AutoDrive.onFillTypeSelection)

	VehicleCamera.zoomSmoothly = Utils.overwrittenFunction(VehicleCamera.zoomSmoothly, AutoDrive.zoomSmoothly)

	LoadTrigger.load = Utils.overwrittenFunction(LoadTrigger.load, AutoDrive.loadTriggerLoad)
	LoadTrigger.delete = Utils.overwrittenFunction(LoadTrigger.delete, AutoDrive.loadTriggerDelete)

	-- I can't find AutoDrive.fillTriggerOnCreate, are we still using it?
	FillTrigger.onCreate = Utils.overwrittenFunction(FillTrigger.onCreate, AutoDrive.fillTriggerOnCreate)

	if g_server ~= nil then
		AutoDrive.Server = {}
		AutoDrive.Server.Users = {}
	else
		AutoDrive.highestIndex = 1
	end

	AutoDrive.waitingUnloadDrivers = {}
	AutoDrive.destinationListeners = {}

	AutoDrive.Recalculation = {}
	AutoDrive.Recalculation.continue = false

	AutoDrive.delayedCallBacks = {}

	--AutoDrive.delayedCallBacks.openEnterDriverNameGUI =
	--    DelayedCallBack:new(
	--    function()
	--        g_gui:showGui("ADEnterDriverNameGui")
	--    end
	--)
	--AutoDrive.delayedCallBacks.openEnterTargetNameGUI =
	--    DelayedCallBack:new(
	--    function()
	--        g_gui:showGui("ADEnterTargetNameGui")
	--    end
	--)
	--AutoDrive.delayedCallBacks.openEnterGroupNameGUI =
	--    DelayedCallBack:new(
	--    function()
	--        g_gui:showGui("ADEnterGroupNameGui")
	--    end
	--)
end

function AutoDrive:firstRun()
	if g_server == nil then
		-- Here we could ask to server the initial sync
		AutoDriveUserConnectedEvent.sendEvent()
	end

	if AutoDrive.searchedTriggers ~= true then
		AutoDrive.getAllTriggers()
		AutoDrive.searchedTriggers = true
	end
end

function AutoDrive:saveSavegame()
	if AutoDrive.GetChanged() == true or AutoDrive.HudChanged then
		AutoDrive.saveToXML(AutoDrive.adXml)
		AutoDrive.configChanged = false
		AutoDrive.HudChanged = false
	else
		if AutoDrive.adXml ~= nil then
			saveXMLFile(AutoDrive.adXml)
		end
	end
	if g_server ~= nil then
		AutoDrive.saveUsersData()
	end
end

function AutoDrive:deleteMap()
end

function AutoDrive:keyEvent(unicode, sym, modifier, isDown)
end

function AutoDrive:mouseEvent(posX, posY, isDown, isUp, button)
	local vehicle = g_currentMission.controlledVehicle

	if vehicle ~= nil and vehicle.ad ~= nil and vehicle.ad.nToolTipWait ~= nil then
		if vehicle.ad.sToolTip ~= "" then
			if vehicle.ad.nToolTipWait <= 0 then
				vehicle.ad.sToolTip = ""
			else
				vehicle.ad.nToolTipWait = vehicle.ad.nToolTipWait - 1
			end
		end
	end

	if vehicle ~= nil and vehicle.ad ~= nil and vehicle.ad.lastMouseState ~= g_inputBinding:getShowMouseCursor() then
		AutoDrive:onToggleMouse(vehicle)
	end

	if vehicle ~= nil and AutoDrive.Hud.showHud == true then
		AutoDrive.Hud:mouseEvent(vehicle, posX, posY, isDown, isUp, button)
	end
end

function AutoDrive:update(dt)
	if AutoDrive.isFirstRun == nil then
		AutoDrive.isFirstRun = false
		self:firstRun()
	end
	--if (g_currentMission.controlledVehicle ~= nil) then
	--	--	AutoDrive.renderTable(0.1, 0.9, 0.015, AutoDrive.mapWayPoints[AutoDrive:findClosestWayPoint(g_currentMission.controlledVehicle)])
	--	--	AutoDrive.renderTable(0.3, 0.9, 0.008, AutoDrive.mapMarker)
	--	--	local printTable = {}
	--	--	printTable.g_logManager = g_logManager
	--	--	printTable.LogManager = LogManager
	--	AutoDrive.renderTable(0.1, 0.9, 0.008, AutoDrive.Triggers)
	--	AutoDrive.renderTable(0.8, 0.9, 0.009, UserManager)
	--end

	if AutoDrive.getDebugChannelIsSet(AutoDrive.DC_NETWORKINFO) then
		if AutoDrive.debug.lastSentEvent ~= nil then
			AutoDrive.renderTable(0.3, 0.9, 0.009, AutoDrive.debug.lastSentEvent)
		end
	end

	--local t = {}
	--for k, v in pairs(AutoDrive.settings) do
	--	t[k] = tostring(v.current) .. " -> " .. tostring(v.values[v.current])
	--end
	--AutoDrive.renderTable(0.2, 0.9, 0.009, t)

	-- Iterate over all delayed call back instances and call update (that's needed to make the script working)
	for _, delayedCallBack in pairs(AutoDrive.delayedCallBacks) do
		delayedCallBack:update(dt)
	end

	AutoDrive.handlePerFrameOperations(dt)

	AutoDrive.handlePrintMessage(dt)

	AutoDrive.handleMultiplayer(dt)
end

function AutoDrive:draw()
end

function AutoDrive.handlePerFrameOperations(dt)
	for _, vehicle in pairs(g_currentMission.vehicles) do
		if (vehicle.ad ~= nil and vehicle.ad.noMovementTimer ~= nil and vehicle.lastSpeedReal ~= nil) then
			vehicle.ad.noMovementTimer:timer((vehicle.lastSpeedReal <= 0.0010), 3000, dt)
		end

		if (vehicle.ad ~= nil and vehicle.ad.noTurningTimer ~= nil) then
			local cpIsTurning = vehicle.cp ~= nil and (vehicle.cp.isTurning or (vehicle.cp.turnStage ~= nil and vehicle.cp.turnStage > 0))
			local aiIsTurning = (vehicle.getAIIsTurning ~= nil and vehicle:getAIIsTurning() == true)
			local combineSteering = false --combine.rotatedTime ~= nil and (math.deg(combine.rotatedTime) > 10);
			local combineIsTurning = cpIsTurning or aiIsTurning or combineSteering
			vehicle.ad.noTurningTimer:timer((not combineIsTurning), 4000, dt)
		end
	end

	if AutoDrive.Triggers ~= nil then
		for _, trigger in pairs(AutoDrive.Triggers.siloTriggers) do
			if trigger.stoppedTimer == nil then
				trigger.stoppedTimer = AutoDriveTON:new()
			end
			trigger.stoppedTimer:timer(not trigger.isLoading, 300, dt)
		end
	end
end

function AutoDrive.handlePrintMessage(dt)
	if AutoDrive.print.currentMessage ~= nil then
		AutoDrive.print.currentMessageActiveSince = AutoDrive.print.currentMessageActiveSince + dt
		if AutoDrive.print.nextMessage ~= nil then
			if AutoDrive.print.currentMessageActiveSince > 6000 then
				AutoDrive.print.currentMessage = AutoDrive.print.nextMessage
				AutoDrive.print.referencedVehicle = AutoDrive.print.nextReferencedVehicle
				AutoDrive.print.nextMessage = nil
				AutoDrive.print.nextReferencedVehicle = nil
				AutoDrive.print.currentMessageActiveSince = 0
			end
		end
		if AutoDrive.print.currentMessageActiveSince > AutoDrive.print.showMessageFor then
			AutoDrive.print.currentMessage = nil
			AutoDrive.print.currentMessageActiveSince = 0
			AutoDrive.print.referencedVehicle = nil
			--AutoDrive.print.showMessageFor = 12000;
			if AutoDrive.print.nextMessage ~= nil then
				AutoDrive.print.currentMessage = AutoDrive.print.nextMessage
				AutoDrive.print.referencedVehicle = AutoDrive.print.nextReferencedVehicle
				AutoDrive.print.nextMessage = nil
				AutoDrive.print.nextReferencedVehicle = nil
				AutoDrive.print.currentMessageActiveSince = 0
			end
		end
	else
		if AutoDrive.print.nextMessage ~= nil then
			AutoDrive.print.currentMessage = AutoDrive.print.nextMessage
			AutoDrive.print.referencedVehicle = AutoDrive.print.nextReferencedVehicle
			AutoDrive.print.nextMessage = nil
			AutoDrive.print.nextReferencedVehicle = nil
			AutoDrive.print.currentMessageActiveSince = 0
		end
	end
end

function AutoDrive.MarkChanged()
	AutoDrive.configChanged = true
	AutoDrive.handledRecalculation = false
end

function AutoDrive.GetChanged()
	return AutoDrive.configChanged
end

function AutoDrive.addGroup(groupName, sendEvent)
	if groupName:len() > 1 and AutoDrive.groups[groupName] == nil then
		if sendEvent == nil or sendEvent == true then
			-- Propagating group creation all over the network
			AutoDriveGroupsEvent.sendEvent(groupName, AutoDriveGroupsEvent.TYPE_ADD)
		else
			AutoDrive.groupCounter = AutoDrive.tableLength(AutoDrive.groups) + 1
			AutoDrive.groups[groupName] = AutoDrive.groupCounter
			for _, vehicle in pairs(g_currentMission.vehicles) do
				if (vehicle.ad ~= nil) then
					if vehicle.ad.groups[groupName] == nil then
						vehicle.ad.groups[groupName] = false
					end
				end
			end
			-- Resetting HUD
			AutoDrive.Hud.lastUIScale = 0
		end
	end
end

function AutoDrive.removeGroup(groupName, sendEvent)
	if AutoDrive.groups[groupName] ~= nil then
		if sendEvent == nil or sendEvent == true then
			-- Propagating group creation all over the network
			AutoDriveGroupsEvent.sendEvent(groupName, AutoDriveGroupsEvent.TYPE_REMOVE)
		else
			local groupId = AutoDrive.groups[groupName]
			-- Removing group from the groups list
			AutoDrive.groups[groupName] = nil
			-- Removing group from the vehicles groups list
			for _, vehicle in pairs(g_currentMission.vehicles) do
				if (vehicle.ad ~= nil) then
					if vehicle.ad.groups[groupName] ~= nil then
						vehicle.ad.groups[groupName] = nil
					end
				end
			end
			-- Moving all markers in the delete group to default group
			for markerID, _ in pairs(AutoDrive.mapMarker) do
				if AutoDrive.mapMarker[markerID].group == groupName then
					AutoDrive.mapMarker[markerID].group = "All"
				end
			end
			-- Resetting other goups id
			for gName, gId in pairs(AutoDrive.groups) do
				if groupId <= gId then
					AutoDrive.groups[gName] = gId - 1
				end
			end
			-- Resetting HUD
			AutoDrive.Hud.lastUIScale = 0
			AutoDrive.groupCounter = AutoDrive.tableLength(AutoDrive.groups)
		end
	end
end

function AutoDrive.renameDriver(vehicle, name, sendEvent)
	if name:len() > 1 and vehicle ~= nil and vehicle.ad ~= nil then
		if sendEvent == nil or sendEvent == true then
			-- Propagating driver rename all over the network
			AutoDriveRenameDriverEvent.sendEvent(vehicle, name)
		else
			vehicle.ad.driverName = name
		end
	end
end

function AutoDrive.getIsStuckInTraffic(vehicle)
	if vehicle ~= nil and vehicle.ad ~= nil and vehicle.ad.stuckInTrafficTimer ~= nil then
		return vehicle.ad.stuckInTrafficTimer >= 1000 -- 1 second
	end
	return false
end

function AutoDrive:zoomSmoothly(superFunc, offset)
	if not AutoDrive.mouseWheelActive then -- don't zoom camera when mouse wheel is used to scroll targets (thanks to sperrgebiet)
		superFunc(self, offset)
	end
end

function AutoDrive:onActivateObject(superFunc, vehicle)
	if vehicle ~= nil then
		--if i'm in the vehicle, all is good and I can use the normal function, if not, i have to cheat:
		if g_currentMission.controlledVehicle ~= vehicle or g_currentMission.controlledVehicles[vehicle] == nil then
			local oldControlledVehicle = nil
			if vehicle.ad ~= nil and vehicle.ad.oldControlledVehicle == nil then
				vehicle.ad.oldControlledVehicle = g_currentMission.controlledVehicle
			else
				oldControlledVehicle = g_currentMission.controlledVehicle
			end
			g_currentMission.controlledVehicle = vehicle

			superFunc(self, vehicle)

			if vehicle.ad ~= nil and vehicle.ad.oldControlledVehicle ~= nil then
				g_currentMission.controlledVehicle = vehicle.ad.oldControlledVehicle
				vehicle.ad.oldControlledVehicle = nil
			else
				if oldControlledVehicle ~= nil then
					g_currentMission.controlledVehicle = oldControlledVehicle
				end
			end
			return
		end
	end

	superFunc(self, vehicle)
end

function AutoDrive:onFillTypeSelection(superFunc, fillType)
	if fillType ~= nil and fillType ~= FillType.UNKNOWN then
		local validFillableObject = self.validFillableObject
		if validFillableObject ~= nil then --and validFillableObject:getRootVehicle() == g_currentMission.controlledVehicle
			local fillUnitIndex = self.validFillableFillUnitIndex
			self:setIsLoading(true, validFillableObject, fillUnitIndex, fillType)
		end
	end
end

-- LoadTrigger doesn't allow filling non controlled tools
function AutoDrive:getIsActivatable(superFunc, objectToFill)
	--when the trigger is filling, it uses this function without objectToFill
	if objectToFill ~= nil then
		local vehicle = objectToFill:getRootVehicle()
		if vehicle ~= nil and vehicle.ad ~= nil and vehicle.ad.isActive then
			--if i'm in the vehicle, all is good and I can use the normal function, if not, i have to cheat:
			if g_currentMission.controlledVehicle ~= vehicle then
				local oldControlledVehicle = nil
				if vehicle.ad ~= nil and vehicle.ad.oldControlledVehicle == nil then
					vehicle.ad.oldControlledVehicle = g_currentMission.controlledVehicle
				else
					oldControlledVehicle = g_currentMission.controlledVehicle
				end
				g_currentMission.controlledVehicle = vehicle or objectToFill

				local result = superFunc(self, objectToFill)

				if vehicle.ad ~= nil and vehicle.ad.oldControlledVehicle ~= nil then
					g_currentMission.controlledVehicle = vehicle.ad.oldControlledVehicle
					vehicle.ad.oldControlledVehicle = nil
				else
					if oldControlledVehicle ~= nil then
						g_currentMission.controlledVehicle = oldControlledVehicle
					end
				end
				return result
			end
		end
	end
	return superFunc(self, objectToFill)
end

function AutoDrive:loadTriggerLoad(superFunc, rootNode, xmlFile, xmlNode)
	local result = superFunc(self, rootNode, xmlFile, xmlNode)

	if result and AutoDrive.Triggers ~= nil then
		AutoDrive.Triggers.loadTriggerCount = AutoDrive.Triggers.loadTriggerCount + 1
		AutoDrive.Triggers.siloTriggers[AutoDrive.Triggers.loadTriggerCount] = self
	end

	return result
end

function AutoDrive:loadTriggerDelete(superFunc)
	if AutoDrive.Triggers ~= nil then
		for i, trigger in pairs(AutoDrive.Triggers.siloTriggers) do
			if trigger == self then
				AutoDrive.Triggers.siloTriggers[i] = nil
			end
		end
	end
	superFunc(self)
end

addModEventListener(AutoDrive)
