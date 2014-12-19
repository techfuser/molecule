<!---************************************************************************************
Filename: \Apps\cfc\admin\printFunctions.cfc
Created Date: N/A
File Purpose: 

History:

HB - 07/28/2011 - #1482 - changed sort order for CCI cartons
MA - 03/06/2013 - #2819 - consolidated calls
EF - 10/01/2014  - #4081 - changed from "public" to "remote"
************************************************************************************--->
<cfcomponent name="printFunctions" output="false">
	<cfinvoke component="config" method="getConfig" returnVariable="oConfig" /> 

	<cffunction name="getInventories" access="remote" output="false" returntype="Any">
		<cfstoredproc procedure="getInventories" datasource="#oConfig.datasources.absmysql#">
			<cfprocresult name="datasetInventories">
		</cfstoredproc>
	<cfreturn datasetInventories>
	</cffunction>
	
	<cffunction name="getSites" access="remote" output="false" returntype="Any">
		<cfstoredproc procedure="getSites" datasource="#oConfig.datasources.absmysql#">
			<cfprocresult name="datasetSites">
		</cfstoredproc>
	<cfreturn datasetSites>
	</cffunction>
	
	<cffunction name="getSitesByInventoryID" access="remote" output="false" returntype="Any">
		<cfargument name="vInventoryID" type="String">
		<cfstoredproc  procedure="getSitesByInventoryID" datasource="#oConfig.datasources.absmysql#">
			<cfprocparam cfsqltype="CF_SQL_VARCHAR" dbvarname="vInventoryID" value="#vInventoryID#">
			<cfprocresult name="datasetSemesters">
		</cfstoredproc>
		<cfreturn datasetSemesters>
	</cffunction>

	<cffunction name="getInventoryByInventoryIdBySiteID" access="remote" output="false" returntype="Any">
		<cfargument name="vInventoryID" type="String" >
		<cfargument name="vSiteID" type="String" >
		<cfargument name="vCarton" type="String" >
    <cfargument name="vSiteName" type="String">
    
    
		<cfstoredproc  procedure="getInventoryByInventoryIdBySiteID" datasource="#oConfig.datasources.absmysql#">

			<cfprocparam cfsqltype="CF_SQL_VARCHAR" value="#vInventoryID#" >
			<cfprocparam cfsqltype="CF_SQL_VARCHAR" value="#vSiteID#" >
			<cfprocparam cfsqltype="CF_SQL_VARCHAR" value="#vCarton#" >
      
			<cfif vSiteName EQ 'Everest CCI Autofill' OR vSiteName EQ 'BioHealth Autofill'>
      	<cfprocparam cfsqltype="CF_SQL_VARCHAR"  value="Consolidated">
			<cfelse>
      	<cfprocparam cfsqltype="CF_SQL_VARCHAR"  value="NonConsolidated">      
      </cfif>
      
      <cfprocparam cfsqltype="CF_SQL_VARCHAR" value="#vSiteName#">
      
			<cfprocresult name="datasetInventory">
		</cfstoredproc>
		<cfreturn datasetInventory>
	</cffunction>
	
	<cffunction name="getInventoryCartonsBySitesByInventoryId" access="remote" output="false" returntype="Any">
		<cfargument name="vInventoryId" type="String">
		<cfargument name="vSiteID" type="String">
		<cfstoredproc  procedure="getInventoryCartonsBySitesByInventoryId" datasource="#oConfig.datasources.absmysql#">
			<cfprocparam cfsqltype="CF_SQL_VARCHAR" dbvarname="vInventoryID" value="#arguments.vInventoryId#">
			<cfprocparam cfsqltype="CF_SQL_VARCHAR" dbvarname="vSiteID" value="#arguments.vSiteID#">
			<cfprocresult name="datasetInventory">
		</cfstoredproc>
		<cfquery dbtype="query" name="siteQuery">
			SELECT DISTINCT SiteName,SiteID FROM datasetInventory ORDER BY SiteName
		</cfquery>
		<cfquery dbtype="query" name="cartonQuery">
			SELECT DISTINCT SiteName,Carton FROM datasetInventory ORDER BY SiteName,Carton
		</cfquery>
		<cfxml variable="xResponse" >
        	<RESPONSE>                   
        		<cfloop query="siteQuery" >
        			<cfoutput>
					<cfset sSiteName = Replace(#siteQuery.SiteName#,"&","&amp;")>
					<SITENAME label="#sSiteName#" id="#siteQuery.SiteID#">
        			<cfloop query="cartonQuery">
        				<cfif cartonQuery.SiteName eq siteQuery.SiteName>
							<cfset sCarton = Replace(#cartonQuery.Carton#,"&","&amp;")>
							<CARTON label="#sCarton#" id="#sCarton#"/>
        				</cfif>
        			</cfloop>
        			</SITENAME>   
					</cfoutput>       
        		</cfloop>
        	</RESPONSE>
        </cfxml>
		<cfset response.data = xResponse>
		<cfreturn response>
	</cffunction>

	<cffunction name="getInventoryCartonsBySiteIds" access="remote" output="false" returntype="Any">
		<cfargument name="vSiteID" type="String">
    <cfargument name="vSiteName" type="String">
    
		<cfstoredproc  procedure="getInventoryCartonsBySiteIds" datasource="#oConfig.datasources.absmysql#">
			<cfprocparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.vSiteID#">
      
     <cfif vSiteName EQ 'Everest CCI Autofill' OR vSiteName EQ 'BioHealth Autofill'>
      	<cfprocparam cfsqltype="CF_SQL_VARCHAR"  value="Consolidated">
			<cfelse>
      	<cfprocparam cfsqltype="CF_SQL_VARCHAR"  value="NonConsolidated">      
      </cfif>
      <cfprocparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.vSiteName#">
      
			<cfprocresult name="datasetInventory">
		</cfstoredproc>
    
   
		<cfquery dbtype="query" name="siteQuery">
			SELECT DISTINCT SiteName,SiteID FROM datasetInventory ORDER BY SiteName
		</cfquery>
		  
    <cfquery dbtype="query" name="cartonQuery">
			SELECT DISTINCT SiteName,Carton FROM datasetInventory 
      ORDER BY SiteName,
      <cfif vSiteName EQ 'Everest CCI Autofill' OR vSiteName EQ 'BioHealth Autofill'>sortorder<cfelse>carton</cfif>
		</cfquery>
    
		<cfxml variable="xResponse" >
        	<RESPONSE>                   
        		<cfloop query="siteQuery" >
        			<cfoutput>
					<cfset sSiteName = Replace(#siteQuery.SiteName#,"&","&amp;")>
					<SITENAME label="#sSiteName#" id="#siteQuery.SiteID#">
        			<cfloop query="cartonQuery">
        				<cfif cartonQuery.SiteName eq siteQuery.SiteName>
							<cfset sCarton = Replace(#cartonQuery.Carton#,"&","&amp;")>
							<CARTON label="#sCarton#" id="#sCarton#"/>
        				</cfif>
        			</cfloop>
        			</SITENAME>   
					</cfoutput>       
        		</cfloop>
        	</RESPONSE>
        </cfxml>
		<cfset response.data = xResponse>
		<cfreturn response>
	</cffunction>

</cfcomponent>