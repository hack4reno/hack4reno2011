/*
Copyright 2007 Adobe Systems Incorporated

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

/*
 * The Bridge class, responsible for navigating AS instances
 */
function FABridge(target,bridgeName)
{
    this.target = target;
    this.remoteTypeCache = {};
    this.remoteInstanceCache = {};
    this.remoteFunctionCache = {};
    this.localFunctionCache = {};
    this.bridgeID = FABridge.nextBridgeID++;
    this.name = bridgeName;
    this.nextLocalFuncID = 0;
    FABridge.instances[this.name] = this;
    FABridge.idMap[this.bridgeID] = this;

    return this;
}

// type codes for packed values
FABridge.TYPE_ASINSTANCE =  1;
FABridge.TYPE_ASFUNCTION =  2;

FABridge.TYPE_JSFUNCTION =  3;
FABridge.TYPE_ANONYMOUS =   4;

FABridge.initCallbacks = {};
FABridge.userTypes = {};

FABridge.addToUserTypes = function()
{
	for (var i = 0; i < arguments.length; i++)
	{
		FABridge.userTypes[arguments[i]] = {
			'typeName': arguments[i], 
			'enriched': false
		};
	}
}

FABridge.argsToArray = function(args)
{
    var result = [];
    for (var i = 0; i < args.length; i++)
    {
        result[i] = args[i];
    }
    return result;
}

function instanceFactory(objID)
{
    this.fb_instance_id = objID;
    return this;
}

function FABridge__invokeJSFunction(args)
{  
    var funcID = args[0];
    var throughArgs = args.concat();//FABridge.argsToArray(arguments);
    throughArgs.shift();
   
    var bridge = FABridge.extractBridgeFromID(funcID);
    return bridge.invokeLocalFunction(funcID, throughArgs);
}

FABridge.addInitializationCallback = function(bridgeName, callback)
{
    var inst = FABridge.instances[bridgeName];
    if (inst != undefined)
    {
        callback.call(inst);
        return;
    }

    var callbackList = FABridge.initCallbacks[bridgeName];
    if(callbackList == null)
    {
        FABridge.initCallbacks[bridgeName] = callbackList = [];
    }

    callbackList.push(callback);
}

function FABridge__bridgeInitialized(bridgeName)
{
    var searchStr = "bridgeName="+ bridgeName;

    if (/Explorer/.test(navigator.appName) || /Netscape/.test(navigator.appName) || /Konqueror|Safari|KHTML/.test(navigator.appVersion))
    {

        var flashInstances = document.getElementsByTagName("object");
        if (flashInstances.length == 1)
        {
            FABridge.attachBridge(flashInstances[0], bridgeName);
        }
        else
        {
            for(var i = 0; i < flashInstances.length; i++)
            {
                var inst = flashInstances[i];
                var params = inst.childNodes;
                var flash_found = false;

                for (var j = 0; j < params.length; j++)
                {
                    var param = params[j];
                    if (param.nodeType == 1 && param.tagName.toLowerCase() == "param")
                    {
                        if (param["name"].toLowerCase() == "flashvars" && param["value"].indexOf(searchStr) >= 0)
                        {
                            FABridge.attachBridge(inst, bridgeName);
                            flash_found = true;
                            break;
                        }
                    }
                }

                if (flash_found) {
                    break;
                }
            }
        }
    }
    else
    {
        var flashInstances = document.getElementsByTagName("embed");
        if (flashInstances.length == 1)
        {
            FABridge.attachBridge(flashInstances[0], bridgeName);
        }
        else
        {
            for(var i = 0; i < flashInstances.length; i++)
            {
                var inst = flashInstances[i];
                var flashVars = inst.attributes.getNamedItem("flashVars").nodeValue;
                if (flashVars.indexOf(searchStr) >= 0)
                {
                    FABridge.attachBridge(inst, bridgeName);
                }

            }
        }
    }
    return true;
}

// used to track multiple bridge instances, since callbacks from AS are global across the page.

FABridge.nextBridgeID = 0;
FABridge.instances = {};
FABridge.idMap = {};
FABridge.refCount = 0;

