@LoginModHash = null
@LoginCookie = null
LoginRescheduler = new Cron(1000)

@RenewLoginCreds = ()->
  console.log "Posting login credentials..."
  result = Meteor.http.post("https://ssl.reddit.com/api/login", {params: {api_type: "json", user: bot_username, passwd: bot_password, rem:true}})

  resultData = result.data.json
  #Check errors
  if result.statusCode isnt 200 or resultData.errors.length isnt 0
    console.log "Error logging in! "+resultData.errors[0][1]
    if resultData.errors[0][0] is "RATELIMIT"
      console.log "Rate limit reached on login, rescheduling in 30 seconds."
      LoginRescheduler.addScheduleJob(Math.round((new Date()).getTime() / 1000) + 30, RenewLoginCreds)
    return false

  @LoginModHash = resultData.data.modhash
  @LoginCookie = resultData.data.cookie
  cookieResponseParts = @LoginCookie.split(",")
  @LoginCookie = "reddit_session="+@LoginCookie

  console.log "Logged in! "+EJSON.stringify resultData

  return true