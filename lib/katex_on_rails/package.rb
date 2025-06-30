# frozen_string_literal: true

require 'nodo'

class KatexOnRails
  class Package < ::Nodo::Core
    require :katex

    function :render_to_string, code: <<~JS
      (expression, options) => {
        return katex.renderToString(expression, options);
      }
    JS
  end
end
