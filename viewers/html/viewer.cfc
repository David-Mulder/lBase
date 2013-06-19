<cfcomponent extends="system._core.baseobject">
	
	<cfset this.filetype = "html">
	<cfset this.cfmlparse = false>
	
	<cffunction name="parse">
		<cfargument name="content">
		<cfset arguments.content = replace(arguments.content,"<%html(","<cfset out.__callInOutput('html',","all")>
		<cfset arguments.content = replace(arguments.content,"<%attr(","<cfset out.__callInOutput('attr',","all")>
		<cfset arguments.content = replace(arguments.content,"<%unsafe(","<cfset out.__callInOutput('unsafe',","all")>
		<cfreturn arguments.content>
	</cffunction>
	
	<cffunction name="execute">
		<cfargument name="file">
		<cfargument name="filename">
		<cfargument name="data">
			
		<cfloop collection="#arguments.data#" item="dataVar">
			<cfset variables[dataVar] = arguments.data[dataVar]>
		</cfloop>
		
		<cfset variables["app"] = this.app>
		<cfset variables["console"] = this.app.module("core").lib("console")>
		<cfif isDefined("this.mod")>
			<cfset variables["mod"] = this.mod>
		</cfif>
		
		<cfset variables["out"] = this.app.module("core").lib("xss")>
			
		<cfsetting enableCFoutputOnly="no"><cfinclude template="#arguments.filename#"><cfsetting enableCFoutputOnly="yes">
	</cffunction>
	
</cfcomponent>