
local composer = require("composer")

local scene = composer.newScene()
local physics = require("physics")
physics.start()

local screenTouched
local update
local onCollision
local preCollision
local gameOver

local platforms = {}
local platformSpeed = 0.9
local platformSpeedMax = 1.1
local player
local death = false


---------------------------------------------------------------------------------
function update()
    player.x = player.x + (3*player.xScale)

    if player.y <= 0 and player.onGround then
        gameOver()
    end

    if player.x >= display.contentWidth then
        player.x = display.contentWidth
        player.xScale = player.xScale * -1
    elseif player.x <= 0 then
        player.x = 0
        player.xScale = player.xScale * -1
    end

    for i, platform in pairs(platforms) do

        platform.y = platform.y - platformSpeed

        platform.gap.x = platform.gap.x + (2*platform.gap.xScale)

        if platform.gap.x >= display.contentWidth then
            platform.gap.x = display.contentWidth
            platform.gap.xScale = platform.gap.xScale * -1
        elseif platform.gap.x <= 0 then
            platform.gap.x = 0
            platform.gap.xScale = platform.gap.xScale * -1
        end

        if platform.y <= -100 then
            platformSpeed = platformSpeed + 0.02

            local lastPlatform
            if i == 1 then
                lastPlatform = platforms[#platforms]
            else
                lastPlatform = platforms[i-1]
            end

            platform.y = lastPlatform.y + 140
            platform.gap.x = math.random(25, display.contentWidth-25)
        end

        if platformSpeed > platformSpeedMax then platformSpeed = platformSpeedMax end
        platform.gap.y = platform.y
    end
end

function screenTouched(event)
    if event.phase == "began" then
        if player.onGround then
            player:setLinearVelocity(0, -450)
        else
            player:setLinearVelocity(0, 700)
            player.stomping = true
        end
    elseif event.phase == "ended" then

    end
end

function gameOver()
    if not death then
        death = true   
        composer.gotoScene("retry", {effect="fade", time=100})
    end
end

function preCollision(self, event)
    
    
    if event.other.name == "platform" then
        local thisPlatform = event.other
        
        if player.stomping and 
        player.contentBounds.xMax < (thisPlatform.gap.contentBounds.xMax+5)and 
        player.contentBounds.xMin > (thisPlatform.gap.contentBounds.xMin-5) then
            event.contact.isEnabled = false
            -- player.stomping = false
        else
            player.stomping = false
        end
    end
end

function onCollision(self, event)

    if event.phase == "began" and event.other.name == "platform" then
        player.onGround = true 
    elseif event.phase == "ended" and event.other.name == "platform" then
        player.onGround = false
    end
end


function scene:create(event)
    local sceneGroup = self.view
    player = display.newRect(sceneGroup, 100, 280, 24, 28)
    player:setFillColor(1,0,0)
    physics.addBody(player, "dynamic", {
        bounce = 0
    })
    player.stomping = false
    player.onGround = true
    player.gravityScale = 3.0
    player.isFixedRotation = true
    player.collision = onCollision
    player:addEventListener("collision") 

    player.preCollision = preCollision
    player:addEventListener("preCollision")      


    for i=1, 6, 1 do 
        local platform = display.newRect(sceneGroup, display.contentCenterX, 300 + (i * 140), display.contentWidth, 14)
        platform.name = "platform"
        physics.addBody(platform, "static", {
            bounce = 0
        })

        platform.gap = display.newRect(sceneGroup, math.random(25, display.contentWidth-25), platform.y, 50, 14)
        platform.gap:setFillColor(0,1,0)
        platforms[#platforms+1] = platform
    end 



end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        Runtime:addEventListener("enterFrame", update)
    elseif phase == "did" then
 
        
    end 
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        Runtime:removeEventListener("enterFrame", update)
        Runtime:removeEventListener("touch", screenTouched)
        Runtime:removeEventListener("collision", onCollision)
    elseif phase == "did" then

    end 
end


function scene:destroy(event)
    local sceneGroup = self.view

    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

Runtime:addEventListener("touch", screenTouched)

---------------------------------------------------------------------------------

return scene
