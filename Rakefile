# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project'

Motion::Project::App.setup do |app|
  app.development do
    app.codesign_certificate = ENV['DEVELOPMENT_CERTIFICATE_NAME']
    app.provisioning_profile = ENV['DEVELOPMENT_PROVISIONING_PROFILE_PATH']
  end

  app.release do
    app.codesign_certificate = ENV['RELEASE_CERTIFICATE_NAME']
    app.provisioning_profile = ENV['RELEASE_PROVISIONING_PROFILE_PATH']
  end

  app.name       = 'Custom Overlay'

  app.frameworks += %w(AssetsLibrary CoreGraphics)
end
