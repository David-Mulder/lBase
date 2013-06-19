<cfcomponent>

	<cffunction name="view" output="true">
		<cfargument name="fullpath">
		<cfargument name="viewer">
		<cfargument name="data" default="#{}#">
		<cfargument name="output" default="#true#">

		<!---<cfif arguments.output>
			<cfinclude template="#arguments.fullpath#">
		<cfelse>
			<cfsavecontent variable="view"><cfinclude template="#arguments.fullpath#"></cfsavecontent>
			<cfreturn view>
		</cfif>--->
		
		<cfset var viewercomponent = this.lbase.createObject("system.viewers."&arguments.viewer&".viewer","instance")>
		<cfset viewercomponent.app = this.app>
		<cfif isDefined("this.mod")>
			<cfset viewercomponent.mod = this.mod>
		</cfif>
		<cfset viewercomponent.lbase = this.lbase>

		<cfif not directoryExists(expandPath('/system/cache/views/'&arguments.viewer))>
			<cfdirectory directory="#expandPath('/system/cache/views/'&arguments.viewer)#" action="create">
		</cfif>
		<cfset var cachefilename = '/system/cache/views/'&arguments.viewer&'/'&hash(arguments.fullpath)&'.cfm'>
		<cfset var cachefile = createObject("java","java.io.File").init(expandPath(cachefilename))>
		<cfset var sourcefile = createObject("java","java.io.File").init(expandpath(arguments.fullpath))>
		<cfset var sourcetime = sourcefile.lastModified()>
		<cfif not sourcefile.exists()>
			<cfset this.lbase.error(404,"View of page not found","View #arguments.fullpath# not found")><cfabort>
		</cfif>
		<cfif not cachefile.exists()>
			<cfset cachefile.createNewFile()>
			<cfset var cachetime = 0>
		<cfelse>
			<cfset var cachetime = cachefile.lastModified()>
		</cfif>

		<cfif Abs(sourcetime-cachetime) gt 1000>
			<cfset var fu = createObject("java","org.apache.commons.io.FileUtils")>
			<cfset var cfml = fu.readFileToString(sourcefile)>
			<cfset cfml = viewercomponent.parse(cfml)>
			<cfset var fw = createObject("java","java.io.FileWriter").init(cachefile)>
			<cfset var bw = createObject("java","java.io.BufferedWriter").init(fw)>
			<cfset bw.write(cfml)>
			<cfset bw.close()>
			<cfset cachefile.setLastModified(sourcetime)>
		</cfif>

		<cfif arguments.output>
			<cfset viewercomponent.execute(cachefile,cachefilename,arguments.data)>
		<cfelse>
			<cfsavecontent variable="view"><cfset viewercomponent.execute(cachefile,cachefilename,arguments.data)></cfsavecontent>
			<cfreturn view>
		</cfif>
		
		<!---<cfoutput>#render(cfml)#</cfoutput>--->

	</cffunction>

</cfcomponent>