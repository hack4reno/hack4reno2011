{
   "_id": "_design/channel",
   "language": "javascript",
   "views": {
       "pstn": {
           "map": "function(doc) {\n  if(doc.type == 'user') {\n    if(doc.pstn) {\n\temit(doc._id, {'name':doc.name, 'address':doc.pstn})\n      }\n  }\n}"
       },
       "sip": {
           "map": "function(doc) {\n  if(doc.type == 'user') {\n    if(doc.sip) {\n\temit(doc._id, {'name':doc.name, 'address':doc.sip})\n    }\n    else if(doc.pstn) {\n\temit(doc._id, {'name':doc.name, 'address':doc.pstn})\n    } \n}\n}"
       },
       "skype": {
           "map": "function(doc) {\n  if(doc.type == 'user') {\n    if(doc.skype) {\n\temit(doc._id, {'name':doc.name, 'address':doc.skype})\n      }\n  }\n}"
       },
       "aim": {
           "map": "function(doc) {\n  if(doc.type == 'user') {\n    if(doc.aim) {\n\temit(doc._id, {'name':doc.name, 'address':doc.aim})\n      }\n  }\n}"
       },
       "gtalk": {
           "map": "function(doc) {\n  if(doc.type == 'user') {\n    if(doc.gtalk) {\n\temit(doc._id, {'name':doc.name, 'address':doc.gtalk})\n      }\n  }\n}"
       },
       "jabber": {
           "map": "function(doc) {\n  if(doc.type == 'user') {\n    if(doc.jabber) {\n\temit(doc._id, {'name':doc.name, 'address':doc.jabber})\n      }\n  }\n}"
       },
       "msn": {
           "map": "function(doc) {\n  if(doc.type == 'user') {\n    if(doc.msn) {\n\temit(doc._id, {'name':doc.name, 'address':doc.msn})\n      }\n  }\n}"
       },
       "sms": {
           "map": "function(doc) {\n  if(doc.type == 'user') {\n    if(doc.sms) {\n\temit(doc._id, {'name':doc.name, 'address':doc.sms})\n      }\n  }\n}"
       },
       "twitter": {
           "map": "function(doc) {\n  if(doc.type == 'user') {\n    if(doc.twitter) {\n\temit(doc._id, {'name':doc.name, 'address':doc.twitter})\n      }\n  }\n}"
       },
       "yahoo": {
           "map": "function(doc) {\n  if(doc.type == 'user') {\n    if(doc.yahoo) {\n\temit(doc._id, {'name':doc.name, 'address':doc.yahoo})\n      }\n  }\n}"
       }
   }
}