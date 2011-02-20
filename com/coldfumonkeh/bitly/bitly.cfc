<!---
Name: bitly.cfc
Author: Matt Gifford AKA coldfumonkeh (http://www.mattgifford.co.uk)
Date: 10.03.2010

Copyright 2010 Matt Gifford AKA coldfumonkeh. All rights reserved.
Product and company names mentioned herein may be
trademarks or trade names of their respective owners.

Subject to the conditions below, you may, without charge:

Use, copy, modify and/or merge copies of this software and
associated documentation files (the 'Software')

Any person dealing with the Software shall not misrepresent the source of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Release Notes
================

Got a lot out of this package? Saved you time and money? 
Share the love and visit Matt’s wishlist: http://www.amazon.co.uk/wishlist/B9PFNDZNH4PY 

Revision history
================

13/10/2010 - Version 2.0

	- updated methods now include:
		- referers, countries, clicksByMinute, clicksByDay, generateQRCode

02/08/2010 - Version 1.1

	- updated methods to interact with version 3.0 of the bit.ly API
	- removed deprecated methods
	- added extra functions to handle with building param strings for remote API calls

--->
<cfcomponent name="bitly" output="false" hint="I am the main bityly Class component.">

	<cfset variables.instance = structNew() />
	
	<cffunction name="init" access="public" output="false" returntype="Any" hint="I am the constructor method for the bitly Class.">
		<cfargument name="username" required="true" 	type="string" 									hint="The bitly account username" />
		<cfargument name="apikey"	required="true"		type="string" 									hint="The bitly account API key" />
		<cfargument name="format"	required="false" 	type="string" 	default="xml" 					hint="The return format from the API response. JSON or XML." />
		<cfargument name="parse"	required="false" 	type="boolean"  default="false"					hint="A boolean value to determine if the output data is parsed or returned as a string" />
		<cfargument name="apiURL"	required="false"	type="string" 	default="http://api.bit.ly/v3/" hint="The URL for the API." />
			<cfscript>
				setAccountDetails(arguments.username,arguments.apikey);
				setReturnFormat(arguments.format);
				setParse(arguments.parse);
				setAPIURL(arguments.apiURL);
			</cfscript>
		<cfreturn this />
	</cffunction>
	
	<!--- MUTATORS --->
	<cffunction name="setAccountDetails" access="private" output="false" returntype="void" hint="I set the bitly account details">
		<cfargument name="username" required="true" type="string" hint="The bitly account username" />
		<cfargument name="apikey"	required="true"	type="string" hint="The bitly account API key" />
		<cfset variables.instance.bitlyaccount = createObject('component','access').init(argumentCollection=arguments) />
	</cffunction>
	
	<cffunction name="setReturnFormat" access="private" output="false" hint="I set the string value for the response format from the API.">
		<cfargument name="format" required="false" type="string" hint="The return format of responses from the bitly API. XML or JSON." />
		<cfset variables.instance.returnformat = arguments.format />
	</cffunction>
	
	<cffunction name="setAPIURL" access="private" output="false" hint="I set the string value for the API URL">
		<cfargument name="apiURL" required="false" type="string" hint="The URL for the API." />
		<cfset variables.instance.apiURL = arguments.apiURL />
	</cffunction>
	
	<cffunction name="setParse" access="private" output="false" hint="I set the parse value for use in the method calls.">
		<cfargument name="parse" required="false" type="boolean" hint="A boolean value to determine if the output data is parsed or returned as a string" />
		<cfset variables.instance.parse = arguments.parse />
	</cffunction>
	
	<!--- ACCESSORS --->
	<cffunction name="getAccountDetails" access="private" output="false" returntype="Any" hint="I return the acess component">
		<cfreturn variables.instance.bitlyaccount />
	</cffunction>
	
	<cffunction name="getUserName" access="private" output="false" returntype="Any" hint="I return the username from the access component">
		<cfreturn getAccountDetails().getusername() />
	</cffunction>
	
	<cffunction name="getApiKey" access="private" output="false" returntype="Any" hint="I return the api key from the acess component">
		<cfreturn getAccountDetails().getapikey() />
	</cffunction>
	
	<cffunction name="getReturnFormat" access="private" output="false" hint="I return the string value for the return response from the variables.instance struct">
		<cfreturn variables.instance.returnformat />
	</cffunction>
	
	<cffunction name="getAPIURL" access="private" output="false" hint="I return the string value for the API URL">
		<cfreturn variables.instance.APIURL />
	</cffunction>
	
	<cffunction name="getParse" access="private" output="false" returntype="string" hint="I return the parse value for use in the method calls.">
		<cfreturn variables.instance.parse />
	</cffunction>
	
	<!--- PUBLIC METHODS --->
	<cffunction name="shorten" access="public" output="false" returntype="Any" hint="Given a long URL, I encode it as a shorter URL.">
		<cfargument name="longURL" 	required="true"  	type="string" 									hint="I am a long URL that you wish to be shortened." />
		<cfargument name="format"  	required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON, XML or TXT." />
		<cfargument name="domain" 	required="true" 	type="String" default="bit.ly"					hint="I refer to a preferred domain; either bit.ly default or j.mp. This affects the output value of url." />
		<cfargument name="x_login" 	required="false" 	type="String" default=""						hint="I am the end-user's login when making requests on behalf of another bit.ly user. This allows application developers to pass along an end user's bit.ly login." />
		<cfargument name="x_apiKey" required="false" 	type="String" default=""						hint="I am the end-user's apiKey when making requests on behalf of another bit.ly user. This allows application developers to pass along an end user's bit.ly apiKey." />
			<cfset var strParam 	= '' />
			<cfset var strResponse 	= '' />
				<cfscript>
					strParam 	= buildParamString(arguments);
					strResponse = makeCall(method='shorten',param=strParam);
				</cfscript>
		<cfreturn handleReturnFormat(strResponse.fileContent,arguments.format) />
	</cffunction>
	
	<cffunction name="expand" access="public" output="false" returntype="Any" hint="Given a bit.ly URL or hash, I return a lengthened URL.">
		<cfargument name="shortURL" required="false" 	type="string" 									hint="I am a short URL that you wish to be lengthened. For more than one short URL, please provide a comma-delimited list." />
		<cfargument name="hash" 	required="false" 	type="string" 									hint="I am a bit.ly URL hash that you wish to be lengthened. For more than one hash, please provide a comma-delimited list." />
		<cfargument name="format"	required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON, XML or TXT." />
			<cfset var strParam 	= '' />
			<cfset var strResponse 	= '' />
				<cfscript>
					strParam 	= buildParamString(arguments);
					strResponse = makeCall(method='expand',param=strParam);
				</cfscript>
		<cfreturn handleReturnFormat(strResponse.fileContent,arguments.format) />
	</cffunction>
	
	<cffunction name="validate" access="public" output="false" returntype="Any" hint="Given a bit.ly user login and apiKey, I validate that the pair is active. I return 0 or 1, determining whether or not the user/apikey pair is currently valid.">
		<cfargument name="x_login" 	required="true" 	type="string" 									hint="The bitly account username" />
		<cfargument name="x_apiKey"	required="true"		type="string" 									hint="The bitly account API key" />
		<cfargument name="format"	required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON, XML or TXT." />
			<cfset var strParam 	= '' />
			<cfset var strResponse 	= '' />
				<cfscript>
					strParam 	= buildParamString(arguments);
					strResponse = makeCall(method='validate',param=strParam);
				</cfscript>
		<cfreturn handleReturnFormat(strResponse.fileContent,arguments.format) />
	</cffunction>
	
	<cffunction name="clicks" access="public" output="false" returntype="Any" hint="Given a bit.ly URL or hash, I return statistics about the clicks on that link.">
		<cfargument name="shortURL" required="false" 	type="string" 									hint="I am a short URL that you wish to have the stats for. For more than one short URL, please provide a comma-delimited list." />
		<cfargument name="hash" 	required="false" 	type="string"									hint="I am a bitly URL hash that you wish to have the stats for. For more than one hash, please provide a comma-delimited list." />
		<cfargument name="format"	required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON or XML." />
			<cfset var strParam 	= '' />
			<cfset var strResponse 	= '' />
				<cfscript>
					strParam 	= buildParamString(arguments);
					strResponse = makeCall(method='clicks',
											param=strParam);
				</cfscript>
		<cfreturn handleReturnFormat(strResponse.fileContent,arguments.format) />
	</cffunction>
	
	<cffunction name="referrers" access="public" output="false" returntype="Any" hint="I provide a list of referring sites for a specified bit.ly short link, and the number of clicks per referrer.">
		<cfargument name="shortURL" required="false" 	type="string" 									hint="I am a short URL that you wish to have the stats for. For more than one short URL, please provide a comma-delimited list." />
		<cfargument name="hash" 	required="false" 	type="string"									hint="I am a bitly URL hash that you wish to have the stats for. For more than one hash, please provide a comma-delimited list." />
		<cfargument name="format"	required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON or XML." />
			<cfset var strParam 	= '' />
			<cfset var strResponse 	= '' />
				<cfscript>
					strParam 	= buildParamString(arguments);
					strResponse = makeCall(method='referrers',
											param=strParam);
				</cfscript>
		<cfreturn handleReturnFormat(strResponse.fileContent,arguments.format) />
	</cffunction>
	
	<cffunction name="countries" access="public" output="false" returntype="Any" hint="I provide a list of countries from which clicks on a specified bit.ly short link have originated, and the number of clicks per country.">
		<cfargument name="shortURL" required="false" 	type="string" 									hint="I am a short URL that you wish to have the stats for. For more than one short URL, please provide a comma-delimited list." />
		<cfargument name="hash" 	required="false" 	type="string"									hint="I am a bitly URL hash that you wish to have the stats for. For more than one hash, please provide a comma-delimited list." />
		<cfargument name="format"	required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON or XML." />
			<cfset var strParam 	= '' />
			<cfset var strResponse 	= '' />
				<cfscript>
					strParam 	= buildParamString(arguments);
					strResponse = makeCall(method='countries',
											param=strParam);
				</cfscript>
		<cfreturn handleReturnFormat(strResponse.fileContent,arguments.format) />
	</cffunction>
	
	<cffunction name="clicksByMinute" access="public" output="false" returntype="Any" hint="For one or more bit.ly links, I provide time series clicks per minute for the last hour in reverse chronological order (most recent to least recent).">
		<cfargument name="shortURL" required="false" 	type="string" 									hint="I am a short URL that you wish to have the stats for. For more than one short URL, please provide a comma-delimited list." />
		<cfargument name="hash" 	required="false" 	type="string"									hint="I am a bitly URL hash that you wish to have the stats for. For more than one hash, please provide a comma-delimited list." />
		<cfargument name="format"	required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON or XML." />
			<cfset var strParam 	= '' />
			<cfset var strResponse 	= '' />
				<cfscript>
					strParam 	= buildParamString(arguments);
					strResponse = makeCall(method='clicks_by_minute',
											param=strParam);
				</cfscript>
		<cfreturn handleReturnFormat(strResponse.fileContent,arguments.format) />
	</cffunction>
	
	<cffunction name="clicksByDay" access="public" output="false" returntype="Any" hint="For one or more bit.ly links, I provide time series clicks per day for the last 30 days in reverse chronological order (most recent to least recent).">
		<cfargument name="shortURL" required="false" 	type="string" 									hint="I am a short URL that you wish to have the stats for. For more than one short URL, please provide a comma-delimited list." />
		<cfargument name="hash" 	required="false" 	type="string"									hint="I am a bitly URL hash that you wish to have the stats for. For more than one hash, please provide a comma-delimited list." />
		<cfargument name="format"	required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON or XML." />
			<cfset var strParam 	= '' />
			<cfset var strResponse 	= '' />
				<cfscript>
					strParam 	= buildParamString(arguments);
					strResponse = makeCall(method='clicks_by_day',
											param=strParam);
				</cfscript>
		<cfreturn handleReturnFormat(strResponse.fileContent,arguments.format) />
	</cffunction>
	
	<cffunction name="proDomain" access="public" output="false" returntype="Any" hint="I am used to query whether a given short domain is assigned for bitly.Pro, and is consequently a valid shortUrl parameter for other api calls. Keep in mind that bitly.pro domains are restricted to less than 15 characters in length. I return a 0 or 1, determining whether or not this is a current bitly.Pro domain.">
		<cfargument name="domain" 	required="true"  	type="string" default="" 						hint="I am a short domain (ie: nyti.ms)." />
		<cfargument name="format"	required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON or XML." />
			<cfset var strParam = '' />
			<cfset var strResponse 	= '' />
				<cfscript>
					strParam 	= buildParamString(arguments);
					strResponse = makeCall(method='bitly_pro_domain',
											param=strParam);
				</cfscript>
		<cfreturn handleReturnFormat(strResponse.fileContent,arguments.format) />
	</cffunction>
	
	<cffunction name="lookup" access="public" output="false" returntype="Any" hint="Given a long URL, I encode it as a shorter URL.">
		<cfargument name="url" 		required="true"  	type="string" 									hint="I am a long URL that you would like to perform a lookup on. For more than one URL, please provide a comma-delimited list." />
		<cfargument name="format"  	required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON, XML or TXT." />
			<cfset var strParam 	= '' />
			<cfset var strResponse 	= '' />
				<cfscript>
					strParam 	= buildParamString(arguments);
					strResponse = makeCall(method='lookup',param=strParam);
				</cfscript>
		<cfreturn handleReturnFormat(strResponse.fileContent,arguments.format) />
	</cffunction>
		
	<cffunction name="authenticate" access="public" output="false" hint="I am used by your application to lookup a bit.ly API key for a user given a bit.ly username and password. Access to this endpoint is restricted and must be requested by emailing api@bit.ly. When requesting access include your application login and apiKey, and a description of your use case and an estimated volume of requests.">
		<cfargument name="x_login" 		required="true" 	type="string" 									hint="The bitly account username or email address." />
		<cfargument name="x_password"	required="true"		type="string" 									hint="The bitly account password." />
		<cfargument name="format"		required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON or XML." />
			<cfset var cfhttp 		= '' />
			<cfset var strParam 	= buildParamString(arguments) />
				<cfset strParam = strParam &'&login=' & getUserName() & '&apiKey=' & getApiKey() />
				<cfhttp url="#getAPIURL()#authenticate" method="post" useragent="monkeh bitly agent">
					<cfhttpparam name="login" 		type="formfield" value="#getUserName()#" />
					<cfhttpparam name="apiKey" 		type="formfield" value="#getApiKey()#" />
					<cfhttpparam name="x_login" 	type="formfield" value="#arguments.x_login#" />
					<cfhttpparam name="x_password" 	type="formfield" value="#arguments.x_password#" />
					<cfhttpparam name="format" 		type="formfield" value="#arguments.format#" />
				</cfhttp>
		<cfreturn handleReturnFormat(cfhttp.fileContent,arguments.format) />
	</cffunction>
	
	<cffunction name="info" access="public" output="false" returntype="Any" hint="Given a bit.ly URL or hash, I return information about that page, such as the long source URL, associated usernames, and other information.">
		<cfargument name="shortURL" required="false" 	type="string"  								hint="I am a short URL that you wish to have the stats for. For more than one short URL, please provide a comma-delimited list." />
		<cfargument name="hash" 	required="false" 	type="string"  								hint="I am a bit.ly URL hash that you wish to have the stats for. For more than one hash, please provide a comma-delimited list." />
		<cfargument name="format"	required="false" 	type="string" default="#getReturnFormat()#" 	hint="The return format from the API response. JSON or XML." />
			<cfset var strParam = '' />
			<cfscript>
				strParam 	= buildParamString(arguments);
				strResponse = makeCall(method='info',
										param=strParam);
			</cfscript>
		<cfreturn handleReturnFormat(strResponse.fileContent,arguments.format) />
	</cffunction>
	
	<cffunction name="generateQRCode" access="public" output="false" hint="I take a bit.ly generated URL, and return the binary data of the generated QR Code image.">
		<cfargument name="shortURL" required="true" type="string"  	hint="I am a short URL that you wish to create a QR Code for." />
			<cfset var cfhttp 		= '' />
			<cfset var returnData 	= '' />
				<cfhttp url="#arguments.shortURL#.qrcode" />
				<cfif cfhttp.StatusCode EQ '200 OK'>
					<cfset returnData = cfhttp.fileContent.toByteArray() />
				</cfif>
		<cfreturn returnData />
	</cffunction>
	
	<!--- PRIVATE METHODS --->
	<cffunction name="makeCall" access="private" output="false" returntype="Any" hint="I make the remote call to the bit.ly API.">
		<cfargument name="method" required="true" 	type="string" 			hint="The name of the method to call from the API." />
		<cfargument name="param"  required="false" 	type="string" default="" hint="The parameter required for the API call (relevant to the method veing called))" />
			<cfset var cfhttp 	= '' />
			<cfset var strURL 	= '' />
			<cfset var strParam = '' />
				<cfscript>
					if(len(arguments.param)) {
						strParam = arguments.param & '&';
					}
					// build the API URL request string
					strURL = strURL & getAPIURL() & arguments.method & '?' 
							& strParam &'login=' & getUserName() & '&apiKey=' & getApiKey();             	                
                </cfscript>
				<cfhttp url="#strURL#" method="get" />
		<cfreturn cfhttp />
	</cffunction>
	
	<cffunction name="handleReturnFormat" access="private" output="false" hint="I handle how the data is returned based upon the provided format">
		<cfargument name="data" 	required="true" 			  type="string" hint="The data returned from the API." />
		<cfargument name="format" 	required="true" default="xml" type="string" hint="The return format of the data. XML or JSON." />
			<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfif getParse()>
						<cfreturn XmlParse(arguments.data) />
					<cfelse>
						<cfreturn arguments.data />
					</cfif>
				</cfcase>
				<cfcase value="json">
					<cfif getParse()>
						<cfreturn DeserializeJSON(arguments.data) />
					<cfelse>
						<cfreturn serializeJSON(DeserializeJSON(arguments.data)) />
					</cfif>
				</cfcase>
				<cfcase value="txt">
					<cfreturn arguments.data />
				</cfcase>
				<cfdefaultcase>
					<cfif getParse()>
						<cfreturn XmlParse(arguments.data) />
					<cfelse>
						<cfreturn arguments.data />
					</cfif>
				</cfdefaultcase>
			</cfswitch>
		<cfabort>
	</cffunction>
	
	<cffunction name="buildParamString" access="private" output="false" returntype="String" hint="I loop through a struct to convert to query params for the URL.">
		<cfargument name="argScope" required="true" type="struct" hint="I am the struct containing the method params." />
			<cfset var strURLParam 	= '' />
				<cfloop collection="#arguments.argScope#" item="key">
					<cfif len(arguments.argScope[key])>
						<cfif listLen(strURLParam)>
							<cfset strURLParam = strURLParam & '&' />
						</cfif>						
						<cfif listLen(arguments.argScope[key], ',') GT 1>
							<cfloop from="1" to="#listLen(arguments.argScope[key], ',')#" index="i">
								<cfset strURLParam = strURLParam & getCorrectParamName(key) & '=' & trim(listGetAt(arguments.argScope[key], i, ',')) />
								<cfif i LT listLen(arguments.argScope[key], ',')>
									<cfset strURLParam = strURLParam & '&' />
								</cfif>
							</cfloop>
						<cfelse>
							<cfset strURLParam = strURLParam & getCorrectParamName(key) & '=' & arguments.argScope[key] />
						</cfif>
					</cfif>
				</cfloop>
		<cfreturn strURLParam />
	</cffunction>
	
	<cffunction name="getCorrectParamName" access="private" output="false" hint="I return the correct param name for a key. The API required certain params to be in camelCase, and so we enforce that here for those cases where required.">
		<cfargument name="paramKey" required="true" type="String" hint="I am the param key." />
			<cfset var strCorrect = '' />
				<cfswitch expression="#arguments.paramKey#">
					<cfcase value="shorturl">
						<cfset strCorrect = 'shortUrl' />
					</cfcase>
					<cfcase value="longurl">
						<cfset strCorrect = 'longUrl' />
					</cfcase>
					<cfcase value="x_apikey">
						<cfset strCorrect = 'x_apiKey' />
					</cfcase>
					<cfdefaultcase>
						<cfset strCorrect = lcase(arguments.paramKey) />
					</cfdefaultcase>
				</cfswitch>
			<cfreturn strCorrect />
	</cffunction>
	
</cfcomponent>