ENV['REDIS_URL'] = 'redis://0.0.0.0:32768'

require 'lita-gamedev-spam'
require 'lita/rspec'

# A compatibility mode is provided for older plugins upgrading from Lita 3. Since this plugin
# was generated with Lita 4, the compatibility mode should be left disabled.
Lita.version_3_compatibility_mode = false
