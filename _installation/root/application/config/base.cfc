<cfcomponent extends="system.config.base">
	<cfset config["baseurl"] = "http://192.168.1.117:8080/lbase/">
		
	<cfset config["autoregister"] = {}>
	<cfset config["autoregister"]["libraries"] = ["modules.core.console"]>
	<cfset config["autoregister"]["modules"] = ["core","template","mongo"]>
		
	<cfset config["defaultViewer"] = "html">
</cfcomponent>