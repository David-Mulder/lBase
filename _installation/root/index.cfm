<cfsetting enableCFoutputOnly="yes">
<cfif isDefined("url.restart")>
	
	<cfoutput>DO NOT USE THIS FEATURE EXCEPT IF THE APP BREAKS</cfoutput>
	
	<cfset session.lbase = {}>
	<cfset application.lbase = {}>
	<cfset session.lbase = {}>
	
</cfif>
<cfset createObject("system.base").run()>
	