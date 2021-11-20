while true do
-- Basic libraries
local component=require('component');
local term=require('term');
local gpu=component.gpu;
local reactor=component.draconic_reactor;
local energy=component.draconic_rf_storage;
local ri=reactor.getReactorInfo();
local math=require('math');
local event = require('event');
local sides = require('sides');
local colors = require('colors');
local os = require('os')

-- NOTE: Change addresses depending on what is in your setup otherwise it will error. Use analyzer to find addresses
local rsaddr1 = '[ADDRESS]';
local rsaddr2 = '[ADDRESS]';
local rs1 = component.proxy(rsaddr1);
local rs2 = component.proxy(rsaddr2);

local inputAddr='[ADDRESS]';
local outputAddr='[ADDRESS]';
local inputGate=component.proxy(inputAddr);
local outputGate=component.proxy(outputAddr);


-- functions
function draw_line(x, y, length, color)
  if length < 0 then
    length = 0;
  end
  gpu.setBackground(color);
  gpu.fill(x, y, length, 1, " ");
  gpu.setBackground(0x000000);
end

function progress_bar(x, y, length, minVal, maxVal, bar_color, bg_color)
  draw_line(x, y, length, bg_color);
  local barSize=math.floor((minVal/maxVal) * length);
  draw_line(x, y, barSize, bar_color);
end

function clear()
  gpu.setBackground(0x000000);
  term.clear();
end

-- main
  clear();
  --Reactor Data tree
  local temp=ri.temperature;
  local cfs=ri.fieldStrength;
  local status=ri.status;
  local fc=ri.fuelConversion;
  local gr=ri.generationRate;
  local fcr=ri.fuelConversionRate;
  local es=ri.energySaturation;
  local fdr=ri.fieldDrainRate;
  local mes=ri.maxEnergySaturation;
  local mfs=ri.maxFieldStrength;
  local mfc=ri.maxFuelConversion;
  
  --enery core data
  local estored=energy.getEnergyStored();
  local ecapacity=energy.getMaxEnergyStored();
  --lock flowgates
  inputGate.setOverrideEnabled(true);
  outputGate.setOverrideEnabled(true);

  term.setCursor(90, 8);
  term.write("Temperature");
  term.setCursor(130, 8);
  term.write(temp .. "C/10000C");
  if (temp < 8000) then
    progress_bar(90, 9, 60, temp, 10000, 0xFF9200, 0x5A5A5A);
  else
    progress_bar(90, 9, 60, temp, 10000, 0xFF2400, 0x5A5A5A);
  end

  term.setCursor(90, 11);
  term.write("Field Strength");
  term.setCursor(130, 11);
  local cfspr=((cfs/mfs)*100);
  term.write(cfspr .. "%");
  if (cfspr < 30) then
    progress_bar(90, 12, 60, cfs, mfs, 0xFF2400, 0x5A5A5A);
  elseif (cfspr < 70) then
    progress_bar(90, 12, 60, cfs, mfs, 0x0024FF, 0x5A5A5A);
  else 
    progress_bar(90, 12, 60, cfs, mfs, 0x0092FF, 0x5A5A5A);
  end
  
  term.setCursor(90, 14);
  term.write("Energy Saturation");
  term.setCursor(130, 14);
  local espr=((es/mes)*100);
  term.write(espr .. "%");
  if (espr < 25) then
    progress_bar(90, 15, 60, es, mes, 0xFF2400, 0x5A5A5A);
  elseif (espr < 75) then
    progress_bar(90, 15, 60, es, mes, 0x99FF00, 0x5A5A5A);
  else
    progress_bar(90, 15, 60, es, mes, 0x00FFFF, 0x5A5A5A);
  end

  term.setCursor(90, 17);
  term.write("Fuel Left");
  local fcl=(mfc - fc);
  term.setCursor(130, 17);
  term.write(fcl .. "/" .. mfc);
  local fcpr=((fc/mfc)*100);
  if (fcpr < 80) then
    progress_bar(90, 18, 60, fcl, mfc, 0xFF9200, 0x5A5A5A);
  else
    progress_bar(90, 18, 60, fcl, mfc, 0xFF0000, 0x5A5A5A);
  end

  term.setCursor(10, 8);
  term.write("Status: ");
  term.setCursor(30, 8);
  if (status == "offline") or (status == "cold") then
    gpu.setForeground(0x5A5A5A);
    term.write("Offline")
    gpu.setForeground(0xFFFFFF);
  elseif (status == "charging") or ((status == "warming_up") and (temp < 2000)) then
    gpu.setForeground(0xFF9200);
    term.write("Charging");
    gpu.setForeground(0xFFFFFF);
  elseif (status == "charged") or ((status == "warming_up") and (temp >= 2000)) then
    gpu.setForeground(0xFFB600);
    term.write("Ready");
    gpu.setForeground(0xFFFFFF);
  elseif (status == "online") or (status == "running") then
    gpu.setForeground(0x99FF00);
    term.write("Online");
    gpu.setForeground(0xFFFFFF);
  elseif (status == "stopping") or (status == "cooling") then
    gpu.setForeground(0xFF0040);
    term.write("Stopping");
    gpu.setForeground(0xFFFFFF);
  else
    gpu.setForeground(0xFF0000);
    term.write("INVALID");
    gpu.setForeground(0xFFFFFF);
  end

  term.setCursor(90, 20);
  term.write("Generation Rate");
  term.setCursor(130, 20);
  gpu.setForeground(0x99FF00);
  local kgr=(gr/1000)
  term.write(kgr .. "kRF/t");
  term.setCursor(130, 21);
  term.write(gr .. "RF/t")
  gpu.setForeground(0xFFFFFF);  

  term.setCursor(90, 23);
  term.write("Field Drain Rate");
  term.setCursor(130, 23);
  gpu.setForeground(0xFF0040);
  local kfdr=(fdr/1000);  
  term.write(kfdr .. "kRF/t");
  term.setCursor(130, 24);
  term.write(fdr .. "RF/t");
  gpu.setForeground(0xFFFFFF);

  gpu.setBackground(0xFF0000);
  gpu.fill(1, 35, 80, 16, " ");
  gpu.setBackground(0x000000);
  gpu.fill(1, 36, 78, 15, " ");
  term.setCursor(1, 36);
  term.write("Warnings");

  term.setCursor(10, 10);
  term.write("Input:");
  term.setCursor(30, 10);
  gpu.setForeground(0xFF9200);
  local ifg=inputGate.getFlow();
  term.write(ifg .. "RF/t");
  gpu.setForeground(0xFFFFFF);

  term.setCursor(10, 12);
  term.write("Gross Output:");
  term.setCursor(30, 12);
  gpu.setForeground(0xFF9200);
  ofg=outputGate.getFlow();
  term.write(ofg .. "RF/t");
  gpu.setForeground(0xFFFFFF);

  term.setCursor(10, 14);
  term.write("Net Output:");
  term.setCursor(30, 14);
  local gol = (ofg-ifg);
  if (gol < 0) then
    gpu.setForeground(0xFF0040);
  elseif (gol > 0) then
    gpu.setForeground(0x99FF00);
  else
    gpu.setForeground(0xFF9200);
  end
  term.write(gol .. "RF/t");
  gpu.setForeground(0xFFFFFF);

  term.setCursor(10, 16);
  term.write("Stored:");
  term.setCursor(30, 16);
  gpu.setForeground(0xFF9200);
  term.write(estored .. "RF/" .. ecapacity .. "RF");
  gpu.setForeground(0xFFFFFF);

