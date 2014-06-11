require 'rest_client'
require 'json'
require 'find'

response_const = RestClient.get "http://10.0.1.10:3000/api/v1/jenkins?name=iAddic7"
if (response_const != nil)

  File.open("/Users/wasappliserver/.jenkins/jobs/#{ARGV[0]}/workspace/#{ARGV[0]}/Constants.h", 'w') do |file|
    file << response_const
  end

end

response_loc = RestClient.get "http://10.0.1.10:3000/api/v1/localizables?name=iAddic7"
arr_json = JSON.parse(response_loc.to_s)

if (response_loc != nil)
  @path ="/Users/wasappliserver/.jenkins/jobs/#{ARGV[0]}/workspace/#{ARGV[0]}"
  lang_tab = Array.new

  #get all the langs for this project
  if (File.exist?(@path))
    Find.find(@path) do |path|
      if (path =~ /.*\.lproj$/)
        lang_tab << path
      end
    end
  end



  #for each lang:
  for i in 0..lang_tab.length-1
    el = lang_tab[i][/(\w+).lproj$/]
    el2 = el[/^(\w+)/]
    lang = el2
    puts "LANG IS ===>" + lang.to_s
    data = String.new

    File.open("/Users/wasappliserver/.jenkins/jobs/#{ARGV[0]}/workspace/#{ARGV[0]}/#{lang}.lproj/Localizable.strings", 'w') do |file|

      arr_json.each do |val|
        if (val["lang"] == lang)
          puts "lang is #{lang} and val lang is #{val["lang"]}"
          data << "\"#{val["key_loc"]}\" = \"#{val["value"]}\"\n"
        end
      end

      file << data
      data =nil
    end
  end
end

