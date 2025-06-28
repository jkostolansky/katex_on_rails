# frozen_string_literal: true

require 'katex_on_rails/version'
require 'katex_on_rails/package'

class KatexOnRails
  def render_to_string(text, options = {})
    katex_package.render_to_string(text, options)
  end

  private

  def katex_package
    @katex_package ||= Package.new
  end
end
