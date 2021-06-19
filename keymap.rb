# Wait until Keyboard class is ready
while !$mutex
  relinquish
end

# Initialize a Keyboard
kbd = Keyboard.new

# `split=` should happen before `init_pins`
kbd.split = true

# If your right hand the "anchor"
# kbd.set_anchor(:right)

# Initialize GPIO assign
#   Assuming you'er using a Sparkfun Pro Micro RP2040
kbd.init_pins(
  [ 4, 5, 6, 7, 8 ],             # row0, row1,... respectively
  [ 29, 28, 27, 26, 22, 20, 23 ] # col0, col1,... respectively
)

# default layer should be added at first
kbd.add_layer :default, %i[
  KC_F1     KC_F2   KC_F3   KC_F4       KC_F5     KC_F6    KC_NO  KC_NO   KC_F7     KC_F8     KC_F9     KC_F10   KC_F11    KC_F12
  KC_ESCAPE KC_Q    KC_W    KC_E        KC_R      KC_T     KC_NO  KC_NO   KC_Y      KC_U      KC_I      KC_O     KC_P      KC_MINUS
  KC_TAB    KC_A    KC_S    KC_D        KC_F      KC_G     KC_NO  KC_NO   KC_H      KC_J      KC_K      KC_L     KC_SCOLON KC_BSPACE
  KC_LSFT   KC_Z    KC_X    KC_C        KC_V      KC_B     KC_NO  KC_NO   KC_N      KC_M      KC_COMMA  KC_DOT   KC_SLASH  KC_RSFT
  KC_NO     KC_NO   KC_NO   ALT_AT      CTL_EQ  LOWER_SPC  KC_AT  KC_UNDS RAISE_ENT SPC_CTL   KC_RGUI  KC_NO     KC_NO     KC_NO
]
kbd.add_layer :raise, %i[
  KC_F1     KC_F2   KC_F3   KC_F4       KC_F5     KC_F6    KC_NO  KC_NO   KC_F7     KC_F8     KC_F9     KC_F10   KC_F11    KC_F12
  KC_GRAVE  KC_EXLM KC_AT   KC_HASH     KC_DLR    KC_PERC  KC_NO  KC_NO   KC_CIRC   KC_AMPR   KC_ASTER  KC_LPRN  KC_RPRN   KC_MIUNS
  KC_TAB    KC_LABK KC_LCBR KC_LBRACKET KC_LPRN   KC_QUOTE KC_NO  KC_NO   KC_LEFT   KC_DOWN   KC_UP     KC_RIGHT KC_UNDS   KC_PIPE
  KC_LSFT   KC_RABK KC_RCBR KC_RBRACKET KC_RPRN   KC_DQUO  KC_NO  KC_NO   KC_TILD   KC_BSLASH KC_COMMA  KC_DOT   KC_SLASH  KC_RSFT
  KC_NO     KC_NO   KC_NO   ALT_AT      CTL_EQ  LOWER_SPC  KC_AT  KC_UNDS RAISE_ENT SPC_CTL   KC_RGUI  KC_NO     KC_NO     KC_NO
]
kbd.add_layer :lower, %i[
  KC_F1     KC_F2   $C_F3   KC_F4       KC_F5     KC_F6    KC_NO  KC_NO   KC_F7     KC_F8     KC_F9     KC_F10   KC_F11    KC_F12
  KC_ESCAPE KC_1    KC_2    KC_3        KC_4      KC_5     KC_NO  KC_NO   KC_6      KC_7      KC_8      KC_9     KC_0      KC_MIUNS
  KC_TAB    KC_F2   KC_F10  KC_F12      KC_LPRN   KC_QUOTE KC_NO  KC_NO   KC_DOT    KC_4      KC_5      KC_6     KC_PLUS   KC_BSPACE
  KC_LSFT   KC_RABK KC_RCBR KC_RBRACKET KC_RPRN   KC_DQUO  KC_NO  KC_NO   KC_0      KC_1      KC_2      KC_3     KC_SLASH  KC_COMMA
  KC_NO     KC_NO   KC_NO   ALT_AT      CTL_EQ  LOWER_SPC  KC_AT  KC_UNDS RAISE_ENT SPC_CTL   KC_RGUI  KC_NO     KC_NO     KC_NO
]
#
#                   Your custom     Keycode or             Keycode (only modifiers)      Release time      Re-push time
#                   key name        Array of Keycode       or Layer Symbol to be held    threshold(ms)     threshold(ms)
#                                   or Proc                or Proc which will run        to consider as    to consider as
#                                   when you click         while you keep press          `click the key`   `hold the key`
kbd.define_mode_key :ALT_AT,      [ :KC_AT,                :KC_LALT,                     150,              150 ]
kbd.define_mode_key :CTL_EQ,      [ :KC_EQUAL,             :KC_LCTL,                     150,              150 ]
kbd.define_mode_key :SPC_CTL,     [ %i(KC_SPACE KC_RCTL),  :KC_RCTL,                     150,              150 ]
kbd.define_mode_key :RAISE_ENT,   [ :KC_ENTER,             :raise,                       150,              150 ]
kbd.define_mode_key :LOWER_SPC,   [ :KC_SPACE,             :lower,                       150,              150 ]

# `before_report` will work just right before reporting what keys are pushed to USB host.
# You can use it to hack data by adding an instance method to Keyboard class by yourself.
# ex) Use Keyboard#before_report filter if you want to input `":" w/o shift` and `";" w/ shift`
#kbd.before_report do
#  kbd.invert_sft if kbd.keys_include?(:KC_SCOLON)
#  # You'll be also able to write `invert_ctl`, `invert_alt` and `invert_gui`
#end

# Initialize RGB class with pin, underglow_size, backlight_size and is_rgbw.
rgb = RGB.new(
  0,    # pin number
  0,    # size of underglow pixel
  32,   # size of backlight pixel
  false # 32bit data will be sent to a pixel if true while 24bit if false
)
# Set an effect
#  `nil` or `:off` for turning off, `:breathing` for "color breathing", `:rainbow` for "rainbow snaking"
rgb.effect = :rainbow
# Set an action when you input
#  `nil` or `:off` for turning off
#rgb.action = :thunder
# Append the feature. Will possibly be able to write `Keyboard#append(OLED.new)` in the future
kbd.append rgb

# Initialize RotaryEncoder with pin_a and pin_b
encoder_left = RotaryEncoder.new(21, 9)
encoder_left.configure :left
# These implementations are still ad-hoc
encoder_left.clockwise do
  kbd.send_key :KC_PGDOWN
end
encoder_left.counterclockwise do
  kbd.send_key :KC_PGUP
end
kbd.append encoder_left

encoder_right = RotaryEncoder.new(21, 9)
encoder_right.configure :right
# These implementations are still ad-hoc
encoder_right.clockwise do
  kbd.send_key :KC_DOWN
end
encoder_right.counterclockwise do
  kbd.send_key :KC_UP
end
kbd.append encoder_right

kbd.start!
