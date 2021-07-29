require 'json'
require 'pathname'
require 'colored2' # dependency of CocoaPods

require_relative 'ios/autolinking_manager'

def use_expo_modules!(options = {})
  # When run from the Podfile, `self` points to Pod::Podfile object

  if @current_target_definition.autolinking_manager.present?
    Pod::UI.message 'Expo modules are already being used in this target definition'.red
    return
  end

  @current_target_definition.autolinking_manager = Expo::AutolinkingManager.new(self, @current_target_definition, options).use_expo_modules!
end

# This is enabled by default, but everyone can opt-out if needed.
$ExpoUseSwiftModules = true

def use_swift_modules!(use = true)
  $ExpoUseSwiftModules = use
end
