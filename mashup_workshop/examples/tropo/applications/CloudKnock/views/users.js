{
   "_id": "_design/users",
   "language": "javascript",
   "views": {
       "checkedin": {
           "map": "function(doc) {\n  if(!doc.type) {\n\temit(doc._id, {'channel': doc.channel, 'network': doc.network});\n  }\n}"
       }
   }
}