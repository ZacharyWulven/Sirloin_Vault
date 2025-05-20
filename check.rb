#!/usr/bin/env ruby

require 'html-proofer'

# Print out HTML-Proofer version for debugging
puts "Using HTML-Proofer version: #{HTMLProofer::VERSION}"

options = {
  :disable_external => true,
  :ignore_urls => [
    %r{^http://127\.0\.0\.1},
    %r{^http://0\.0\.0\.0},
    %r{^http://localhost},
    %r{^/Sirloin_Vault/}
  ]
}

begin
  HTMLProofer.check_directory("./_site", options).run
  puts "HTML-Proofer checks passed successfully!"
  exit 0
rescue => e
  puts "Error running HTML-Proofer: #{e.message}"
  exit 1
end 