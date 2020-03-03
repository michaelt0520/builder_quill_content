require "builder_quill_content/version"
require "json"

module BuilderQuillContent
  class Error < StandardError; end
  # Your code goes here...

  EMBED_KEYS = %w[wk-image wk-youtube wk-tweet wk-instagram wk-divider waku-post wk-maps].freeze

  def to_html(input)
    content_json = JSON.parse(input)
    line = content = ''

    while content_json.length.positive?
      node = content_json.shift

      if node['insert'] == "\n"
        content, line = end_of_line(content, line, node['attributes'])
      elsif node['insert'].include?("\n")
        content, line = break_line(content, line, node['insert'])
      else
        content, line = inline(content, line, node)
      end
    end

    content.gsub('</ul><ul>', '')
  rescue JSON::ParserError
    'No content'
  end

  def end_of_line(content, line, attributes)
    content += attributes.nil? ? "<p>#{line}</p>" : ConvertInline.new('insert' => line, 'attributes' => attributes).convert
    [content, '']
  end

  def break_line(content, line, insert)
    insert.split(/(?<=\n)/).each do |text|
      if text.end_with?("\n")
        content += "<p>#{line}#{text.delete("\n")}</p>"
        line = ''
      else
        line += text
      end
    end
    [content, line]
  end

  def inline(content, line, node)
    return [content + ConvertInline.new(node).convert, line] if embed_node?(node)

    [content, line + ConvertInline.new(node).convert]
  end

  def embed_node?(node)
    return false if node['insert'].is_a?(String)
    return false unless node['insert'].keys.find { |k| EMBED_KEYS.include?(k) }

    true
  end
end
