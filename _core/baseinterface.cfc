<cfcomponent>

	<cfset this.basepath = "">
	
	<cffunction name="view">
		<cfargument name="template">
		<cfargument name="data" default="#{}#">
		<cfargument name="output" default="#true#">

		<cfset var file = arguments.template>
		
		<cfif not find(".",file) gt 0>
			<cfset file = file & "." & this.app.config.base.defaultViewer>
			<cfset var viewertype = this.app.config.base.defaultViewer>
		<cfelse>
			<cfset file = file>
			<cfset var viewertype = listlast(file,".")>
		</cfif>
		<cfset file = replace(this.basepath,".","/","all") & "/views/" & file>

		<cfset var viewer = createObject("viewer")>
			
		<cfset viewer.app = this.app>
		<cfset viewer.lbase = this.lbase>
		<cfif isDefined("this.mod")>
			<cfset viewer.mod = this.mod>
		</cfif>
		
		<cfreturn viewer.view("/"&file,viewertype,arguments.data,arguments.output)>

	</cffunction>

	<cffunction name="lib">
		<cfargument name="name">
		<cfset var component = this.lbase.createObject(this.basepath & ".libraries." & arguments.name,"application")>
		<!--- the following two references shouldn't be necessary, but better be safe than sorry --->
		<cfset component.app = this.app>
		<cfif isDefined("this.mod")>
			<cfset component.mod = this.mod>
		</cfif>
		<cfif isDefined("component._name")>
			<cfreturn component>
		<cfelse>
			<cfset component._type = "lib">
			<cfset component._name = arguments.name>
			<cfset component._fullname = this.basepath & ".libraries." & arguments.name>
			<cftry>
				<cfset component._autoregister()>
				<cfcatch>
					<cfset this.lbase.error(code=503,developerMessage="Did you forget to extend 'system.library'? Component autoregistration didn't work.",cfcatch=cfcatch)>
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn component>
	</cffunction>

	<cffunction name="module">
		<cfargument name="name">
		<cfif fileexists(expandpath("/modules/"&arguments.name&"/interface.cfc"))>
			<cfset var bi = this.lbase.createObject(fullpath="modules."&arguments.name&".interface",defaultScope="request",doInit=false)>
		<cfelse>
			<cfset var bi = this.lbase.createObject(fullpath="system._core.baseinterface",name=arguments.name,defaultScope="request",hashid=hash("modules."&arguments.name),doInit=false)>		
		</cfif>
		<cfif isDefined("bi._name")>
			<cfreturn bi>
		<cfelse>
			<cfset bi._type = "module">
			<cfset bi._name = arguments.name>
			<cfset bi._fullname = "modules."&arguments.name>
			<cfset bi.basepath = "modules."&arguments.name>
			<cfset bi.app = this.app>
			<cfset bi.mod = bi>
			<cfset bi.lbase = this.lbase>
			<cfif isDefined("bi.init")>
				<cfset bi.init()>
			</cfif>
			<cfset bi.config = this.lbase.createObject(fullpath="system._core.config",defaultScope="request",doInit=false,hashid=hash("system._core.config"&arguments.name))>
			<cfset bi.config.basepath = bi.basepath>
			<cfset bi.config.context = "module">
			<cfset bi.config.init()>
			<cfset bi._autoregister()>
			<cfreturn bi>
		</cfif>		
	</cffunction>

	<cffunction name="model">
		<cfargument name="name">
		<cfset var component = this.lbase.createObject(this.basepath & ".models." & arguments.name,"instance")>
		<cfset component._type = "model">
		<cfset component._name = arguments.name>
		<cfset component._fullname = this.basepath & ".models." & arguments.name>
		<cfset component.app = this.app>
		<cfif isDefined("this.mod")>
			<cfset component.mod = this.mod>
		</cfif>
		<cfreturn component>
	</cffunction>
	
	<cffunction name="_register">
		<cfargument name="component">
		<cfset this[arguments.component._name] = arguments.component>
	</cffunction>
	
	<cffunction name="_autoregister">
		<cfif isDefined("this.mod")>
			<cfset var context = this.mod>
		<cfelse>
			<cfset var context = this.app>
		</cfif>
		<cfset this.lbase.autoregister(this,context)>
	</cffunction>

</cfcomponent>