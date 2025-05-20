#!/usr/bin/env ruby

require 'html-proofer'

begin
  puts "Starting HTML-Proofer checks..."
  
  # Get HTML-Proofer version if available
  if HTMLProofer.const_defined?(:VERSION)
    puts "Using HTML-Proofer version: #{HTMLProofer::VERSION}"
  else
    puts "HTML-Proofer version not available"
  end

  options = {
    :disable_external => true,
    :ignore_urls => [
      %r{^http://127\.0\.0\.1},
      %r{^http://0\.0\.0\.0},
      %r{^http://localhost},
      %r{^/Sirloin_Vault/}
    ]
  }

  # Use the legacy API for maximum compatibility
  proofer = HTMLProofer.check_directory("./_site", options)
  proofer.run
  
  puts "HTML-Proofer checks passed successfully!"
  exit 0
rescue => e
  puts "Error running HTML-Proofer: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end 