class ConvertInline
  class Error < StandardError; end
  # Your code goes here...

  attr_accessor :node, :insert, :attributes

  def initialize(node)
    @node       = node
    @insert     = @node['insert']
    @attributes = @node['attributes']
  end

  def convert
    return @insert if @insert.is_a?(String) && @attributes.nil?

    content = ''

    if @insert.is_a?(String)
      @attributes.keys.each { |attr| content += send(attr) }
    else
      content = @insert.keys.first == 'wk-image' ? image : embed(@insert.keys.first)
    end

    content
  end

  private

  def italic
    "<em>#{@insert}</em>"
  end

  def bold
    "<strong>#{@insert}</strong>"
  end

  def header
    "<h#{@attributes['header']}>#{@insert}</h#{@attributes['header']}>"
  end

  def blockquote
    "<blockquote>#{@insert}</blockquote>"
  end

  def link
    '<a href="' + @attributes['link'] + '" target="_blank">' + @insert + '</a>'
  end

  def list
    "<ul><li>#{@insert}</li></ul>"
  end

  def embed(key)
    return '<hr>' if key == 'wk-divider'

    '<div data-id="' + key + '" data-src="' + @insert[key] + '"></div>'
  end

  def image
    img_src    = @insert['wk-image']['src']
    img_cap    = @insert['wk-image']['caption']
    img_alt    = @attributes['alt']

    '<figure class="post-content-image-container">
      <img class="post-content-image lazy" data-src="' + img_src + '" alt="' + img_alt + '">
      <figcaption class="post-image-caption u-text-center">' + img_cap + '</figcaption>
    </figure>'
  end
end
