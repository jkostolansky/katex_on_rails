# frozen_string_literal: true

require 'test_helper'

class KatexOnRailsTest < Minitest::Test
  def test_render_to_string
    katex = KatexOnRails.new
    expected_fragment = katex_x_html(true)

    assert_equal expected_fragment, katex.render_to_string(
      'x', { output: 'html', displayMode: true, throwOnError: true }
    )
  end

  def test_render_in_html
    html_fragment = <<~HTML
      <div class="parent">
        <span class="before">Content before.</span>
        <span class="inline">\\(x\\)</span>
        <span class="display">\\[x\\]</span>
        <code class="ignored">\\(x\\)</code>
        <span class="after">Content after.</span>
      </div>
    HTML

    expected_html = <<~HTML
      <div class="parent">
        <span class="before">Content before.</span>
        <span class="inline">#{katex_x_html(false)}</span>
        <span class="display">#{katex_x_html(true)}</span>
        <code class="ignored">\\(x\\)</code>
        <span class="after">Content after.</span>
      </div>
    HTML

    katex = KatexOnRails.new

    result = katex.render_in_html(
      html_fragment, { output: 'html', throwOnError: true }
    )

    assert_instance_of Nokogiri::HTML5::DocumentFragment, result
    assert_equal expected_html, result.to_html
  end

  def test_render_in_html_with_custom_config
    html_fragment = <<~HTML
      <div>§§x§§</div>
      <div>\\[x\\]</div>
      <span>§§x§§</span>
    HTML

    expected_html = <<~HTML
      <div>#{katex_x_html(false)}</div>
      <div>\\[x\\]</div>
      <span>§§x§§</span>
    HTML

    katex = KatexOnRails.new(
      delimiters: [{ left: '§§', right: '§§', display: false }],
      ignored_tags: %w[span]
    )

    result = katex.render_in_html(
      html_fragment, { output: 'html', throwOnError: true }
    )

    assert_instance_of Nokogiri::HTML5::DocumentFragment, result
    assert_equal expected_html, result.to_html
  end

  private

  def katex_x_html(display_mode)
    html_fragment = <<~HTML.gsub(/\n\s*/, '')
      <span class="katex">
        <span class="katex-html" aria-hidden="true">
          <span class="base">
            <span class="strut" style="height:0.4306em;"></span>
            <span class="mord mathnormal">x</span>
          </span>
        </span>
      </span>
    HTML

    if display_mode
      html_fragment = <<~HTML.gsub(/\n\s*/, '')
        <span class="katex-display">
          #{html_fragment}
        </span>
      HTML
    end

    html_fragment
  end
end
