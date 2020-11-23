require File.expand_path("#{__dir__}/lib/elder_scrolls_plugin/version")
require 'date'

Gem::Specification.new do |s|
  s.name = 'elder_scrolls_plugin'
  s.version = ElderScrollsPlugin::VERSION
  s.date = Date.today.to_s
  s.authors = ['Muriel Salvan']
  s.email = ['muriel@x-aeon.com']
  s.summary = 'Elder Scrolls Plugin - Reading Bethesda\'s esp, esm and esl files'
  s.description = 'Library reading Bethesda\'s plugins files (.esp, .esm and .esl) files. Provides a simple API to access plugins\' data organized in chunks'
  s.homepage = 'https://github.com/Muriel-Salvan/elder_scrolls_plugin'
  s.license = 'BSD-4-Clause'

  s.files = Dir['{bin,lib,spec}/**/*']
  Dir['bin/**/*'].each do |exec_name|
    s.executables << File.basename(exec_name)
  end

  # Dependencies
  # Riffola to read RIFF files
  s.add_dependency 'riffola'
  # BinData to read binary data easily from strings
  s.add_dependency 'bindata'
  # For the executable to dump JSON diffs
  s.add_dependency 'json-diff'

  # Development dependencies (tests, debugging)
  # Test framework
  s.add_development_dependency 'rspec'
end
