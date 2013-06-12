# Main document with the control loop.
console.log "Initializing..."
reddit = Reddit

#=== Collections ===
@ProcessedPosts = new Meteor.Collection "processedposts" #format: id, title, score, numrepost
@CommentQueue = new Meteor.Collection "commentqueue" #Comments to post, format PostID and Text

#===Global Variables
@RequestCount = 0
@RequestHistory = []
@RequestLimit = 30
#LoopSuspended = false
@ProcessingPosts = false

#==Config==
@bot_username = "RepostConspiracyBot"
@bot_password = "S85FUBpTbIju"

#==Crons==
RequestLimitResetter = new Cron(60000)
RequestLimitResetter.addJob 1, ()->
  #console.log "Request count reset"+LoopSuspended
  @RequestCount = 0

CoreLoop = new Cron(1000)

LoginRefresher = new Cron(900000)
LoginRefresher.addJob 1, @RenewLoginCreds

###

Bot "Main loop"
Slight issue - wtf happens if the post speed is faster than the bot can process? D:
  1. Catalogue a list of all new posts since the last processed (use ProcessedPosts collection)
  2. Loop through this list oldest -> newest and check url using info:
    http://www.reddit.com/api/info.json?url=http://i.imgur.com/leWXamV.jpg
  2a. If there are reposts, construct the table and file it
  2b. Store it in the array ProcessedPosts
    Stable URL, ID, # Previous Posts, Date
###

Meteor.startup ->
  console.log "===== STARTING BOT ====="
  if not RenewLoginCreds()
    console.log "Login failed, we won't be able to post any comments..."
    @LoginModHash = null
    @LoginCookie = null
  BuildPostQueue()
  console.log "===== STARTING LOOP ===="
  mainLoop()

mainLoop = ()->
  try
    for time, i in @RequestHistory
      if time < (new Date().getTime())-60000
        @RequestHistory.splice(i, 1)
        @RequestCount = @RequestHistory.length
        #console.log "Popped request, count: "+@RequestCount

    if not @FetchingPosts and @RequestCount < @RequestLimit
      @ProcessPostQueue()
      @BuildPostQueue()
  catch error
    console.log "Error: "+EJSON.stringify error
    console.log "Recovering from error..."

  #This job will get called once after 1 second
  CoreLoop.addScheduleJob(Math.round((new Date()).getTime() / 1000) + 1, ()->
    mainLoop()
  )
