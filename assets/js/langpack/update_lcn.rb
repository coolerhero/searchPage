#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'   
require 'json'
require 'gettext'
require 'tmpdir'
require 'fileutils'

include GetText

pot = <<-END
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\\n"
"Report-Msgid-Bugs-To: \\n"
"POT-Creation-Date: #{Time.now}\\n"
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n"
"Language-Team: LANGUAGE <LL@li.org>\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"

END

page = Nokogiri::HTML(open("index.html"))   

strings = Hash.new
page.xpath('//*[@lang="en"]').each do |t|
  next if t.name == 'html'
  text = t.text
  if text.empty?
    text = t.attribute('placeholder').to_s
    text = t.attribute('value').to_s if text.empty?
    next if text.empty?
  end
  strings[text] ||= []
  strings[text].push(t.line)
end

strings['Loading Page'] = [0]

strings.each_pair do |text, lines|
  pot += "#: "
  pot += lines.map { |l| "index.html:#{l}"}.join(' ')
  pot += "\n"
  pot += "msgid \"#{text}\"\n"
  pot += "msgstr \"\"\n"
  pot += "\n"
end

lcndir=ENV['MY_LCN_CHECKOUT'] || "/nowhere"
IO.popen("msgcat -F - -o #{lcndir}/50-pot/opensuse-search-page.pot", "w").puts(pot)

Dir.mktmpdir do |localedir|
    
  Dir.glob("#{lcndir}/*/po/opensuse-search-page.*.po").sort.each do |po|
    language = %r(.*/([^/]*)/po).match(po)[1]
    system("msgmerge -q -U #{po} #{lcndir}/50-pot/opensuse-search-page.pot")
    domain = "#{language}_landing"
    mofile="#{localedir}/#{language}/LC_MESSAGES/#{domain}.mo"
    GetText.locale = language
    FileUtils.mkpath("#{localedir}/#{language}/LC_MESSAGES")
    system("msgfmt -o #{mofile} #{po}")
    GetText.bindtextdomain(domain, path: localedir)
    GetText.textdomain(domain)
    translations={}
    strings.keys.sort.each do |string|
      next if string.empty?
      translation = gettext(string)
      translations[string] = gettext(string) if string != translation
    end
    next if translations.count < 2
    hash = {}
    hash['WARNING'] = 'Please see the README.md - this is generated'
    hash['token'] = translations
    open("assets/js/langpack/#{language}.json", "w") do |f|
      f.write(JSON.pretty_generate(hash))
    end
  end
end
