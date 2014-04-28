require 'rest_client'
require 'hockeyapp'
require 'unirest'
require 'maruku'

@filejson = nil
@fileMd = nil
#
#TestFlight Upload
#
def distributeToTestFlight(api_token, team_token, distribution_list)


  url = 'http://testflightapp.com/api/builds.json'
  dir_ipa = Dir["/Users/wasappliserver/.jenkins/jobs/#{@project_dir}/builds/*.ipa"]
  dir_dsym = Dir["/Users/wasappliserver/.jenkins/jobs/#{@project_dir}/builds/*-dSYM.zip"]
  puts "sending the request to TestFlight"

  RestClient.post url,
                  {
                      :file => File.new(dir_ipa[0], 'rb'),
                      :dsym => File.new(dir_dsym[0], 'rb'),
                      :api_token => api_token,
                      :team_token => team_token,
                      :notes => @release_note,
                      :notify => 'false',
                      :distribution_lists => distribution_list
                  }
  executePushes "success", ""
end

#
#HockeyApp Upload
#
def distributeToHockeyApp(hockeyapp_token, app_id)

  url = "https://rink.hockeyapp.net/api/2/apps/#{app_id}/app_versions/upload"
  dir_ipa = Dir["/Users/wasappliserver/.jenkins/jobs/#{@project_dir}/builds/*.ipa"]
  dir_dsym = Dir["/Users/wasappliserver/.jenkins/jobs/#{@project_dir}/builds/*-dSYM.zip"]
  puts "sending the request to HockeyApp"

  RestClient.post url,
                  {
                      :header => "X-HockeyAppToken:#{hockeyapp_token}",
                      :ipa => File.new(dir_ipa[0], 'rb'),
                      :dsym => File.new(dir_dsym[0], 'rb'),
                      :notes => @release_note,
                      :notify => '0',
                      :status => '1'
                  }
  #launch pushes
  executePushes "success", ""
end

#
# Manage Push
#
def executePushes build_status, error_msg

  # get the infos from JSON file
  arr_of_arrs = JSON.parse(@filejson.to_s)

  push_app_list = arr_of_arrs["notification"]
  user_box_car = push_app_list["BoxCar_tokens"]
  user_push_co = push_app_list["PushCo_tokens"]

  if build_status == "success"
    title = "Build success"
    long_message = @release_note
  elsif build_status == "failed"
    title = "Build failed"
    long_message = "#{error_msg}"
  end

### BoxCar ###
  dev_box_car = user_box_car["Devs"]
#clients_box_car = user_box_car["Clients"]
#Devs
  for i in 0..dev_box_car.length-1
    user_credentials = dev_box_car[i]
    sendPushCar user_credentials, title, long_message
  end

#Clients
#for i in 0..clients_box_car.length-1
#  user_credentials = clients_box_car[i]
# sendPushCar user_credentials, title, long_message, url
#end
### end BoxCar ###

### Push.co ###
#if build_status == "success"
  if build_status == "success"
    message = @release_note
  elsif build_status == "failed"
    message = "#{error_msg}"
  end
#clients_push_co = user_push_co["Clients"]
#All
  api_key = user_push_co["api_key"]
  api_secret = user_push_co["api_secret"]
  message = @release_note
  sendPushCo api_key, api_secret, message
  #end
  ### end Push.co ###

end

#
# Push notifications for BoxCar
#
def sendPushCar (user_credentials, title, long_message)
  url= 'https://new.boxcar.io/api/notifications'
  doc = Maruku.new(long_message)

  RestClient.post url,
                  {
                      :user_credentials => user_credentials,
                      :notification => {
                          :title => title,
                          :long_message => doc.to_html,
                          :sound => "success",
                      }
                  }
end

#
# Push notifications for Push.co
#
def sendPushCo (api_key, api_secret, message)
  url = "https://api.push.co/1.0/push"
  response = Unirest::post url,
                           parameters: {
                               "message" => message,
                               "api_key" => api_key,
                               "api_secret" => api_secret
                           }

end

#reading the config JSON file
#Open the .json file
def readFileJson
  @filejson = File.read("/Users/wasappliserver/.jenkins/jobs/#{ARGV[0]}/workspace/Release/#{ARGV[0]}.json")
end

#reading the release Markdown file
#Open the .json file
def readFileMd
  @fileMd = File.read("/Users/wasappliserver/.jenkins/jobs/#{ARGV[0]}/workspace/Release/#{ARGV[0]}.md")
  puts @fileMd
end
