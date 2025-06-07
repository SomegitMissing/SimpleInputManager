/**
 * @param {Constant.VirualKey | Real} value
 */
function KeyboardAction(value) constructor {
    self.value = value;

    /**@returns {Bool} */
    static press = function() {
        return keyboard_check(value);
    }

    /**@returns {Bool} */
    static just_pressed = function() {
        return keyboard_check_pressed(value);
    }

    /**@returns {Bool} */
    static just_release = function() {
        return keyboard_check_released(value);
    }
}

/**
 * @param {Constant.GamepadButton} value
 */
function ControllerButtonAction(value) constructor {
    self.value = value;

    /**
     * @param {Real}
     * @returns {Bool}
     */
    static press = function(controller) {
        return gamepad_button_check(controller, value);
    }

    /**
     * @param {Real}
     * @returns {Bool}
     */
    static just_pressed = function(controller) {
        return gamepad_button_check_pressed(controller, value);
    }

    /**
     * @param {Real}
     * @returns {Bool}
     */
    static just_release = function(controller) {
        return gamepad_button_check_released(controller, value);
    }
}

/**
 * @param {Constant.GamepadButton} value
 * @param {Real} deadzone
 */
function ControllerTriggerAction(value, deadzone) constructor {
    self.value = value;
    self.deadzone = deadzone;

    /**
     * @param {Real}
     * @returns {Real}
     */
    static press = function(controller) {
        var v = gamepad_button_value(controller, value);
        if(v >= deadzone) return v;
        return 0;
    }
}

/**
 * @param {Constant.GamepadAxis} value
 * @param {Real} value
 * @param {Real} direction
 * @param {Real} deadzone
 */
function ControllerStickAction(value, direction, deadzone) constructor {
    self.value = value;
    self.deadzone = deadzone;
    self.direction = direction;

    /**
     * @param {Real}
     * @returns {Real}
     */
    static press = function(controller) {
        var v = gamepad_axis_value(controller, value);
        if(sign(v) != direction) return 0;
        v = abs(v);
        if(v <= deadzone) return 0;
        return v;
    }
}

enum CHECK_ACTION_TYPE {
	PRESS,
	JUST_PRESSED,
	JUST_RELEASED,
}

/**
 * @param {Array<Struct.KeyboardAction | Struct.ControllerButtonAction | Struct.ControllerTriggerAction | Struct.ControllerStickAction>} actions
 * @param {CHECK_ACTION_TYPE} type
 * @returns {Real}
 */
function CheckAction(actions, type = CHECK_ACTION_TYPE.PRESS) {
	for (var i = 0; i < array_length(actions); ++i) {
		var action = actions[i];
		if(is_instanceof(action, KeyboardAction)) {
            switch(type) {
                case CHECK_ACTION_TYPE.PRESS:
                    if(action.press()) return 1;
                    break;
                case CHECK_ACTION_TYPE.JUST_PRESSED:
                    if(action.just_pressed()) return 1;
                    break;
                case CHECK_ACTION_TYPE.JUST_RELEASED:
                    if(action.just_release()) return 1;
                    break;
            }
            continue;
        }

        var controller_count = gamepad_get_device_count();
        for(var c = 0; c < controller_count; ++c) {
            if(is_instanceof(action, ControllerButtonAction)) {
                switch(type) {
                    case CHECK_ACTION_TYPE.PRESS:
                        if(action.press(c)) return 1;
                        break;
                    case CHECK_ACTION_TYPE.JUST_PRESSED:
                        if(action.just_pressed(c)) return 1;
                        break;
                    case CHECK_ACTION_TYPE.JUST_RELEASED:
                        if(action.just_release(c)) return 1;
                        break;
                }
                continue;
            }

            var value = action.press(c);
            if(value > 0) return value;
        }
	}
	return 0;
}

/**
 * @param {Array<Struct.KeyboardAction | Struct.ControllerButtonAction | Struct.ControllerTriggerAction | Struct.ControllerStickAction>} action_left
 * @param {Array<Struct.KeyboardAction | Struct.ControllerButtonAction | Struct.ControllerTriggerAction | Struct.ControllerStickAction>} action_right
 * @param {Array<Struct.KeyboardAction | Struct.ControllerButtonAction | Struct.ControllerTriggerAction | Struct.ControllerStickAction>} action_up
 * @param {Array<Struct.KeyboardAction | Struct.ControllerButtonAction | Struct.ControllerTriggerAction | Struct.ControllerStickAction>} action_down
 */
function CheckAxis(action_left, action_right, action_up, action_down) {
    var horizontal = CheckAction(action_right) - CheckAction(action_left);
    var vertical = CheckAction(action_down) - CheckAction(action_up);

    var vec = new Vec2(horizontal, vertical);
    return vec.limit_length(0, 1);
	
}

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
