<cfcomponent name="config" output="false" >
	<cffunction name="getConfig" access="private" output="false" hint="">
		<cfset response = structnew() />		
		<cfset response.datasources.absmysql = "absmysql" /> 
		<cfreturn response>
	</cffunction>
</cfcomponent>	
		
	
