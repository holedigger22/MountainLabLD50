--[[
    Class describing the Volcano object.
    The Volcano is the main focus of the game state - the volcano
    slowly gets angrier over time, the player drops animals and people
    into it to appease it, and when it eventually reaches full anger,
    it erupts and the game ends.
    Author: Hans Jorgensen
]]

Volcano = Class{}

-- TODO: Is there a way to avoid absolute pathnames here?
local NormalState = require "src/volcano/states/NormalState"
local ExplodingState = require "src/volcano/states/ExplodingState"
local ExplodedState = require "src/volcano/states/ExplodedState"

--[[
    The volcano has three main states:
    - Normal: The normal gameplay loop - the volcano slowly builds up anger, develops cravings,
      accepts offerings, etc.
    - Exploding: The volcano has hit max anger and is playing a mad sick explosion animation of some kind
    - Exploded: The volcano has erupted - we should transfer the main game to Game Over at this point
]]

function Volcano:init()
    self.state_machine = StateMachine{
        normal = NormalState,
        exploding = ExplodingState,
        exploded = ExplodedState,
    }
    -- Enter the normal state, passing state change functions into the parameters
    self.state_machine.change("normal", { 
        explode_callback = generate_explode_callback(self.state_machine) 
    })
end

function generate_explode_callback(state_machine)
    return function()
        state_machine:change("exploding", {
            exploded_callback = function() state_machine:change("exploded", {}) end
        })
    end
end

function Volcano:is_exploded()
    local current = self.state_machine.current
    if current.is_exploded ~= nil then
        return current:is_exploded()
    else
        return false
    end
end

function Volcano:update()
    self.state_machine:update()
end

function Volcano:processAI()
    self.state_machine:processAI()
end

function Volcano:accept_offering(offering)
    local current = self.state_machine.current
    if current.accept_offering ~= nil then
        current:accept_offering(offering)
    end
end

function Volcano:render()
    self.state_machine:render()
end