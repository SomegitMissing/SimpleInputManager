# Simple Input Manager
An easy to use input manager for Game Maker. Allowing you to map multiple inputs to one action.

You just add your actions in the `global.Actions` located in `SimpleInputManager` script.

```gml
global.Actions = {
	left: [
		new KeyboardAction(vk_left),
		new ControllerButtonAction(gp_padl),
		new ControllerStickAction(gp_axislh, -1, 0.2),
	],
	right: [
		new KeyboardAction(vk_right),
		new ControllerButtonAction(gp_padr),
		new ControllerStickAction(gp_axislh, 1, 0.2),
	],
	jump: [
		new KeyboardAction(vk_up),
		new KeyboardAction(vk_space),
		new ControllerButtonAction(gp_face1),
	],
};
```

Then you just use the function `CheckAction` to check if the action was executed.

```gml
if (CheckAction(global.Actions.jump)) {
  y += 10;
}
```

I haven't tested it, but as far as I know it should work in all platforms since it just uses the built in Game Maker functions for keyboard and controller input.