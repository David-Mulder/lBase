<cfcomponent>

	<cfset this.sessionmanagement = true>

	<cffunction name="onSessionStart" returnType="void">    		
    	<cfif not isDefined("application.lbase")>
			<cfset application.lbase = {}>
		</cfif>
		<cfif not isDefined("application.lbase.sessions")>
			<cfset application.lbase.sessions = {}>
		</cfif>
		<cfset application.lbase.sessions[session.sessionid] = session>
	</cffunction>

	<cffunction name="onSessionend" returnType="void">    		
		<cfargument name="SessionScope">
		<cfargument name="AppScope">

		<cfset structDelete(arguments.AppScope.lbase.sessions,arguments.SessionScope.sessionid)>

	</cffunction>

</cfcomponent>