<cfcomponent extends="system._core.baseobject">
	
	<cfset this.filetype = "html">
	<cfset this.cfmlparse = false>
	
	<cffunction name="parse">
		<cfargument name="content">
		<cfreturn arguments.content>
	</cffunction>
	
	<cffunction name="execute">
		<cfargument name="file">
		<cfargument name="filename">
		<cfargument name="data">
		
		
		<cfset var mustache = this.lbase.createObject("system.viewers.mustache.mustacheFormatter","instance")>
		<cfset var fu = createObject("java","org.apache.commons.io.FileUtils")>
		<cfset var template = fu.readFileToString(arguments.file)>
		<cfset this.app._autoregister()>
		<cfoutput>#mustache.render(template, arguments.data)#</cfoutput>
		
		<!---
		<cfloop collection="#arguments.data#" item="dataVar">
			<cfset variables[dataVar] = arguments.data[dataVar]>
		</cfloop>
		
		<cfset variables["app"] = this.app>
		<cfif isDefined("this.mod")>
			<cfset variables["mod"] = this.mod>
		</cfif>
		
		<cfset variables["out"] = this.app.module("core").lib("xss")>
			
		<cfinclude template="#arguments.fullpath#">
		--->
	</cffunction>
	
</cfcomponent>