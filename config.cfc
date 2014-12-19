<cfcomponent name="config" output="false" >
	<cffunction name="getConfig" access="public" output="true" hint="return mysql db info">
		<cfset response = structnew() />		
		<cfset response.datasources.absmysql = "absmysql" /> 
		<cfreturn response>
	</cffunction>
</cfcomponent>	
		
	
