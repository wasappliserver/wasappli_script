require 'rest_client'
require 'hockeyapp'

  #
  #TestFlight Upload
  #
  def distributeToTestFlight(api_token,team_token,release_note,project_dir,distribution_list)

    url = 'http://testflightapp.com/api/builds.json'
    dir_ipa = Dir["/Users/wasappliserver/.jenkins/jobs/"+project_dir+"/builds/*.ipa"]
    dir_dsym = Dir["/Users/wasappliserver/.jenkins/jobs/"+project_dir+"/builds/*-dSYM.zip"]
    puts "sending the request to TestFlight"
    
    RestClient.post url,
        {
          :file => File.new(dir_ipa[0],'rb'),
          :dsym => File.new(dir_dsym[0],'rb'),
          :api_token => api_token,
          :team_token => team_token,
          :notes => release_note,
          :notify => 'false',
          :distribution_lists => distribution_list
        } 
      executePushes project_dir
  end

  #
  #HockeyApp Upload
  #
  def distributeToHockeyApp(hockeyapp_token,app_id,release_note,project_dir)
    
    url = 'https://rink.hockeyapp.net/api/2/apps/' + app_id + '/app_versions/upload'
    dir_ipa = Dir["/Users/wasappliserver/.jenkins/jobs/" + project_dir + "/builds/*.ipa"]
    dir_dsym = Dir["/Users/wasappliserver/.jenkins/jobs/" + project_dir + "/builds/*-dSYM.zip"]
    puts "sending the request to HockeyApp"
    
    RestClient.post url, 
        {
          :header => 'X-HockeyAppToken:' + hockeyapp_token,
          :ipa => File.new(dir_ipa[0],'rb'),
          :dsym => File.new(dir_dsym[0],'rb'),
          :notes => release_note,
          :notify => '0',
          :status => '1'
        }
        #launch pushes
        executePushes project_dir
    end
    
    #
    # Manage Push
    #
    def executePushes project_dir
      url= 'https://new.boxcar.io/api/notifications'
     
      title = 'Build notification'
      long_message = '<b>Some text or HTML for the full layout page notification</b>'
      sound = 'success'
      
      # get the infos from JSON file
      #!In construction!#
      file = File.read("/Users/wasappliserver/.jenkins/jobs/" + project_dir + "/workspace/distri_configs/" +             project_dir + ".json")
      #arr_of_arrs = JSON.parse(file.to_s);
      
      #user_credentials = arr_of_arrs["user_credentials"]
      #title = arr_of_arrs["title"]
      #long_message = arr_of_arrs["long_message"]

      user_credentials = 'fV1xb1AcG7S6KeRtO1W'
      title = 'push test'
      long_message = '<b>Some text or HTML for the full layout page notification</b>'
      sound = 'success'
      sendPush user_credentials,title,long_message,sound,url
    end
    
    #
    # Push notifications
    #
    def sendPush (user_credentials,title,long_message,sound,url)
      
      RestClient.post url, 
          {
            :user_credentials => user_credentials,
            :notification => { 
              :title => title,
              :long_message => long_message,
              :sound => sound
            }
          }
    end
      