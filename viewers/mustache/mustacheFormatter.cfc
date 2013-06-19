<!---
	This extention to Mustache provides the following functionality:

	1) It adds Ctemplate-style "modifiers" (or formatters). You can now use the following
	   syntax with your variables:

	   Hello "{{NAME:leftPad(20):upperCase}}"

	   This would output the "NAME" variable, left justify it's output to 20 characters and
	   make the string upper case.

	   The idea is to provide a collection of common formatter functions, but a user could
	   extend this compontent to add in their own user formatters.

	   This method provides is more readable and easy to implement over the lambda functionality
	   in the default Mustache syntax.
--->
<cfcomponent extends="Mustache" output="false">

<!---
	<!---// the only difference to the original RegEx is I capture the ".*" match //--->
	<cfset variables.TagRegEx = CreateObject("java","java.util.regex.Pattern").compile("\{\{(!|\{|&|\>)?\s*(\w+)(.*?)\}?\}\}", 32) />
--->

	<!---// captures arguments to be passed to formatter functions //--->
	<cfset variables.Mustache.ArgumentsRegEx = createObject("java","java.util.regex.Pattern").compile("[^\s,]*(?<!\\)\(.*?(?<!\\)\)|(?<!\\)\[.*?(?<!\\)\]|(?<!\\)\{.*?(?<!\\)\}|(?<!\\)('|"").*?(?<!\\)\1|(?:(?!,)\S)+", 40) />

	<cffunction name="init">
		<cfset super.init(argumentCollection=arguments)>
		<cfset variables.xss = this.app.module("core").lib("xss")>
		<cfset variables.xss.returnValues = true>
		<cfreturn this>
	</cffunction>

	<!---// overwrite the default methods //--->
  <cffunction name="onRenderTag" access="private" output="false">
    <cfargument name="rendered" />
    <cfargument name="options" hint="Arguments supplied to the renderTag() function" />

		<cfset var local = {} />
		<cfset var results = arguments.rendered />
		<cfif not structKeyExists(arguments.options, "extra") or not len(arguments.options.extra)>
			<cfset arguments.options.extra=":html">
		</cfif>

		<cfset local.extras = listToArray(arguments.options.extra, ":") />

		<!---// look for functional calls (see #2) //--->
		<cfloop index="local.fn" array="#local.extras#">
			
			<!---// all formatting functions start with two underscores //--->
			<cfset local.fn = trim(local.fn)>
			<cfset local.fnName = listFirst(local.fn, "(") />
			<cfset local.ffn = trim("__" & local.fn) />
			<cfset local.ffnName = listFirst(local.fn, "(") />
			
			<cfif structKeyExists(variables.xss, trim(local.fn))>
				<!---// get the arguments (but ignore empty arguments) //--->
				<cfif reFind("\([^\)]+\)", local.fn)>
					<!---// get the arguments from the function name //--->
					<cfset local.args = replace(local.fn, local.fnName & "(", "") />
					<!---// gets the arguments from the string //--->
					<cfset local.args = regexMatch(left(local.args, len(local.args)-1), variables.Mustache.ArgumentsRegEx) />
				<cfelse>
					<cfset local.args = [] />
				</cfif>
				
				<cfinvoke component="#xss#" method="#local.fn#" returnvariable="results">
					<cfinvokeargument name="1" value="#results#">
					<cfset local.i = 1 />
					<cfloop index="local.value" array="#local.args#">
						<cfset local.i++ />
						<cfinvokeargument name="#local.i#" value="#trim(local.value)#" />
					</cfloop>
				</cfinvoke>
			</cfif>
			
			<!---// check to see if we have a function matching this fn name //--->
			<cfif structKeyExists(variables, local.ffnName) and isCustomFunction(variables[local.ffnName])>
				<!---// get the arguments (but ignore empty arguments) //--->
				<cfif reFind("\([^\)]+\)", local.ffn)>
					<!---// get the arguments from the function name //--->
					<cfset local.args = replace(local.ffn, local.ffnName & "(", "") />
					<!---// gets the arguments from the string //--->
					<cfset local.args = regexMatch(left(local.args, len(local.args)-1), variables.Mustache.ArgumentsRegEx) />
				<cfelse>
					<cfset local.args = [] />
				</cfif>

				<!---// call the function and pass in the arguments //--->
				<cfinvoke method="#local.ffnName#" returnvariable="results">
					<cfinvokeargument name="1" value="#results#">
					<cfset local.i = 1 />
					<cfloop index="local.value" array="#local.args#">
						<cfset local.i++ />
						<cfinvokeargument name="#local.i#" value="#trim(local.value)#" />
					</cfloop>
				</cfinvoke>
			</cfif>
		</cfloop>

		<cfreturn results />
  </cffunction>

	<cffunction name="htmlEncode" access="private" output="false"
		hint="Encodes a string into HTML (can be overridden)">
		<cfargument name="input"/>
		<cfargument name="options"/>
		<cfargument name="callerArgs" hint="Arguments supplied to the renderTag() function"/>

		<cfreturn arguments.input/>
	</cffunction>

	<cffunction name="regexMatch" access="private" output="false">
		<cfargument name="text"/>
		<cfargument name="re"/>

		<cfset var local = {}>

		<cfset local.results = []/>
		<cfset local.matcher = arguments.re.matcher(arguments.text)/>
		<cfset local.i = 0 />
		<cfset local.nextMatch = "" />
		<cfloop condition="#local.matcher.find()#">
			<cfset local.nextMatch = local.matcher.group(0) />
			<cfif isDefined('local.nextMatch')>
				<cfset arrayAppend(local.results, local.nextMatch) />
			<cfelse>
				<cfset arrayAppend(local.results, "") />
			</cfif>
		</cfloop>

		<cfreturn local.results />
	</cffunction>

	<!---//
		MUSTACHE FUNCTIONS
	 //--->
	 
	<cffunction name="__leftPad" access="private" output="false">
		<cfargument name="value" type="string" />
		<cfargument name="length" type="numeric" />

		<cfreturn lJustify(arguments.value, arguments.length) />
	</cffunction>

	<cffunction name="__rightPad" access="private" output="false">
		<cfargument name="value" type="string" />
		<cfargument name="length" type="numeric" />

		<cfreturn rJustify(arguments.value, arguments.length) />
	</cffunction>

	<cffunction name="__upperCase" access="private" output="false">
		<cfargument name="value" type="string" />

		<cfreturn ucase(arguments.value) />
	</cffunction>

	<cffunction name="__lowerCase" access="private" output="false">
		<cfargument name="value" type="string" />

		<cfreturn lcase(arguments.value) />
	</cffunction>

	<cffunction name="__multiply" access="private" output="false">
		<cfargument name="num1" type="numeric" />
		<cfargument name="num2" type="numeric" />

		<cfreturn arguments.num1 * arguments.num2 />
	</cffunction>

</cfcomponent>