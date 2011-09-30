# Create a new Tropo Scripting API application and attached these two scripts to it for voice and sms messaging

# Attach this script to the voice token
#http://api.tropo.com/1.0/sessions?action=create&token=3d5eed33429706408efcc0e92307b044ba2ecb3c2e641f69f9179b54e9d04af908e583112195de9ec7b05b9e&phonenumber=14805551212&remindermessage=hello+world


message($remindermessage, {
    :to => $phonenumber,
    :channel => "VOICE"
})



# Attach this script to the SMS token
#http://api.tropo.com/1.0/sessions?action=create&token=848b6b17c6229844827847b381a4a7e25c72d0750ec751bc0d10072e58eaa12683b6ea0a8aa5e166ee7bfcc8&phonenumber=14805551212&remindermessage=hello+world

message($remindermessage, {
		:to => $phonenumber,
		:network => "SMS"
})