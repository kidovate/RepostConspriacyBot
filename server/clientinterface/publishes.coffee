
Meteor.startup ->
  Meteor.publish "commentstats", ()->
    return CommentQueue.find({}, {fields: {posted: 1}})
  Meteor.publish "poststats", ()->
    return ProcessedPosts.find({}, {fields: {id: 1}})