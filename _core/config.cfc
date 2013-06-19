<cfcomponent>

	<cfset this.basepath = "">
	<cfset this.context = "">

	<cffunction name="init">
		<cfset directory = expandPath("/"&replace(this.basepath,".","/","all")&"/config/")>
		<cfif directoryExists(directory)>
			<cfset arr_configFiles = directoryList(path=directory,recurse=false,filter="*.cfc",listinfo="name")>
			<cfloop from="1" to="#arrayLen(arr_configfiles)#" index="configFileI">
				<cfset configFilename = arr_configfiles[configFileI]>
				<cfset configName = left(configFilename,len(configFilename)-4)>
				<!---<cfset this[configName] = createObject("application.config."&configName).getConfig()>--->
				<cfset this[configName] = this.lbase.createObject(this.basepath&".config."&configName,"application").getConfig(context=this.context)>
			</cfloop>
			<cfset structDelete(this,"init")>
		</cfif>
		<cfreturn this>
	</cffunction>

</cfcomponent>