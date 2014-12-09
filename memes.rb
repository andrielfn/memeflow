require 'open-uri'
require 'json'
require 'uri'

query = ARGV.first

def item_xml(options = {})
  <<-ITEM
  <item arg="#{options[:arg]}" uid="#{options[:uid]}">
    <title>#{options[:title]}</title>
    <subtitle>#{options[:subtitle]}</subtitle>
    <icon>#{options[:path]}</icon>
  </item>
  ITEM
end

def meme_image(url)
  filename = File.basename(URI.parse(url).path)

  unless File.exists?("images/#{filename}")
    open("images/#{filename}", 'wb') do |file|
     file << open(url).read
    end
  end

  images_path = File.expand_path('../images', __FILE__)
  File.join(images_path, "#{filename}")
end

default_memes = JSON.parse(File.read('memes.json'))

if File.exists?("#{ENV['HOME']}/.memes")
  personal_memes = JSON.parse(File.read("#{ENV['HOME']}/.memes"))
end

memes = (personal_memes || []) + default_memes

items = memes.map do |item|
  if item['title'].match(/#{query}/i)
    item_xml({
      :arg => item["image"],
      :uid => item["image"],
      :path => meme_image(item["image"]),
      :title => item["title"],
      :subtitle => "Copy link to clipboard"
    })
  end
end.join

output = "<?xml version='1.0'?>\n<items>\n#{items}</items>"

puts output