FABridge.extractBridgeFromID = function(id)
{
    var bridgeID = (id >> 16);
    return FABridge.idMap[bridgeID];
}

FABridge.attachBridge = function(instance, bridgeName)
{
    var newBridgeInstance = new FABridge(instance, bridgeName);

    FABridge[bridgeName] = newBridgeInstance;

/*  FABridge[bridgeName] = function() {
        return newBridgeInstance.root();
    }
*/

    var callbacks = FABridge.initCallbacks[bridgeName];
    if (callbacks == null)
    {
        return;
    }
    for (var i = 0; i < callbacks.length; i++)
    {
        callbacks[i].call(newBridgeInstance);
    }
    delete FABridge.initCallbacks[bridgeName]
}

// some methods can't be proxied.  You can use the explicit get,set, and call methods if necessary.

FABridge.blockedMethods =
{
    toString: true,
    get: true,
    set: true,
    call: true
};

FABridge.prototype =
{


// bootstrapping

    root: function()
    {
        return this.deserialize(this.target.getRoot());
    },

    releaseASObjects: function()
    {
        return this.target.releaseASObjects();
    },

    releaseNamedASObject: function(value)
    {
        if(typeof(value) != "object")
        {
            return false;
        }
        else
        {
            var ret =  this.target.releaseNamedASObject(value.fb_instance_id);
            return ret;
        }
    },

    create: function(className)
    {
        return this.deserialize(this.target.create(className));
    },


    // utilities

    makeID: function(token)
    {
        return (this.bridgeID << 16) + token;
    },


    // low level access to the flash object

    getPropertyFromAS: function(objRef, propName)
    {
        if (FABridge.refCount > 0)
        {
            throw new Error("You are trying to call recursively into the Flash Player which is not allowed. In most cases the JavaScript setTimeout function, can be used as a workaround.");
        }
        else
        {
            FABridge.refCount++;
            retVal = this.target.getPropFromAS(objRef, propName);
            retVal = this.handleError(retVal);
            FABridge.refCount--;
            return retVal;
        }
    },

    setPropertyInAS: function(objRef,propName, value)
    {
        if (FABridge.refCount > 0)
        {
            throw new Error("You are trying to call recursively into the Flash Player which is not allowed. In most cases the JavaScript setTimeout function, can be used as a workaround.");
        }
        else
        {
            FABridge.refCount++;
            retVal = this.target.setPropInAS(objRef,propName, this.serialize(value));
            retVal = this.handleError(retVal);
            FABridge.refCount--;
            return retVal;
        }
    },

    callASFunction: function(funcID, args)
    {
        if (FABridge.refCount > 0)
        {
            throw new Error("You are trying to call recursively into the Flash Player which is not allowed. In most cases the JavaScript setTimeout function, can be used as a workaround.");
        }
        else
        {
            FABridge.refCount++;
            retVal = this.target.invokeASFunction(funcID, this.serialize(args));
            retVal = this.handleError(retVal);
            FABridge.refCount--;
            return retVal;
        }
    },

    callASMethod: function(objID, funcName, args)
    {
        if (FABridge.refCount > 0)
        {
            throw new Error("You are trying to call recursively into the Flash Player which is not allowed. In most cases the JavaScript setTimeout function, can be used as a workaround.");
        }
        else
        {
            FABridge.refCount++;
            args = this.serialize(args);
            retVal = this.target.invokeASMethod(objID, funcName, args);
            retVal = this.handleError(retVal);
            FABridge.refCount--;
            return retVal;
        }
    },

    // responders to remote calls from flash

    invokeLocalFunction: function(funcID, args)
    {
        var result;
        var func = this.localFunctionCache[funcID];

        if(func != undefined)
        {
            result = this.serialize(func.apply(null, this.deserialize(args)));
        }

        return result;
    },

    // Object Types and Proxies
	getUserTypeDescriptor: function(objTypeName)
	{
		var simpleType = objTypeName.replace(/^([^:]*)\:\:([^:]*)$/, "$2");
    	var isUserProto = ((typeof window[simpleType] == "function") && (typeof FABridge.userTypes[simpleType] != "undefined"));

    	var protoEnriched = false;
    	
    	if (isUserProto) {
	    	protoEnriched = FABridge.userTypes[simpleType].enriched;
    	}
    	var toret = {
    		'simpleType': simpleType, 
    		'isUserProto': isUserProto, 
    		'protoEnriched': protoEnriched
    	};
    	return toret;
	}, 
	
    // accepts an object reference, returns a type object matching the obj reference.
    getTypeFromName: function(objTypeName)
    {
    	var ut = this.getUserTypeDescriptor(objTypeName);
    	var toret = this.remoteTypeCache[objTypeName];
    	if (ut.isUserProto)
		{
    		//enrich both of the prototypes: the FABridge one, as well as the class in the page. 
	    	if (!ut.protoEnriched)
			{

		    	for (i in window[ut.simpleType].prototype)
				{
		    		toret[i] = window[ut.simpleType].prototype[i];
		    	}
				
				window[ut.simpleType].prototype = toret;
				this.remoteTypeCache[objTypeName] = toret;
				FABridge.userTypes[ut.simpleType].enriched = true;
	    	}
    	}
        return toret;
    },

    createProxy: function(objID, typeName)
    {
    	//get user created type, if it exists
    	var ut = this.getUserTypeDescriptor(typeName);

        var objType = this.getTypeFromName(typeName);

		if (ut.isUserProto)
		{
			var instFactory = window[ut.simpleType];
			var instance = new instFactory(this.name, objID);
			instance.fb_instance_id = objID;
		}
		else
		{
	        instanceFactory.prototype = objType;
	        var instance = new instanceFactory(objID);
		}

        this.remoteInstanceCache[objID] = instance;
        return instance;
    },

    getProxy: function(objID)
    {
        return this.remoteInstanceCache[objID];
    },

    // accepts a type structure, returns a constructed type
    addTypeDataToCache: function(typeData)
    {
        newType = new ASProxy(this, typeData.name);
        var accessors = typeData.accessors;
        for (var i = 0; i < accessors.length; i++)
        {
            this.addPropertyToType(newType, accessors[i]);
        }

        var methods = typeData.methods;
        for (var i = 0; i < methods.length; i++)
        {
            if (FABridge.blockedMethods[methods[i]] == undefined)
            {
                this.addMethodToType(newType, methods[i]);
            }
        }


        this.remoteTypeCache[newType.typeName] = newType;
        return newType;
    },

    addPropertyToType: function(ty, propName)
    {
        var c = propName.charAt(0);
        var setterName;
        var getterName;
        if(c >= "a" && c <= "z")
        {
            getterName = "get" + c.toUpperCase() + propName.substr(1);
            setterName = "set" + c.toUpperCase() + propName.substr(1);
        }
        else
        {
            getterName = "get" + propName;
            setterName = "set" + propName;
        }
        ty[setterName] = function(val)
        {
            this.bridge.setPropertyInAS(this.fb_instance_id, propName, val);
        }
        ty[getterName] = function()
        {
            return this.bridge.deserialize(this.bridge.getPropertyFromAS(this.fb_instance_id, propName));
        }
    },

    addMethodToType: function(ty, methodName)
    {
        ty[methodName] = function()
        {
            return this.bridge.deserialize(this.bridge.callASMethod(this.fb_instance_id, methodName, FABridge.argsToArray(arguments)));
        }
    },

    // Function Proxies

    getFunctionProxy: function(funcID)
    {
        var bridge = this;
        if (this.remoteFunctionCache[funcID] == null)
        {
            this.remoteFunctionCache[funcID] = function()
            {
                bridge.callASFunction(funcID, FABridge.argsToArray(arguments));
            }
        }
        return this.remoteFunctionCache[funcID];
    },

    getFunctionID: function(func)
    {
        if (func.__bridge_id__ == undefined)
        {
            func.__bridge_id__ = this.makeID(this.nextLocalFuncID++);
            this.localFunctionCache[func.__bridge_id__] = func;
        }
        return func.__bridge_id__;
    },

    // serialization / deserialization

    serialize: function(value)
    {
        var result = {};

        var t = typeof(value);
        if (t == "number" || t == "string" || t == "boolean" || t == null || t == undefined)
        {
            result = value;
        }
        else if (value instanceof Array)
        {
            result = [];
            for (var i = 0; i < value.length; i++)
            {
                result[i] = this.serialize(value[i]);
            }
        }
        else if (t == "function")
        {
            result.type = FABridge.TYPE_JSFUNCTION;
            result.value = this.getFunctionID(value);
        }
        else if (value instanceof ASProxy)
        {
            result.type = FABridge.TYPE_ASINSTANCE;
            result.value = value.fb_instance_id;
        }
        else
        {
            result.type = FABridge.TYPE_ANONYMOUS;
            result.value = value;
        }

        return result;
    },

    deserialize: function(packedValue)
    {

        var result;

        var t = typeof(packedValue);
        if (t == "number" || t == "string" || t == "boolean" || packedValue == null || packedValue == undefined)
        {
            result = this.handleError(packedValue);
            //if (typeof(retVal)=="string" && retVal.indexOf("__FLASHERROR")==0)
            //{
            //    throw new Error(retVal);
            //}
        }
        else if (packedValue instanceof Array)
        {
            result = [];
            for (var i = 0; i < packedValue.length; i++)
            {
                result[i] = this.deserialize(packedValue[i]);
            }
        }
        else if (t == "object")
        {
            for(var i = 0; i < packedValue.newTypes.length; i++)
            {
                this.addTypeDataToCache(packedValue.newTypes[i]);
            }
            for (var aRefID in packedValue.newRefs)
            {
                this.createProxy(aRefID, packedValue.newRefs[aRefID]);
            }
            if (packedValue.type == FABridge.TYPE_PRIMITIVE)
            {
                result = packedValue.value;
            }
            else if (packedValue.type == FABridge.TYPE_ASFUNCTION)
            {
                result = this.getFunctionProxy(packedValue.value);
            }
            else if (packedValue.type == FABridge.TYPE_ASINSTANCE)
            {
                result = this.getProxy(packedValue.value);
            }
            else if (packedValue.type == FABridge.TYPE_ANONYMOUS)
            {
                result = packedValue.value;
            }
        }
        return result;
    },

    addRef: function(obj)
    {
        this.target.incRef(obj.fb_instance_id);
    },

    release:function(obj)
    {
        this.target.releaseRef(obj.fb_instance_id);
    },

    handleError: function(value)
    {
        if (typeof(value)=="string" && value.indexOf("__FLASHERROR")==0)
        {
            var myErrorMessage = value.split("||");
            if(FABridge.refCount > 0 )
            {
                FABridge.refCount--;
            }
            throw new Error(myErrorMessage[1]);
            return value;
        }
        else
        {
            return value;
        }   
    }
};

