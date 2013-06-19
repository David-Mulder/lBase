<cfcomponent>
	
	<cfset this.type = "text/css">
	
	<cffunction name="process">
		<cfargument name="content">
		<cfargument name="label">
		<cfargument name="rootPath">
		<cfargument name="publicRootPath">

		<cfset wehazerror = false>

		<cfset var lesscode = arguments.content>
		<cfscript language="java" jarlist="js.jar">
			import org.mozilla.javascript.*;
			import java.io.*;
			
			org.mozilla.javascript.Context cx = org.mozilla.javascript.Context.enter();
			Scriptable scope = cx.initStandardObjects();
			
			String filename = (String) cf.call("expandpath","./less/less.js");
			
			BufferedReader br = new BufferedReader(new FileReader(filename));
			try {
		        StringBuilder sb = new StringBuilder();
		        String line = br.readLine();
		
		        while (line != null) {
		            sb.append(line);
		            sb.append("\n");
		            line = br.readLine();
		        }
		        
		        String scriptcode = sb.toString();
		        
		        String lesscode = (String) cf.get("lesscode");
		    	
		    	try {
				
					Object result = cx.evaluateString(scope, scriptcode, "<cmd>", 1, null);
					
					Object fObj = scope.get("parse", scope);
					if (!(fObj instanceof Function)) {
					    System.out.println("f is undefined or not a function.");
					} else {
					    Object functionArgs[] = { lesscode, cf.get("arguments.rootPath"), cf.get("arguments.publicRootPath") };
					    Function f = (Function)fObj;
					    NativeObject resultt = (NativeObject) f.call(cx, scope, scope, functionArgs);
					    cf.set("resultt",resultt.get("d",resultt));
					    Boolean wehazerror = (Boolean) resultt.get("haserror",resultt);
					    cf.set("wehazerror",wehazerror);
					  	if(wehazerror){
						    Object json = NativeJSON.stringify(cx, scope, resultt, null, null);
					  		cf.set("error",json);
					  	}else{
					  		cf.set("css",resultt.get("css",resultt));
					  	}
					    
					}
					
				} finally {
					// Exit from the context.
					org.mozilla.javascript.Context.exit();
				}
		        	
		        
		    } finally {
		        br.close();
		    }
		</cfscript>
		<cfif wehazerror>
			<cfset str_error = DeserializeJSON(error).e>
			<cfset var console = this.app.module("core").lib("console")>
			<cfset console.groupStart(label="#arguments.label#: #str_error.type# error encountered",forcelabel="true")>
				<cfset console.error(label="Message",msg=str_error.message)>
				<cfset console.debug(label="Location",msg=arguments.label&":"&str_error.line)>
				<cfset console.debug(label="Extract",msg=str_error.extract)>
				<cfset console.debug(label="Full error",msg=str_error)>
			<cfset console.groupEnd()>
			<cfabort>
		<cfelse>
			<cfreturn replace(css,"\n","#chr(10)##chr(13)#","all")>
		</cfif>
	</cffunction>
	
</cfcomponent>