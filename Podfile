platform :osx, '10.12'
use_frameworks!


def development_pods
    pod 'BlueSocket'
end

def testing_pods
    pod 'Nimble'
end

target 'homekit-emulator' do
    development_pods
end

target 'homekit-emulatorTests' do
    development_pods
    testing_pods
end
