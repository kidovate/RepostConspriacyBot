@CommentQueue = new Meteor.Collection "commentqueue" #Comments to post, format PostID and Text
@ProcessedPosts = new Meteor.Collection "processedposts" #format: id, title, score, numrepost

Meteor.startup ->
  Meteor.subscribe "commentstats"
  Meteor.subscribe "poststats"

Template.statistics.commentCountFirstDigit = ->
  return (""+CommentQueue.find().count())[0]
Template.statistics.commentCountSecondDigit = ->
  return (""+CommentQueue.find().count())[1]
Template.statistics.commentCountThirdDigit = ->
  count = CommentQueue.find().count()
  if count > 99
    return (""+CommentQueue.find().count())[2]
  else
    return ""

Template.statistics.postCountFirstDigit = ->
  return (""+ProcessedPosts.find().count())[0]
Template.statistics.postCountSecondDigit = ->
  return (""+ProcessedPosts.find().count())[1]
Template.statistics.postCountThirdDigit = ->
  count = ProcessedPosts.find().count()
  if count > 99
    return (""+ProcessedPosts.find().count())[2]
  else
    return ""