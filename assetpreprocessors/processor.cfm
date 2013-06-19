<cfcontent reset="yes"><cfsetting enableCFoutputOnly="yes">

<cfset request.page = "">
<cfset app = createObject("system.base").createApp()>
<cfset console = app.module("core").lib("console")>	
<cfif not directoryExists(expandPath('/system/cache/assets/'&request.processor&'/'))>
	<cfdirectory directory="#expandPath('/system/cache/assets/'&request.processor&'/')#" action="create">
</cfif>
	
<cfset cachefilename = '/system/cache/assets/'&request.processor&'/'&hash(request.asset)><cfset cachefile = createObject("java","java.io.File").init(expandPath(cachefilename))>
<cfset sourcefile = createObject("java","java.io.File").init(expandpath(request.asset))>
<cfset sourcetime = sourcefile.lastModified()><cfif not sourcefile.exists()>	<cfset console.log(request.asset)>
	<cfcontent reset="yes"><cfheader statuscode="404" statustext="Not Found :(" /><cfabort>
</cfif>
<cfif not cachefile.exists()>
	<cfset cachefile.createNewFile()>
	<cfset cachetime = 0>
<cfelse>
	<cfset cachetime = cachefile.lastModified()>
</cfif>
<cfset fu = createObject("java","org.apache.commons.io.FileUtils")>
<cfset processor = createObject(request.processor&".processor")><cfif Abs(sourcetime-cachetime) gt 1000 or isDefined("url.restart")>
	<cfset sourcecode = fu.readFileToString(sourcefile)>
	<cfset processor.app = app>	<cfset result = processor.process(		content=sourcecode,		label=request.asset,		rootPath=replace(sourcefile.getParent(),"\","/","all"),		publicRootPath=app.config.base.baseurl&request.publicRootPath	)>
	
	<cfset fw = createObject("java","java.io.FileWriter").init(cachefile)>
	<cfset bw = createObject("java","java.io.BufferedWriter").init(fw)>
	<cfset bw.write(result)>
	<cfset bw.close()>
	<cfset cachefile.setLastModified(sourcetime)>
</cfif>
<cfset code = fu.readFileToString(cachefile)><cfcontent type="#processor.type#">
<cfoutput>#code#</cfoutput>