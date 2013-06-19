<cfcomponent>
	
	<cffunction name="register">
		<cfset this._register(argumentCollection=arguments)>
	</cffunction>
	
	<cffunction name="_register">
		<cfargument name="component">
		<cfset this[arguments.component._name] = arguments.component>
	</cffunction>
	
	<cffunction name="_autoregister">
		<cfif isDefined("this.mod")>
			<cfset context = this.mod>
		<cfelse>
			<cfset context = this.app>
		</cfif>
		<cfset this.lbase.autoregister(this,context)>
	</cffunction>
	
</cfcomponent>