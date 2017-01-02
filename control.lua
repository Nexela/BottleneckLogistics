--script.on_event("bottleneck_toggle_on", function(event) game.print("bottleneck turned on") end)
--script.on_event("bottleneck_toggle_off", function(event) game.print("bottleneck turned off") end)

local bottleneck_toggle = remote.call("Bottleneck", "get_ids")

script.on_event(bottleneck_toggle, function(event)
    if event.enable then
      game.print("Bottleneck Enabled")
    else
      game.print("Bottleneck Disabled")
    end
  end
  )