// The root ASProxy class that facades a flash object

ASProxy = function(bridge, typeName)
{
    this.bridge = bridge;
    this.typeName = typeName;
    return this;
};

ASProxy.prototype =
{
    get: function(propName)
    {
        return this.bridge.deserialize(this.bridge.getPropertyFromAS(this.fb_instance_id, propName));
    },

    set: function(propName, value)
    {
        this.bridge.setPropertyInAS(this.fb_instance_id, propName, value);
    },

    call: function(funcName, args)
    {
        this.bridge.callASMethod(this.fb_instance_id, funcName, args);
    }, 
    
    addRef: function() {
        this.bridge.addRef(this);
    }, 
    
    release: function() {
        this.bridge.release(this);
    }
};

/*
 * jQuery Tools 1.2.2 - The missing UI library for the Web
 * 
 * [toolbox.flashembed]
 * 
 * NO COPYRIGHTS OR LICENSES. DO WHAT YOU LIKE.
 * 
 * http://flowplayer.org/tools/
 * 
 * File generated: Tue May 25 08:09:15 GMT 2010
 */
(function(){function f(a,b){if(b)for(key in b)if(b.hasOwnProperty(key))a[key]=b[key];return a}function l(a,b){var c=[];for(var d in a)if(a.hasOwnProperty(d))c[d]=b(a[d]);return c}function m(a,b,c){if(e.isSupported(b.version))a.innerHTML=e.getHTML(b,c);else if(b.expressInstall&&e.isSupported([6,65]))a.innerHTML=e.getHTML(f(b,{src:b.expressInstall}),{MMredirectURL:location.href,MMplayerType:"PlugIn",MMdoctitle:document.title});else{if(!a.innerHTML.replace(/\s/g,"")){a.innerHTML="<h2>Flash version "+
b.version+" or greater is required</h2><h3>"+(g[0]>0?"Your version is "+g:"You have no flash plugin installed")+"</h3>"+(a.tagName=="A"?"<p>Click here to download latest version</p>":"<p>Download latest version from <a href='"+k+"'>here</a></p>");if(a.tagName=="A")a.onclick=function(){location.href=k}}if(b.onFail){var d=b.onFail.call(this);if(typeof d=="string")a.innerHTML=d}}if(h)window[b.id]=document.getElementById(b.id);f(this,{getRoot:function(){return a},getOptions:function(){return b},getConf:function(){return c},
getApi:function(){return a.firstChild}})}var h=document.all,k="http://www.adobe.com/go/getflashplayer",n=typeof jQuery=="function",o=/(\d+)[^\d]+(\d+)[^\d]*(\d*)/,i={width:"100%",height:"100%",id:"_"+(""+Math.random()).slice(9),allowfullscreen:true,allowscriptaccess:"always",quality:"high",version:[3,0],onFail:null,expressInstall:null,w3c:false,cachebusting:false};window.attachEvent&&window.attachEvent("onbeforeunload",function(){__flash_unloadHandler=function(){};__flash_savedUnloadHandler=function(){}});
window.flashembed=function(a,b,c){if(typeof a=="string")a=document.getElementById(a.replace("#",""));if(a){if(typeof b=="string")b={src:b};return new m(a,f(f({},i),b),c)}};var e=f(window.flashembed,{conf:i,getVersion:function(){var a;try{a=navigator.plugins["Shockwave Flash"].description.slice(16)}catch(b){try{var c=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");a=c&&c.GetVariable("$version")}catch(d){}}return(a=o.exec(a))?[a[1],a[3]]:[0,0]},asString:function(a){if(a===null||a===undefined)return null;
var b=typeof a;if(b=="object"&&a.push)b="array";switch(b){case "string":a=a.replace(new RegExp('(["\\\\])',"g"),"\\$1");a=a.replace(/^\s?(\d+\.?\d+)%/,"$1pct");return'"'+a+'"';case "array":return"["+l(a,function(d){return e.asString(d)}).join(",")+"]";case "function":return'"function()"';case "object":b=[];for(var c in a)a.hasOwnProperty(c)&&b.push('"'+c+'":'+e.asString(a[c]));return"{"+b.join(",")+"}"}return String(a).replace(/\s/g," ").replace(/\'/g,'"')},getHTML:function(a,b){a=f({},a);var c='<object width="'+
a.width+'" height="'+a.height+'" id="'+a.id+'" name="'+a.id+'"';if(a.cachebusting)a.src+=(a.src.indexOf("?")!=-1?"&":"?")+Math.random();c+=a.w3c||!h?' data="'+a.src+'" type="application/x-shockwave-flash"':' classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"';c+=">";if(a.w3c||h)c+='<param name="movie" value="'+a.src+'" />';a.width=a.height=a.id=a.w3c=a.src=null;a.onFail=a.version=a.expressInstall=null;for(var d in a)if(a[d])c+='<param name="'+d+'" value="'+a[d]+'" />';a="";if(b){for(var j in b)if(b[j]){d=
b[j];a+=j+"="+(/function|object/.test(typeof d)?e.asString(d):d)+"&"}a=a.slice(0,-1);c+='<param name="flashvars" value=\''+a+"' />"}c+="</object>";return c},isSupported:function(a){return g[0]>a[0]||g[0]==a[0]&&g[1]>=a[1]}}),g=e.getVersion();if(n){jQuery.tools=jQuery.tools||{version:"1.2.2"};jQuery.tools.flashembed={conf:i};jQuery.fn.flashembed=function(a,b){return this.each(function(){$(this).data("flashembed",flashembed(this,a,b))})}}})();


(function($) {

    // UTILITY
    // ====================================================================================

	function isNull(check, def) {
		if(check==null) {
			return def;
		}
		else {
			return check;
		}
	}
	
    function wrap(config) {
        
        // Get Delegate
        var target = config.target;

        // Create delegate
        var delegate = {
			$flash: target,
			dispatcher:$({}),
			methods: config.methods,
			properties: config.properties,
			bind: function(name, listeners) {
				this.dispatcher.bind(name, listeners);
			},
			unbind: function(name, listeners) {
				this.dispatcher.unbind(name, listeners);
			}            
        };
        
        // Wire Methods
		$.each(config.methods, function(i, name) {
			delegate[name] = function() {
			    if(this.$flash == null) {
			        return;
			    }
			    var args = [];
			    for ( var i=0; i<arguments.length; i++ ) {
			        args.push(arguments[i]);
			    }
				return this.$flash.call(name, args);
			}
		});
		
        // Wire Properties
		$.each(config.properties, function(i, name) {
		    var readonly = name.match("^@") != null;
		    if(readonly == true) {
    		    name = name.substr(1);
		    }
			delegate[name] = function(value) {
			    if(this.$flash == null) {
			        return;
			    }
				if(arguments.length === 0) {
					return this.$flash.get(name);
				}
				else if(readonly===false){
					this.$flash.set(name, value);
				}
			}
		});
		
		delegate.apply = function(options) {
    		$.each(options, function(k,v) {
    			if(k.match("^on")) {
    				delegate.bind(k.substr(2).toLowerCase(), v);
    			}
    			else if(typeof delegate[k] == "function") {
    				delegate[k](v);
    			}
    			else {
    				delegate[k] = v;
    			}
    		});		
		};
		
		return delegate;
        
    }
    
    // FACTORY METHODS
    // ====================================================================================

	function wrapCall(phone, $flash, options) {

		var call = wrap({
		    target: $flash,
    		methods: ["answer","hangup","digit"],
    		properties : ["@to","@state","@id","talking","muted","hold","volume","pushToTalk"]
		})

		call.apply(options);

		if(options.hasOwnProperty("headers")) {
		    var headers = options.headers;
		    for(var headerName in headers) {
                if(headers.hasOwnProperty(headerName)) {
                    $flash.addHeader(headerName, headers[headerName]);
                }
            }
		}
		
		$flash.addEventListener(null, function(event) {
			var eventName = (event.getType()+"").toLowerCase();
	    	call.dispatcher.trigger($.extend({
	    	    call: call,
	    	    phone: phone,
	    	    reason: event.getReason()
	    	}, $.Event(eventName)),[call]);
		});	
		
		return call;
	}

    function wrapPhone(options) {

        options = $.extend({
            flashMovie: "phono-dev.swf"
        }, options)
        
		var phone = wrap({
		    target: null,
		    options: options,
		    methods: ["showFlashPermissionBox", "text", "connect", "disconnect", "verify", "reportIssue"],
		    properties: ["@state", "@connected", "@flashPermissionState", "@sessionId", "tones", "ringTone", "ringbackTone"]
		});

		phone = $.extend(phone, {
		    calls: {},
			dial: function(to, options) {
				options = isNull(options,{});
				options.to = to;
				var call = wrapCall(phone, phone.$flash.createCall(), options);
				phone.calls[call.id()] = call;
				call.$flash.setTo(to);
				call.$flash.start();
				return call;
			},
            flashEventListener: function(event) {
	    		var eventName = (event.getType()+"").toLowerCase();
            	var jsEvent = $.extend({
                    phone: phone,
                    reason: event.getReason()
                }, $.Event(eventName));
                
            	if(event["getCall"] != undefined) {
            	    var callId = event.getCall().getId();
            	    var call = phone.calls[callId];
            	    if(call == null) {
            	        call = wrapCall(phone, event.getCall(), {to:phone.sessionId});
            	        phone.calls[call.id()] = call;
            	    }
        		    jsEvent.call = call;
            	    phone.dispatcher.trigger(jsEvent,[jsEvent.call]);            		
            	}
            	else if(event["getMessage"] != undefined) {
        		    jsEvent.message = wrapMessage(event.getMessage());
            	    phone.dispatcher.trigger(jsEvent,[jsEvent.message]);            		
            	}
            	else {
            	    phone.dispatcher.trigger(jsEvent,[phone]);            		
            	}
	    	}			
		});       
		
		return phone; 
		
    }

	function wrapMessage(message) {
		return {
			from:message.getFrom(),
			body:message.getBody(),
			reply: function(body) {
				message.reply(body);
			}
		};
	}

    // MAIN JQUERY PLUGIN
    // ====================================================================================

	jQuery.phono = function(options) {

        if(!options.flashMovie) {
            throw "flashMovie option is required";
        }
		
        var phone = wrapPhone(options);
		var bridgeId = options.flashElementId;
		
		// Create Flash DIV is none was specified		
        if (!bridgeId){
	        
	        var flashDivNum = $(".phono_FlashHolder").size() + 1;
	        var flashDiv = $("<div>")
	        	.attr("id","_flash" + flashDivNum)
	        	.addClass("phono_FlashHolder")
	        	.appendTo("body");
	        	
	        if($.browser.msie){
	        	flashDiv.css({
	        		"width":"1px",
	        		"height":"1px",
	        		"position":"absolute",
	        		"top":"50%",
	        		"left":"50%",
	        		"margin-top":"-69px",
	        		"margin-left":"-107px",
	        		"z-index":"10001",
	        		"visibility":"visible"
	        	})
	        }else{
	        	flashDiv.css({
	        		"width":"215px",
	        		"height":"138px",
	        		"position":"absolute",
	        		"top":"50%",
	        		"left":"50%",
	        		"margin-top":"-69px",
	        		"margin-left":"-107px",
	        		"z-index":"10001",
	        		"visibility":"hidden"
	        	})
	        }
	        
	        bridgeId = $(flashDiv).attr("id");
	        
	        phone.bind({
	        	flashpermissionshow: function() {
					$("#"+bridgeId).css("visibility","visible");
					
					if($.browser.msie){
						$("#"+bridgeId).css({
							"width":"215px",
	        				"height":"138px"
						})
					}
	        	},
	        	flashpermissionhide: function() {
            		if($.browser.msie){
						$("#"+bridgeId).css({
							"width":"1px",
	        				"height":"1px"
						})
					}else{
						$("#"+bridgeId).css("visibility","hidden");
					}
	        	}
	        });
	    }
	    
	    // OMG! Fix position of flash movie to be integer pixel
	    phone.bind("flashpermissionshow", function() {
        	var p = $("#"+bridgeId).position();
			$("#"+bridgeId).css("left",parseInt(p.left));
			$("#"+bridgeId).css("top",parseInt(p.top));
	    });		
		
	    FABridge.addInitializationCallback(bridgeId, function(){
	    	phone.$flash = this.create("Wrapper").getPhone();
	    	phone.apply(options);
	    	phone.$flash.setId(bridgeId);
	    	phone.$flash.addEventListener(null, phone.flashEventListener);
	    	if(phone.hasOwnProperty("gateway")) {
    	    	phone.$flash.connect(phone.gateway);
	    	}
	    	else {
    	    	phone.$flash.connect();
	    	}
	    });
	    
	    flashembed(bridgeId, {src:options.flashMovie, id:bridgeId + "id"}, {bridgeName:bridgeId});
	    
	    return phone;
	    
	}
	
	
})(jQuery);