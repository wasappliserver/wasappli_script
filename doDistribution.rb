require_relative 'distribute.rb'
require 'json'

# Generic reading the config JSON file
#Open the .json file 
file = File.read("/Users/wasappliserver/.jenkins/jobs/"+ARGV[0]+"/workspace/distri_configs/"+ARGV[0]+".json")
arr_of_arrs = JSON.parse(file.to_s);
project_dir = ARGV[0]

arr_distri = arr_of_arrs["distribution"]
arr_info = arr_distri["distribution_info"]
arr_notif = arr_of_arrs["notification"]


if arr_distri["distribution_name"] == 'TestFlight'
# # # # # # FOR TESTFLIGHT # # # # # # #

# get variables
api_token = arr_info["api_token"]
team_token = arr_info["team_token"]
distribution_list = arr_info["distribution_list"]
#RELEASE NOTE
#!work in progress!#
release_note = arr_info["release _note"]

#call the distribution method
distributeToTestFlight(api_token,team_token,release_note,project_dir,distribution_list)
# # # # # # # # # # # # # # # # # # # # #

else if ARGV[1] == 'test'
  executePushes project_dir


else if arr_distri["distribution_name"] == 'HockeyApp'
# # # # # # # FOR HOCKEY APP # # # # # # # # 
hockeyapp_token = arr_of_arrs["hockeyapp_token"]
app_id = arr_of_arrs["app_id"]
release_note = arr_of_arrs["distribution_list"]

distributeToHockeyApp(hockeyapp_token,app_id,release_note,project_dir)

else
   warn 'distribution site wasnt specified !'
 end
end
end