require 'html-proofer'

options = {
  disable_external: true,
  ignore_urls: [
    %r{^http://127\.0\.0\.1},
    %r{^http://0\.0\.0\.0},
    %r{^http://localhost},
    %r{^/Sirloin_Vault/}
  ]
}

HTMLProofer.check_directory("./_site", options).run 