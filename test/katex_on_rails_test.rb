# frozen_string_literal: true

require 'test_helper'

class KatexOnRailsTest < Minitest::Test
  def test_render_to_string
    expected_html = <<~HTML.gsub(/\n\s*/, '')
      <span class="katex-display">
        <span class="katex">
          <span class="katex-html" aria-hidden="true">
            <span class="base">
              <span class="strut" style="height:0.4306em;"></span>
              <span class="mord mathnormal">x</span>
            </span>
          </span>
        </span>
      </span>
    HTML

    assert_equal expected_html, KatexOnRails.new.render_to_string(
      'x', { output: 'html', displayMode: true, throwOnError: true }
    )
  end
end
