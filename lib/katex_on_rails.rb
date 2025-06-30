# frozen_string_literal: true

require 'nokogiri'

require 'katex_on_rails/package'
require 'katex_on_rails/version'

class KatexOnRails
  DELIMITERS = [
    { left: '$$', right: '$$', display: true },
    { left: '\(', right: '\)', display: false },
    { left: '\begin{equation}', right: '\end{equation}', display: true },
    { left: '\begin{align}', right: '\end{align}', display: true },
    { left: '\begin{alignat}', right: '\end{alignat}', display: true },
    { left: '\begin{gather}', right: '\end{gather}', display: true },
    { left: '\begin{CD}', right: '\end{CD}', display: true },
    { left: '\[', right: '\]', display: true }
  ].freeze

  IGNORED_TAGS = %w[script noscript style textarea pre code option].freeze

  # Initialize the KaTeX on Rails with the provided configuration.
  #
  # This initializer allows you to customize how KaTeX processes mathematical expressions
  # in your HTML content. You can specify which delimiters to recognize and which HTML
  # tags to ignore during processing.
  #
  # @param [Hash] configuration Custom KaTeX on Rails configuration options.
  # @option configuration [Array<Hash>] delimiters A list of delimiters to look for math.
  # @option configuration [Array<String>] ignored_tags A list of HTML tags to skip when searching for math.
  #
  # @return [KatexOnRails] The KaTeX on Rails instance.
  #
  # == Configuration Options
  #
  # === +:delimiters+ (Array<Hash>)
  #
  # A list of delimiters to look for math expressions, processed in the specified order.
  # Each delimiter must be a Hash with the following keys:
  #
  # * +:left+ (String):: The opening delimiter that starts the math expression.
  # * +:right+ (String):: The closing delimiter that ends the math expression.
  # * +:display+ (Boolean):: Whether to render in display mode (block) or inline mode.
  #
  # Default delimiters:
  #
  #   [
  #     { left: '$$', right: '$$', display: true },
  #     { left: '\(', right: '\)', display: false },
  #     { left: '\begin{equation}', right: '\end{equation}', display: true },
  #     { left: '\begin{align}', right: '\end{align}', display: true },
  #     { left: '\begin{alignat}', right: '\end{alignat}', display: true },
  #     { left: '\begin{gather}', right: '\end{gather}', display: true },
  #     { left: '\begin{CD}', right: '\end{CD}', display: true },
  #     { left: '\[', right: '\]', display: true }
  #   ]
  #
  # If you want to support inline math via +$+, be sure to place it after +$$+ in the array.
  # Otherwise, +$$+ expressions will be incorrectly parsed as empty +$+ expressions.
  #
  # === +:ignored_tags+ (Array<String>)
  #
  # A list of HTML tag names to skip when searching for math expressions.
  # Use this to prevent processing math-like content in code blocks, scripts, etc.
  #
  # Default ignored tags:
  #
  #   %w[script noscript style textarea pre code option]
  #
  # == Examples
  #
  # Usage with the default configuration:
  #
  #   katex = KatexOnRails.new
  #
  # Usage with a custom configuration:
  #
  #   katex = KatexOnRails.new(
  #     delimiters: [
  #       { left: '$$', right: '$$', display: true },
  #       { left: '$', right: '$', display: false }
  #     ],
  #     ignored_tags: %w[span]
  #   )
  #
  def initialize(**configuration)
    @delimiters = configuration.fetch(:delimiters, DELIMITERS)
    @ignored_tags = configuration.fetch(:ignored_tags, IGNORED_TAGS)
    @katex_package ||= Package.new
  end

  # Generate an HTML string of the rendered math expression.
  #
  # This method takes a LaTeX math expression and converts it directly to an HTML fragment using KaTeX.
  #
  # @param [String] expression The LaTeX math expression to render.
  # @param [Hash] options The KaTeX rendering options (see KaTeX documentation).
  #
  # @return [String] HTML string containing the rendered math.
  #
  # == Rendering Options
  #
  # Common options are:
  #
  # - +:display_mode+ (Boolean):: Render in display (block) mode or inline mode.
  # - +:throw_on_error+ (Boolean):: Throw an error on invalid LaTeX (default: true).
  # - +:output+ (String):: Output format ('html', 'mathml', or 'htmlAndMathml').
  #
  # All the supported options are listed in the {KaTeX documentation}[https://katex.org/docs/options].
  #
  # == Example
  #
  #   KatexOnRails.new.render_to_string('x', { output: 'html' })
  #   # => "<span class=\"katex\">..."
  #
  def render_to_string(expression, options = {})
    @katex_package.render_to_string(expression, options)
  end

  # Render all math expressions found within an HTML fragment.
  #
  # This method processes an HTML string, automatically detecting
  # and rendering any math expressions based on the configured delimiters.
  # It returns a Nokogiri document fragment that can be converted back to a string.
  #
  # @param [String] html_fragment The HTML content to process.
  # @param [Hash] options KaTeX rendering options.
  #
  # @return [Nokogiri::HTML5::DocumentFragment] Processed HTML with rendered math.
  #
  # == Rendering Options
  #
  # Common options are:
  #
  # - +:throw_on_error+ (Boolean):: Throw an error on invalid LaTeX (default: true).
  # - +:output+ (String):: Output format ('html', 'mathml', or 'htmlAndMathml').
  #
  # All the supported options are listed in the {KaTeX documentation}[https://katex.org/docs/options].
  #
  # == Examples
  #
  #   KatexOnRails.new.render_in_html('<div>Formula: \(x^2\)</div>', { output: 'html' }).to_html
  #   # => "<div>Formula: <span class=\"katex\">...</span></div>"
  #
  def render_in_html(html_fragment, options = {})
    html_fragment = html_fragment.to_html if html_fragment.respond_to?(:to_html)
    doc = Nokogiri::HTML5.fragment(html_fragment.to_s)

    @delimiters.each do |delimiter|
      delimiter_left = Regexp.escape(delimiter[:left].to_s)
      delimiter_right = Regexp.escape(delimiter[:right].to_s)
      math_regexp = /#{delimiter_left}(.*?)#{delimiter_right}/

      each_text_node(doc) do |current_node|
        content = current_node.content
        next unless math_regexp.match?(content)

        new_content = content.gsub(math_regexp) do |_match|
          render_to_string(
            ::Regexp.last_match(1),
            options.merge({ displayMode: delimiter[:display] })
          )
        end

        new_fragment = Nokogiri::HTML5.fragment(new_content)
        current_node.replace(new_fragment)
      end
    end

    doc
  end

  private

  def each_text_node(node, &)
    return if @ignored_tags.include?(node.name)

    node.children.each { |child| each_text_node(child, &) }

    yield node if node.text?
  end
end
