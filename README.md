# KaTeX on Rails

Convert LaTeX math formulas to HTML using KaTeX in Rails.

KaTeX on Rails uses [Nodo](https://github.com/mtgrosser/nodo)
to call the [KaTex](https://katex.org) Node.js package.

## Installation

Add the KaTeX on Rails gem:

```sh
bundle add katex_on_rails
```

Or add this line to your Gemfile manually:

```ruby
gem 'katex_on_rails'
```

Install the `katex` package with `npm`:

```sh
npm install katex
```

Or with `yarn`:
```sh
yarn add katex
```

To render any HTML generated by this gem, you will need to link the CSS file
from the `katex` Node.js package, make the KaTeX font files available to the client,
and use the HTML5 doctype. See [browser usage](https://katex.org/docs/browser).
Note, however, that you do not need to include `katex.js` on the client.

## Configuration

The KaTeX on Rails initializer allows you to customize how KaTeX processes mathematical expressions.
You can specify which delimiters to recognize and which HTML tags to ignore during processing.

```ruby
# Using the default configuration:
katex = KatexOnRails.new

# Specifying a custom configuration:
katex = KatexOnRails.new(
  delimiters: [
    { left: '$$', right: '$$', display: true },
    { left: '$', right: '$', display: false }
  ],
  ignored_tags: %w[span]
)
```

### `delimiters` (`Array<Hash>`)

A list of delimiters to look for math expressions, processed in the specified order.
Each delimiter must be a Hash with the following keys:

* `left` (`String`) – The opening delimiter that starts the math expression.
* `right` (`String`) – The closing delimiter that ends the math expression.
* `display` (`Boolean`) – Whether to render in display mode (block) or inline mode.

Default delimiters:
```ruby
[
  { left: '$$', right: '$$', display: true },
  { left: '\(', right: '\)', display: false },
  { left: '\begin{equation}', right: '\end{equation}', display: true },
  { left: '\begin{align}', right: '\end{align}', display: true },
  { left: '\begin{alignat}', right: '\end{alignat}', display: true },
  { left: '\begin{gather}', right: '\end{gather}', display: true },
  { left: '\begin{CD}', right: '\end{CD}', display: true },
  { left: '\[', right: '\]', display: true }
]
```

If you want to support inline math via `$`, be sure to place it after `$$` in the array.
Otherwise, `$$` expressions will be incorrectly parsed as empty `$` expressions.

### `ignored_tags` (`Array<String>`)

A list of HTML tag names to skip when searching for math expressions.
Use this to prevent processing math-like content in code blocks, scripts, etc.

Default ignored tags:
```ruby
%w[script noscript style textarea pre code option]
```

## Usage

### `render_to_string`

This method takes a LaTeX math expression and converts it directly to an HTML fragment using KaTeX.

Example:

```ruby
katex.render_to_string('x', { output: 'html' })
# => "<span class=\"katex\">..."
```

Common rendering options are:
- `display_mode` (`Boolean`) – Render in display (block) mode or inline mode.
- `throw_on_error` (`Boolean`) – Throw an error on invalid LaTeX (default: true).
- `output` (`String`) – Output format (`html`, `mathml`, or `htmlAndMathml`).

All the supported options are listed in the [KaTeX documentation](https://katex.org/docs/options).

### `render_in_html`

This method processes an HTML string, automatically detecting and rendering all math expressions found in the HTML
based on the configured delimiters. It returns a Nokogiri document fragment that can be converted back to a string.

Common rendering options are:
- `throw_on_error` (`Boolean`) – Throw an error on invalid LaTeX (default: true).
- `output` (`String`) – Output format (`html`, `mathml`, or `htmlAndMathml`).

All the supported options are listed in the [KaTeX documentation](https://katex.org/docs/options).

Example:

```ruby
katex.render_in_html('<div>Formula: \(x^2\)</div>', { output: 'html' }).to_html
# => "<div>Formula: <span class=\"katex\">...</span></div>"
```

## License

The KaTeX on Rails gem is released under the [MIT License](https://opensource.org/licenses/MIT).
