component{

	function run{
		var app = this.createApp();

		if(isDefined("app.config.routes.module")){
			var module = app.module(app.config.routes.module);
			selfReference = "mod";
			this.mod = module;
			baseMapping = "modules." & app.config.routes.module;
		}else{
			baseMapping = "application";
			selfReference = "app";
		}
			
		if(isDefined("app.config.routes.controller") and len(app.config.routes.controller)){
			try{
				controller = this.createObject("#baseMapping#.controllers."&app.config.routes.controller,"request");
			}catch{
				writedump(cfcatch);
				flush();
				if(cfcatch.errorCode eq "errorCode.badRequest"){
					this.error(404,"The page could not be found","The controller #app.config.routes.controller# in #baseMapping# could not be found");
				}else{
					rethrow;
					this.error(503);flush();
				}
			}
			<cfset controller._name = app.config.routes.controller>
			<cfset controller._fullname = "#baseMapping#.controllers."&app.config.routes.controller>
			<cfset this.completeObject(controller)>
			<cfset args_input = createObject("java","com.naryx.tagfusion.cfm.engine.cfArgStructData").init()>
			<cfloop from="1" to="#arraylen(app.config.routes.arguments)#" index="i">
			    <cfset args_input[i] = app.config.routes.arguments[i]>
			</cfloop>
			
			<cftry>
				<cfset controller._autoregister()>

				<cfif isDefined("controller.restful") and controller.restful>
					<cfset app.config.routes.page = cgi.request_method & "_" & app.config.routes.page>
				</cfif>
				<cfinvoke component="#controller#" method="#app.config.routes.page#" argumentCollection="#args_input#" returnVariable="output">
				<cfif isDefined("output")>
					<cfset var metaFunctions = getMetaData(controller).functions>
					<cfset var metaFunction = "">
					<cfloop array="#metaFunctions#" index="metaFunction">
						<cfif metaFunction.name eq app.config.routes.page>
							<cfbreak>
						</cfif>
					</cfloop>
					<cfif isDefined("metaFunction.returnFormat") and metaFunction.returnFormat eq "json">
						<cfoutput>#SerializeJSON(output)#</cfoutput>
					<cfelse>
						<cfoutput>#output#</cfoutput>						
					</cfif>
				</cfif>

				<cfcatch>
					<cfif cfcatch.detail contains "Method #app.config.routes.page# could not be found.">
						<cfset this.error(404,"The page could not be found","The page '#app.config.routes.page#' in the controller '#baseMapping#.controllers.#app.config.routes.controller#' could not be found.")>
					<cfelse>
						<cfrethrow>
						<cfset this.error(503)><cfflush>
					</cfif>					
				</cfcatch>
			</cftry>
		}else{
			<cfset this.error(404,"Page not found","No relevant controller could be determined")>
		}
	}
	
	<cffunction name="createApp">
		<cfset var app = createObject("system._core.baseinterface")>
		<cfset this.app = app>
		<cfset app._name = "application">
		<cfset app._fullname = "application">
		<cfset app.config = this.createObject(fullpath="system._core.config",defaultScope="request",doInit=false)>
		<cfset app.basepath = "application">
		<cfset app.config.lbase = this>
		<cfset app.config.basepath = "application">
		<cfset app.config.context = "application">
		<cfset app.config.init()>
		<cfset app.lbase = this>
		<cfset app.app = app>

		<cfset app._autoregister()>
		<cfreturn app>
	</cffunction>
	
	<cffunction name="error">
		<cfargument name="errorcode" default="503">
		<cfargument name="userMessage" default="Unknown error">
		<cfargument name="developerMessage" default="Unknown error">
		<cfargument name="cfcatch" default="#{}#">
<cfthrow>
		<cfparam name="request.errorNum" default="1">
		<cfif request.errorNum gt 1>
			<cfoutput>ERROR LOOP (error handling function is broken/looping)</cfoutput>
			<cfdump var="#arguments#">
			<cfabort>
		</cfif>
		<cfset request.errorNum = request.errorNum + 1>

		<cfset errorcontroller = createObject("application.controllers.error")>
		<cfset this.completeObject(errorcontroller)>
		<cfif isDefined("errorcontroller['"&arguments.errorcode&"']")>
			<cfset methodname = arguments.errorcode>
		<cfelse>
			<cfset methodname = "generic">
		</cfif>
		<cfinvoke component="#errorcontroller#" method="#methodname#" errorCode="#arguments.errorCode#" userMessage="#arguments.userMessage#" developerMessage="#arguments.developerMessage#">
		<cfabort>
	</cffunction>
	
	<cffunction name="createObject">
		<cfargument name="fullpath">
		<cfargument name="defaultScope">
		<cfargument name="hashid" default="#hash(arguments.fullpath)#">
		<cfargument name="doInit" default="#true#">

		<cfset var componentHash = arguments.hashid>
		<cfset scopes = {application:application,session:session,request:request}>
		<cfloop collection="#scopes#" item="scope">
			<cfif isDefined("scopes[scope].lbase.store[componentHash]")>
				<cfset obj = scopes[scope].lbase.store[componentHash]>
				<cfset this.completeObject(obj)>
				<cfreturn obj>
			</cfif>
		</cfloop>
		
		<cftry>
			<cfset metaObject = createObject("component",arguments.fullpath)>
			<cfcatch>
				<cfif cfcatch.errorCode eq "errorCode.badRequest">
					<cfset this.error(503,"The page could not be rendered","The object #fullpath# could not be found")>
				</cfif>
				<cfdump var="#arguments#"><cfflush>
				<cfdump var="#cfcatch#"><cfflush><cfrethrow>
			</cfcatch>
		</cftry>
		<cfset metaData = getMetaData(metaObject)>
		<cfif isDefined("metaData['lbase:scope']")>
			<cfset defaultScope = metaData['lbase:scope']>
		</cfif>

		<cfif defaultScope eq "instance">
			<cfset var obj = createObject("component",arguments.fullpath)>
			<cfset this.completeObject(obj)>

			<cfif isDefined("obj.init") and arguments.doInit>
				<cfset obj.init()>
			</cfif>
			<cfreturn obj>
		</cfif>
		
		<cfif not isDefined("scopes[scope].lbase")>
			<cfset scopes[scope].lbase = {}>
		</cfif>
		<cfif not isDefined("scopes[scope].lbase.store")>
			<cfset scopes[scope].lbase.store = {}>
		</cfif>
		<cfset scopes[defaultScope].lbase.store[componentHash] = createObject("component",arguments.fullpath)>
		<cfset this.completeObject(scopes[defaultScope].lbase.store[componentHash])>
		<cfif isDefined("scopes[defaultScope].lbase.store[componentHash].init") and arguments.doInit>
			<cfset scopes[defaultScope].lbase.store[componentHash].init()>
		</cfif>
		<cfreturn scopes[defaultScope].lbase.store[componentHash]>

	</cffunction>
	
	<cffunction name="completeObject" access="private">
		<cfargument name="object">
		<cfset object.lbase = this>
		<cfset object.app = this.app>
		<cfif isDefined("this.mod")>
			<cfset object.mod = this.mod>
		</cfif>
		<cfreturn object>
	</cffunction>

	<cffunction name="autoregister">
		<cfargument name="registrationScope">
		<cfargument name="context">
		
		<cfset var lib = "">
		<cfset var module = "">
		
		<cfif isDefined("arguments.context.config.base.autoregister")>
			<cfset var autoregister = arguments.context.config.base.autoregister>
			<cfif isDefined("autoregister.libraries")>
				<cfloop array="#autoregister.libraries#" index="lib">
					<cfif context._name eq "application">
						<!--- support libraries from external modules --->
						<cfif listFirst(lib,".") eq "application">
							<cfset arguments.registrationScope._register(arguments.context.lib(listDeleteAt(lib,1,".")))>
						<cfelse>
							<cfset lib = listDeleteAt(lib,1,".")>
							<cfset module = listgetat(lib,1,".")>
							<cfset lib = listDeleteAt(lib,1,".")>
							<cfset arguments.registrationScope._register(arguments.context.module(module).lib(lib,1,"."))>
						</cfif>
					<cfelse>
						<!--- do not support libraries from external modules in module --->
						<cfset arguments.registrationScope._register(arguments.context.lib(lib))>
					</cfif>
				</cfloop>
			</cfif>
			<cfif isDefined("autoregister.models")>
				<cfloop array="#autoregister.models#" index="model">
					<cfset arguments.registrationScope._register(arguments.context.model(model))>
				</cfloop>
			</cfif>
			<cfif isDefined("autoregister.modules")>
				<cfloop array="#autoregister.modules#" index="module">
					<cfset arguments.registrationScope._register(this.app.module(module))>
				</cfloop>
			</cfif>
		</cfif>

	</cffunction>
	
	<cffunction name="getModules">
		<cfset var modules = "">
		<cfset var returnModules = []>
		<cfdirectory action="list" directory="#expandPath('/modules/')#" type="dir" name="modules">
		<cfloop query="modules">
			<cfset arrayAppend(returnModules,modules.name)>
		</cfloop>
		<cfreturn returnModules>
	</cffunction>
	
	<cffunction name="getAssetPreProcessors">
		<cfset var modules = "">
		<cfset var returnProcessors = []>
		<cfdirectory action="list" directory="#expandPath('/system/assetpreprocessors/')#" type="dir" name="assetpreprocessors">
		<cfloop query="assetpreprocessors">
			<cfset arrayAppend(returnProcessors,assetpreprocessors.name)>
		</cfloop>
		<cfreturn returnProcessors>
	</cffunction>

}