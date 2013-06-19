<cfcomponent extends="system.config.routes">
	
	<cffunction name="init">
		
	</cffunction>

	<cffunction name="getConfig">
		<cfif arguments.context eq "application">
			<cfreturn super.getConfig(argumentCollection=arguments)>
		</cfif>
		<!--- see aplication config --->
		<cfreturn variables.routes>
	</cffunction>

	<cffunction name="getRelevantURLPath">
		<cfset var destination = listDeleteAt(super.getRelevantURLPath(),1,'/')>
		<cfif destination eq "">
			<cfset destination = "/">
		</cfif>
		<cfreturn destination>
	</cffunction>

</cfcomponent>