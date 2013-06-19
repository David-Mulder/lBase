<cfcomponent>

	<cfset this.modules = []>

	<cffunction name="init">
		<cfdirectory action="list" directory="#expandPath('/modules/')#" name="modules">
		<cfloop query="modules">
			<cfif fileExists(expandPath("/modules/#modules.name#/config/routes.cfc"))>
				<cfset arrayAppend(this.modules,modules.name)>
			</cfif>
			<!---<cfdirectory action="list" directory="#expandPath('/modules/#modules.name#/controllers')#" name="modules">--->
		</cfloop>
	</cffunction>

	<cffunction name="getConfig">
		<cfargument name="checkModules" default="#true#">

		<cfif not isDefined("variables.routes")>
			<cfset variables.routes = {}>
		</cfif>

		<cfset str_return = {
			destination:this.getRelevantURLPath(),
			controller:"home",
			page:"index",
			arguments:[]
		}>

		<cfloop collection="#variables.routes#" item="route">

			<cfset regex = "^" & route & "$">
			<cfset regex = replace(regex,"(:num)","(\d+)","all")>
			<cfset regex = replace(regex,"(*)","(.*?)","all")>

			<cfset origin = str_return.destination>
			<cfset matches = reFindNoCase(regular=regex,string=origin,subexpression=true)>
			<cfif matches.pos[1] gt 0>
				<cfset var destination = "/" & variables.routes[route]>
				<cfloop from="2" to="#arraylen(matches.pos)#" index="matchI">
					<cfset destination = replace(destination,"$"&(matchI-1),mid(origin,matches.pos[matchI],matches.len[matchI]),"all")>
				</cfloop>
				<cfset str_return.destination = destination>
				<cfbreak>
			</cfif>

		</cfloop>
		<cfif isDefined("str_return.destination") and len(str_return.destination)>
			<cfset var destination = listtoarray(str_return.destination,"/",true)>
			<cfset arraydeleteat(destination,1)>
			<cfif arraylen(destination) gte 1>
				<cfif arguments.checkModules and arrayFind(this.modules,destination[1])>
					<cfset module_routes = this.lbase.createObject("modules.#destination[1]#.config.routes","application")>
					<cfset module_route = module_routes.getConfig(context="application",checkModules=false)>
					<cfset str_return.controller = module_route.controller>
					<cfset str_return.page = module_route.page>
					<cfset str_return.arguments = module_route.arguments>
					<cfset str_return.module = destination[1]>
					<cfreturn str_return>
				<cfelse>
					<cfset str_return.controller = destination[1]>
					<cfif arraylen(destination) gt 1>
						<cfset str_return.page = destination[2]>
						<cfset str_return.arguments = duplicate(destination)>
						<cfset arraydeleteat(str_return.arguments,1)>
						<cfset arraydeleteat(str_return.arguments,1)>							
					</cfif>
				</cfif>
			<cfelse>
				<cfset str_return.controller = "home">
				<cfset str_return.page = "index">
				<cfset str_return.arguments = []>
			</cfif>
		</cfif>
		<cfreturn str_return>
	</cffunction>
	
	<cffunction name="getRelevantURLPath">
		<cfset urlpath = request.page>
		<cfif len(urlpath) gt 1 and right(urlpath,1) eq "/">
			<cfset urlpath = left(urlpath,len(urlpath)-1)>
		</cfif>
		<cfreturn urlpath>
	</cffunction>
	
</cfcomponent>