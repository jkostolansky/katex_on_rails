# frozen_string_literal: true

require 'nodo'

class KatexOnRails
  class Package < ::Nodo::Core
    require :katex

    function :render_to_string, code: <<~JS
      (text, options) => {
        return katex.renderToString(text, options);
      }
    JS
  end
end