--warnings
  if (status == "offline") or (status == "cold") then
    term.setCursor(2 , 38);
    term.write("Reactor is Offline, thus it is not generating power");
  end
  if (cfspr < 25) then
    term.setCursor(2, 39);
    term.write("Containment field is below Critical level, Shutdown will be required");
  elseif (cfspr < 35) then
    term.setCursor(2, 39);
    term.write("Containment field is below 35%, consider increasing Input power");
  end
  if (temp > 8000) then
    term.setCursor(2, 40);
    term.write("Temperature is above 8000C, consider reducing Output power");
  end
  if (status == "charging") or ((status == "warming_up") and (temp < 2000)) then
    term.setCursor(2, 38);
    term.write("Reactor is warming up, thus consuming power");
  end
  if (status == "charged") or ((status == "warming_up") and (temp >= 2000)) then
    term.setCursor(2, 38);
    term.write("Reactor is ready. Activate reactor!");
  end
  if (status == "stopping") then
    term.setCursor(2, 38);
    term.write("Reactor is shutting down");
  end
  if (fcpr > 80) then
    term.setCursor(2, 41);
    term.write("Reactor is running low on fuel, consider refuel");
  end




  local inupA = rs1.getBundledInput(sides.top, 8);
  if ((inupA ~= 0 ) and (holdIA == 0)) then
    holdIA = 1;
    local newifg = (ifg+1000);
    inputGate.setFlowOverride(newifg);
  end
  if (inupA == 0) then
    holdIA = 0;
  end
  local inupB = rs1.getBundledInput(sides.top, 9);
  if ((inupB ~= 0) and (holdIB == 0)) then
    holdIB = 1;
    local newifg = (ifg+10000);
    inputGate.setFlowOverride(newifg);
  end
  if (inupB == 0) then
    holdIB = 0;
  end  
  local inupC = rs1.getBundledInput(sides.top, 10);
  if ((inupC ~= 0) and (holdIC == 0)) then
    holdIC = 1;
    local newifg = (ifg+100000);
    inputGate.setFlowOverride(newifg);
  end
  if (inupC == 0) then
    holdIC = 0;
  end
  local indnA = rs1.getBundledInput(sides.top, 12);
  if ((indnA ~= 0) and (holdID == 0)) then
    holdID = 1;
    local newifg = (ifg-1000);
    inputGate.setFlowOverride(newifg);
  end
  if (indnA == 0) then
    holdID = 0;
  end
  local indnB = rs1.getBundledInput(sides.top, 13);
  if ((indnB ~= 0) and (holdIE == 0)) then
    holdIE = 1;
    local newifg = (ifg-10000);
    inputGate.setFlowOverride(newifg);
  end
  if (indnB == 0) then
    holdIE = 0;
  end
  local indnC = rs1.getBundledInput(sides.top, 14);
  if ((indnC ~= 0) and (holdIF == 0)) then
    holdIF = 1;
    local newifg = (ifg-100000);
    inputGate.setFlowOverride(newifg);
  end
  if (indnC == 0) then
    holdIF = 0;
  end

  local outupA = rs1.getBundledInput(sides.top, 0);
  if ((outupA ~= 0) and (holdOA == 0)) then
    holdOA = 1;
    local newifg = (ofg+1000);
    outputGate.setFlowOverride(newifg);
  end
  if (outupA == 0) then
    holdOA = 0;
  end
  local outupB = rs1.getBundledInput(sides.top, 1);
  if ((outupB ~= 0) and (holdOB == 0)) then
    holdOB = 1;
    local newifg = (ofg+10000);
    outputGate.setFlowOverride(newifg);
  end
  if (outupB == 0) then
    holdOB = 0;
  end
  local outupC = rs1.getBundledInput(sides.top, 2);
  if ((outupC ~= 0) and (holdOC == 0)) then
    holdOC = 1;
    local newifg = (ofg+100000);
    outputGate.setFlowOverride(newifg);
  end
  if (outupC == 0) then
    holdOC = 0;
  end
  local outdnA = rs1.getBundledInput(sides.top, 4);
  if ((outdnA ~= 0) and (holdOD == 0)) then
    holdOD = 1;
    local newifg = (ofg-1000);
    outputGate.setFlowOverride(newifg);
  end
  if (outdnA == 0) then
    holdOD = 0;
  end
  local outdnB = rs1.getBundledInput(sides.top, 5);
  if ((outdnB ~= 0) and (holdOE == 0)) then
    holdOE = 1;
    local newifg = (ofg-10000);
    outputGate.setFlowOverride(newifg);
  end
  if (outdnB == 0) then
    holdOE = 0;
  end
  local outdnC = rs1.getBundledInput(sides.top, 6);
  if ((outdnC ~= 0) and (holdOF == 0)) then
    holdOF = 1;
    local newifg = (ofg-100000);
    outputGate.setFlowOverride(newifg);
  end
  if (outdnC == 0) then
    holdOF = 0;
  end

  local stopb = rs2.getBundledInput(sides.top, 12);
  if (stopb ~= 0) and (holdST == 0) then
    reactor.stopReactor();
    holdST = 1;
  end
  if (stopb == 0) then
    holdST = 0; 
  end
  local chrgb = rs2.getBundledInput(sides.top, 4);
  if (chrgb ~= 0) and (holdCB == 0) then
    reactor.chargeReactor();
    holdCB = 1;
  end
  if (chrgb == 0) then
    holdCB = 0;
  end
  local actb  = rs2.getBundledInput(sides.top, 8);
  if (actb ~= 0) and (holdAB == 0) then
    reactor.activateReactor();
    holdAB = 1;
  end
  if (actb == 0) then
    holdAB = 0;
  end

  if (ifg < 0) then
    inputGate.setFlowOverride(0);
  end
  if (ofg < 0) then
    outputGate.setFlowOverride(0);
  end
  

  if (status == "offline") or (status == "cold") then
    rs2.setBundledOutput(sides.top, {[colors.green] = 15, [colors.red] = 0, [colors.cyan] = 0, [colors.lime] = 0, [colors.pink] = 0});  
  elseif (status == "stopping") or (status == "cooling") then
    rs2.setBundledOutput(sides.top, {[colors.green] = 0, [colors.red] = 15, [colors.cyan] = 0, [colors.lime] = 0, [colors.pink] = 0});  
  elseif (status == "online") or (status == "running")  then
    rs2.setBundledOutput(sides.top, {[colors.green] = 0, [colors.red] = 0, [colors.cyan] = 15, [colors.lime] = 0, [colors.pink] = 0});  
  elseif (status == "charging") or ((status == "warming_up") and (temp < 2000))  then
    rs2.setBundledOutput(sides.top, {[colors.green] = 0, [colors.red] = 0, [colors.cyan] = 0, [colors.lime] = 15, [colors.pink] = 0});  
  elseif (status == "charged") or ((status == "warming_up") and (temp >= 2000)) then
    rs2.setBundledOutput(sides.top, {[colors.green] = 0, [colors.red] = 0, [colors.cyan] = 0, [colors.lime] = 0, [colors.pink] = 15});  
  else
    rs2.setBundledOutput(sides.top, {[colors.green] = 0, [colors.red] = 0, [colors.cyan] = 0, [colors.lime] = 0, [colors.pink] = 0});  
  end                      
os.sleep(0.001);
end
