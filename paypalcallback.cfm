<!---
************************************************************************************
Filename: /ob/paypalcallback.cfm
Created Date: 02/23/2016
File Purpose: This is the processe file to hand paypal token, iframe, and auth

History: 
************************************************************************************
--->

<cftry>
	
	<!--- Get Auth requested --->
	<cfset A_PP_RESPONSE = GetHttpRequestData().content>
	
	<cfif LEN(A_PP_RESPONSE) GT 0>
	
		<cfset session.PayPal.paypalCallbackRelocateTo="">
		<cfset session.PayPal.paypalCallbackRelocateErrCode="">
		
		<cfquery name="PayPalLog" datasource="absmysql">
			INSERT INTO Logs.PayPalLog(TrasanctionType,PayLoad,Type,IPaddress, SiteID, StudentID) 
			VALUES('A','#A_PP_RESPONSE#','Response','#cgi.REMOTE_ADDR#', <cfif isDefined('session.ob_site.SiteID')>#session.ob_site.SiteID#<cfelse>NULL</cfif>, <cfif isDefined('session.ob_users.StudentID')>'#session.ob_users.StudentID#'<cfelse>NULL</cfif>) 
		</cfquery>
		
		<cfset A_SECURETOKENID="SECURETOKENID=([^&]*)">
		<cfset A_PNREF="PNREF=([^&]*)">
		<cfset A_MSG="RESPMSG=([^&]*)">
		<cfset A_RESULT_CODE="RESULT=([^&]*)">
		<cfset A_AVSZIP="AVSZIP=([^&]*)">
		<cfset A_CVV2MATCH="CVV2MATCH=([^&]*)">
		<cfset A_MATCH_SECURETOKENID=REFindNoCase(A_SECURETOKENID,A_PP_RESPONSE,1,true)>
		<cfset A_MATCH_PNREF=REFindNoCase(A_PNREF,A_PP_RESPONSE,1,true)>
		<cfset A_MATCH_MSG=REFindNoCase(A_MSG,A_PP_RESPONSE,1,true)>
		<cfset A_MATCH_RESULT=REFindNoCase(A_RESULT_CODE,A_PP_RESPONSE,1,true)>
		<cfset A_MATCH_AVSZIP=REFindNoCase(A_AVSZIP,A_PP_RESPONSE,1,true)>
		<cfset A_MATCH_CVV2MATCH=REFindNoCase(A_CVV2MATCH,A_PP_RESPONSE,1,true)>
		<cfif A_MATCH_SECURETOKENID.len[1]>
			<cfset A_SECURETOKENID=mid(A_PP_RESPONSE,A_MATCH_SECURETOKENID.pos[2],A_MATCH_SECURETOKENID.len[2])>
		</cfif>
		<cfif A_MATCH_PNREF.len[1]>
			<cfset A_PNREF_CODE=mid(A_PP_RESPONSE,A_MATCH_PNREF.pos[2],A_MATCH_PNREF.len[2])>
		</cfif>
		<cfif A_MATCH_MSG.len[1]>
			<cfset A_RESPMSG=mid(A_PP_RESPONSE,A_MATCH_MSG.pos[2],A_MATCH_MSG.len[2])>
		</cfif>
		<cfif A_MATCH_RESULT.len[1]>
			<cfset A_RESULT=mid(A_PP_RESPONSE,A_MATCH_RESULT.pos[2],A_MATCH_RESULT.len[2])>
		</cfif>
		<cfif A_MATCH_AVSZIP.len[1]>
			<cfset A_AVSZIP=mid(A_PP_RESPONSE,A_MATCH_AVSZIP.pos[2],A_MATCH_AVSZIP.len[2])>
		</cfif>
		<cfif A_MATCH_CVV2MATCH.len[1]>
			<cfset A_CVV2MATCH=mid(A_PP_RESPONSE,A_MATCH_CVV2MATCH.pos[2],A_MATCH_CVV2MATCH.len[2])>
		</cfif>
		
		<!--- Invalid Token --->
		<cfif isDefined('A_SECURETOKENID') AND isDefined('session.paypal.SecureTokenID') AND compareNoCase(A_SECURETOKENID,session.paypal.SecureTokenID) NEQ 0>
			
			<!--- Redirection marker divs ---->
			<div id="paypalCallbackRelocate">TRUE</div>
			<div id="paypalCallbackRelocateTo">Course</div>
		
			<cfset session.PayPal.paypalCallbackRelocateTo="Course">
			<cfset session.PayPal.paypalCallbackRelocateErrCode="CCTokenFailed">
			
			<!--- valid --->
		<cfelseif isDefined('A_RESULT') AND A_RESULT EQ 0 AND isDefined('A_RESPMSG') AND compareNoCase(A_RESPMSG,"Approved") EQ 0 AND compareNoCase(A_AVSZIP,"N") NEQ 0 AND compareNoCase(A_CVV2MATCH,"N") NEQ 0>
			<cfset session.PayPal.A_PP_RESPONSE = A_PP_RESPONSE>
			<cfset session.PayPal.A_PNREF_CODE = A_PNREF_CODE>
			<cfset session.PayPal.A_RESPMSG = A_RESPMSG>
			<cfset session.PayPal.A_RESULT = A_RESULT>
			
			
			<!---  Redirection marker divs - do PayPal charge ---->
			<div id="paypalCallbackRelocate">FALSE</div>
			<div id="paypalCallbackRelocateTo"></div>

			<!--- perform charge via ajax --->
			
		<!--- Validation failed for Result/A_RESPMSG/A_AVSZIP--->	
		<cfelse>
			<cfset session.PayPal.A_PP_RESPONSE = A_PP_RESPONSE>
			<cfset session.PayPal.A_PNREF_CODE = A_PNREF_CODE>
			<cfset session.PayPal.A_RESPMSG = A_RESPMSG>
			<cfset session.PayPal.A_RESULT = A_RESULT>
			
			<!--- Void if A_RESULT = 0 and A_RESPMSG is Approved  --->
			<cfif session.PayPal.A_RESULT EQ 0 AND compareNoCase(session.PayPal.A_RESPMSG,"Approved") EQ 0>
				<cfinclude template="/private/process/process_voidAuth.cfm">
			</cfif>
			
			<!--- Redirection marker divs ---->
			<div id="paypalCallbackRelocate">TRUE</div>
			<div id="paypalCallbackRelocateTo">Billing</div>
			
			<cfset session.PayPal.paypalCallbackRelocateTo="Billing">
			<cfset session.PayPal.paypalCallbackRelocateErrCode="CCFailed">
			
		</cfif>
		
	<cfelse>
		<!--- Do nothing - Page invoked directly --->
	</cfif>
	
<cfcatch>

	<cfset PayPalError ="Error processing ORDER against PayPal. "&cfcatch.Message&" "&cfcatch.Detail>
	
	<cfif isDefined('session.ob_site.SiteID') AND isDefined('session.ob_users.StudentID')>

		<cfquery name="PayPalLog" datasource="ob">
			INSERT INTO Logs.PayPalLog(PayLoad,Type,IPaddress,SiteID,StudentID) 
			VALUES('#PayPalError#','Error','#cgi.REMOTE_ADDR#',<cfif isDefined('session.ob_site.SiteID')>#session.ob_site.SiteID#<cfelse>NULL</cfif>, <cfif isDefined('session.ob_users.StudentID')>'#session.ob_users.StudentID#'<cfelse>NULL</cfif>) 
		</cfquery>
		
		<!--- Redirection marker divs ---->
		<div id="paypalCallbackRelocate">TRUE</div>
		<div id="paypalCallbackRelocateTo">Course</div>
		
		<cfset session.PayPal.paypalCallbackRelocateTo="Course">
		<cfset session.PayPal.paypalCallbackRelocateErrCode="CCTokenFailed">
	
	<cfelse>

		<cfquery name="PayPalLog" datasource="ob">
			INSERT INTO Logs.PayPalLog(PayLoad,Type,IPaddress) 
			VALUES('#PayPalError#','Error','#cgi.REMOTE_ADDR#') 
		</cfquery>
		
		<!--- Redirection marker divs ---->
		<div id="paypalCallbackRelocate">TRUE</div>
		<div id="paypalCallbackRelocateTo">Home</div>
		
		<cfset session.PayPal.paypalCallbackRelocateTo="Home">
		<cfset session.PayPal.paypalCallbackRelocateErrCode="NotLoggedIn">
		
	</cfif>

</cfcatch>
</cftry>
