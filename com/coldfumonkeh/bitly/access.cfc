<!---
Name: access.cfc
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

--->
<cfcomponent displayname="access" output="false" hint="I am the access component, and I contain the account username and API key">

	<cfset variables.instance = structNew() />
	
	<cffunction name="init" access="public" output="false" returntype="Any" hint="I am the constructor method for the access class">
		<cfargument name="username" required="true" type="string" hint="The bit.ly account username" />
		<cfargument name="apikey"	required="true"	type="string" hint="The bit.ly account API key" />
			<cfscript>
				setusername(arguments.username);
				setapikey(arguments.apikey);
			</cfscript>
		<cfreturn this />
	</cffunction>
	
	<!--- MUTATORS --->
	<cffunction name="setusername" access="private" output="false" hint="I set the bit.ly account username">
		<cfargument name="username" required="true" type="string" hint="The bit.ly account username" />
		<cfset variables.instance.username = arguments.username />
	</cffunction>
	
	<cffunction name="setapikey" access="private" output="false" hint="I set the bit.ly API key">
		<cfargument name="apikey"	required="true"	type="string" hint="The bit.ly account API key" />
		<cfset variables.instance.apikey = arguments.apikey />
	</cffunction>
	
	<!--- ACCESSORS --->
	<cffunction name="getusername" access="public" output="false" hint="I get the bit.ly account username">
		<cfreturn variables.instance.username />
	</cffunction>
	
	<cffunction name="getapikey" access="public" output="false" hint="I get the bit.ly account API key">
		<cfreturn variables.instance.apikey />
	</cffunction>

</cfcomponent>