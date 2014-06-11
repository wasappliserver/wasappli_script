#encoding utf-8
require_relative 'distribute.rb'
require 'json'

#error msg variable
error_msg = ""

#BEFORE DOING ANYTHING, COMPARING HASH OF FILES
# if !File.exists?("/Users/wasappliserver/Documents/Hash/hash#{ARGV[0]}")
#   File.new("/Users/wasappliserver/Documents/Hash/hash#{ARGV[0]}", "w+")
# else
#   hash_content= File.read("/Users/wasappliserver/Documents/Hash/hash#{ARGV[0]}")
# end
# # # # #

#read the file and get the json
readFileJson
arr_json = JSON.parse(@filejson.to_s)

#set project directory value
@project_dir = ARGV[0]

#Verification
# readFileMd
#puts @fileMd
# puts hash_content
# if @fileMd.to_s == hash_content.to_s
#   warn "Distribution aborted MD has no changes"
#   error_msg = "Distribution aborted MD has no changes"
#   executePushes "skipped", error_msg
#   exit
# end

#WRITE Hash In a file for future comparison
# def write_in_hash
#   File.new("/Users/wasappliserver/Documents/Hash/hash#{ARGV[0]}", "w+")
#   File.write("/Users/wasappliserver/Documents/Hash/hash#{ARGV[0]}", @fileMd)
# end

#Verif is ok; getting content from JSON
arr_distri = arr_json["distribution"]
arr_info = arr_distri["distribution_info"]
arr_notif = arr_json["notification"]

#RELEASE NOTE
readFileMd
if @fileMd.to_s == ""
  warn "Release file missing"
  error_msg = "No Release file found, or release file is empty"
  executePushes "failed", error_msg
  exit
else
  @release_note = @fileMd.to_s
end

if arr_distri["distribution_name"] == 'TestFlight'
# # # # # # FOR TESTFLIGHT # # # # # # #

# get variables
  if arr_info.has_key?("api_token")
    api_token = arr_info["api_token"]
  else
    error_msg = "api token is missing"
    puts error_msg
    # write_in_hash
    executePushes "failed", error_msg
    exit
  end

  if arr_info.has_key?("team_token")
    team_token = arr_info["team_token"]
  else
    error_msg = "team_token is missing"
    puts error_msg
    # write_in_hash
    executePushes "failed", error_msg
    exit
  end

  if arr_info.has_key?("distribution_list")
    distribution_list = arr_info["distribution_list"]
  else
    error_msg = "distribution_list is missing"
    puts error_msg
    # write_in_hash
    executePushes "failed", error_msg
    exit
  end
  #write_in_hash

  #call the distribution method
  distributeToTestFlight(api_token, team_token, distribution_list)
# # # # # # # # # # # # # # # # # # # # #

elsif arr_distri["distribution_name"] == 'HockeyApp'

# # # # # # # FOR HOCKEY APP # # # # # # # #
  if arr_json.has_key?("hockeyapp_token")
    hockeyapp_token = arr_info["hockeyapp_token"]
  else
    error_msg = "hockeyapp_token is missing"
    puts error_msg
    # write_in_hash
    executePushes "failed", error_msg
    exit
  end
  if arr_info.has_key?("app_id")
    app_id = arr_info["app_id"]
  else
    error_msg = "app_id is missing"
    puts error_msg
    # write_in_hash
    executePushes "failed", error_msg
    exit
  end

  #RELEASE NOTE
  #!work in progress!#
  release_note = arr_json["distribution_list"]

  #Distribution
  distributeToHockeyApp(hockeyapp_token, app_id)

else
  warn 'distribution site wasnt specified !'
  # write_in_hash
  exit
end