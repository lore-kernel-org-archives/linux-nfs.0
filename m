From: ltd777@ins-america1.com
Subject: It Happens!! What do you do, who do you call,
	what will it cost??? FREE QUOTE
Date: Tue, 12 Jun 2007 11:42:33 -0600
Message-ID: <brot6i7p540t7s7x2.vfpw6x7q8kcu7ps@ins-america1.com>
Content-Type: multipart/mixed; boundary="===============0130866120=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hy9Rx-0005OA-0z
	for nfs@lists.sourceforge.net; Tue, 12 Jun 2007 09:42:33 -0700
Received: from mail.ins-america1.com ([67.19.27.226] helo=ins-america1.com)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Hy9Ry-0007P2-5k
	for nfs@lists.sourceforge.net; Tue, 12 Jun 2007 09:42:36 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0130866120==
Content-Type: text/html;
	 charset="us-ascii"
Content-Transfer-Encoding: 7BIT

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<script language="javascript1.1">

function getFormattedmsg(sVal)
{
	while(sVal.indexOf("_")!=-1)
	{
		sVal = sVal.replace("_", " ")
	}
	return sVal;
	
}

function fnFixSpace(sFldval)
{
	//created on: 10th May 2002
	//Programmer: Prashant Sharma
	//Purpose	: This function is used to remove spaces. 
	//Arguments : text field object value
	var sTemp=sFldval;
  var sReversedString="";
  var sTemp1;
  
  //remove spaces from the front
  sNewval = fnRemoveSpaces(sTemp);
  
  // reverse n remove spaces from the front
  for(var i=sNewval.length-1;i>=0;i--)
		sReversedString = sReversedString + sNewval.charAt(i);
	sTemp1 = fnRemoveSpaces(sReversedString);
	//reverse again
	sReversedString="";
	for(var i=sTemp1.length-1;i>=0;i--)
		sReversedString = sReversedString + sTemp1.charAt(i);
	sNewval = sReversedString;
	return sNewval;
}

function fnRemoveSpaces(sFldval)
{
	var sTemp=sFldval;
  var sNewval=sTemp;
  //remove spaces from the front
  for(var i=0;i<sTemp.length;i++)
  {	
		if(sTemp.charAt(i)!=" ")
			break;
		else
			sNewval = sTemp.substring(i+1);
	}
	return sNewval;
}

function ValidateEMail(objName)
{
	
	
	//created on: 12th May 2002
	//Programmer: Prashant Sharma
	//Purpose	: This function is used to validate email. 
	//Arguments : Email object
		
	var sobjValue;
	var iobjLength;
	
	sobjValue=objName;
	iobjLength=sobjValue.length;
	iFposition=sobjValue.indexOf("@");
	iSposition=sobjValue.indexOf(".");
	iTmp=sobjValue.lastIndexOf(".");	
	iPosition=sobjValue.indexOf(",");
	iPos=sobjValue.indexOf(";");
	
	if (iobjLength!=0)
	{
		if ((iFposition == -1)||(iSposition == -1))
		{
			return false;
		}
		else if(sobjValue.charAt(0) == "@" || sobjValue.charAt(0)==".")
		{
			return false;				
		}
		else if(sobjValue.charAt(iobjLength) == "@" ||
sobjValue.charAt(iobjLength)==".")
		{
			return false;				
		}	
		else if((sobjValue.indexOf("@",(iFposition+1)))!=-1)
		{	
			return false;
		}
		else if ((iobjLength-(iTmp+1)<2)||(iobjLength-(iTmp+1)>3))
		{
			return false;
		}
		else if ((iPosition!=-1) || (iPos!=-1))
		{
			return false;
		}
		else
		{
			return true;
		}		
	}		
}


/*----------------------------------------------------------------------------------------------------------------------
	this sub routine checks for the mandatory fields, their data types and maximum length
	also validates valid email entered or not
	Return : True/False
	Input : objFrm ( form object name)
	Version : 1.0.0
	
	
	Object Name=TR_     				means Required Field For Text          					Object Type=text
	Object Name=TR_    					means Required Field For Text          					Object Type=textarea
	Object Name=TR_    					means Required Field For Valid Password     			Object Type=Password
	Object Name=TR_Confirm_Password		means Required Field For Valid Confirm Password    		Object Type=Password
	
	Object Name=IR_     				means Required Field For Number							Object Type=text
	Object Name=IN_     				means not Required Field For Number						Object Type=text
	Object Name=TREF_   				means Required Field For Valid Email					Object Type=text
	Object Name=TNEF_   				means not Required Field For Valid Email				Object Type=text
	------------------------------------------------------------------------------------------------------------------*/
function ValidateForm(objFrm)
{
	var iConventionPos;
	var sChangedName;
	for( var i =0; i< objFrm.length;i++)
	{
		if(objFrm[i].type=='text' || objFrm[i].type=='textarea' || objFrm[i].type=='select-one' || objFrm[i].type=='select-multiple' || objFrm[i].type=='password')
		{
			if(objFrm[i].type=='text' || objFrm[i].type=='textarea' || objFrm[i].type=='password')
				objFrm[i].value = fnFixSpace(objFrm[i].value);
			
			var objDataTypeHolder = objFrm[i].name.substring(0,3);
			if(objFrm[i].name.substring(0,5)=='TREF_' || objFrm[i].name.substring(0,5)=='TNEF_')
				objDataTypeHolder = objFrm[i].name.substring(0,5);
			if((objFrm[i].type=='select-one' && objFrm[i].options[objFrm[i].selectedIndex].value=='' && objDataTypeHolder=="TR_"))
			{
				sChangedName = objFrm[i].name.substring(3);
				sChangedName = getFormattedmsg(sChangedName)
				alert("Please select "+ sChangedName +".");
				objFrm[i].focus();
				return false;
				break;
			}

			if((objDataTypeHolder=="TR_" || objDataTypeHolder=="IR_" || objDataTypeHolder=="MR_"  )&& (objFrm[i].value==''))
			{	
				sChangedName = objFrm[i].name.substring(3);
				sChangedName = getFormattedmsg(sChangedName)
				alert("Please enter "+ sChangedName +".");
				objFrm[i].focus();
				return false;
				break;
			}
			if(objDataTypeHolder=="TREF_" && objFrm[i].value=='')
			{
				alert("Please enter email.");
				objFrm[i].focus();
				objFrm[i].select();
				return false;
				break;
			}
						
			if((objDataTypeHolder=="IN_" || objDataTypeHolder=="MN_" )&& (isNaN(objFrm[i].value) && objFrm[i].value!='' ))
			{
				sChangedName = objFrm[i].name.substring(3);
				sChangedName = getFormattedmsg(sChangedName)
				alert("Please enter numeric "+ sChangedName +".");
				objFrm[i].focus();
				objFrm[i].select();
				return false;
				break;
			}
			
			if((objDataTypeHolder=="TREF_") || (objDataTypeHolder=="TNEF_" && objFrm[i].value!='' ))
			{
				if(!ValidateEMail(objFrm[i].value))
				{
					alert("Please enter valid email.");
					objFrm[i].focus();
					objFrm[i].select();
					return false;
					break;
				}
			}
			
			
		}
	}
	return true;
}

</script>
<body>
<form action="http://www.ins-america1.com/a/sendemail.asp" method="post" onSubmit="javascript:return ValidateForm(this);">
<!--
	Object Name=TR_     				means Required Field For Text          	
	Object Name=TN_     				means Not Required Field For Text   
	
	Object Name=IR_     				means Required Field For Number				Object Type=text
	Object Name=IN_     				means not Required Field For Number			Object Type=text
	
	Object Name=TREF_   				means Required Field For Valid Email		Object Type=text
	
	KEEP THE EMAIL FIELD NAME AS "TREF_Email"
-->
<table width="400" border="0" align="center" cellpadding="0" cellspacing="1" bgcolor="#000000">
  <tr>
    <td><table width="400" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td bgcolor="#FFFFFF"><img src="http://www.ins-america1.com/a/images/ad.jpg" width="497" height="513"></td>
        </tr>
        <tr>
          <td align="center" bgcolor="#083681"><TABLE cellSpacing=1 cellPadding=2 width="97%" bgColor=#0066CC 
            border=0>
              <TBODY>
                <TR align=left bgColor=#083681> 
                  <TD><FONT color="#FFFFFF" size=2 face="Arial, Helvetica, sans-serif">Business 
                    Name </FONT></TD>
                  <TD><FONT color="#FFFFFF" size=2 face="Arial, Helvetica, sans-serif"> 
                    <INPUT 
                  size=15 name="TR_Business_Name">
                    </FONT></TD>
                  <TD><FONT color="#FFFFFF" 
                  size=2 face="Arial, Helvetica, sans-serif">Contact</FONT></TD>
                  <TD><FONT face="Verdana, Arial, Helvetica, sans-serif" size=1> 
                    <INPUT 
                  size=15 name="TN_Contact">
                    </FONT></TD>
                </TR>
                <TR align=left bgColor=#083681> 
                  <TD><FONT color="#FFFFFF" 
                  size=2 face="Arial, Helvetica, sans-serif">Email</FONT></TD>
                  <TD><FONT color="#FFFFFF" size=2 face="Arial, Helvetica, sans-serif"> 
                    <INPUT 
                  size=15 name="TREF_Email">
                    </FONT></TD>
                  <TD><FONT color="#FFFFFF" 
                  size=2 face="Arial, Helvetica, sans-serif">Phone</FONT></TD>
                  <TD><FONT face="Verdana, Arial, Helvetica, sans-serif" size=1> 
                    <INPUT 
                  size=15 name="TN_Phone">
                    </FONT></TD>
                </TR>
                <TR align=left bgColor=#083681> 
                  <TD><FONT color="#FFFFFF" 
                  size=2 face="Arial, Helvetica, sans-serif">Printer</FONT></TD>
                  <TD><FONT color="#FFFFFF" size=2 face="Arial, Helvetica, sans-serif"> 
                    <SELECT 
                  name="TN_Printer">
				  	  <OPTION value="">-select-</OPTION>
                      <OPTION>HP</OPTION>
                      <OPTION>Lexmark</OPTION>
                      <OPTION>Okidata</OPTION>
                      <OPTION>Brother</OPTION>
                    </SELECT>
                    </FONT></TD>
                  <TD><FONT color="#FFFFFF" size=2 face="Arial, Helvetica, sans-serif">Model 
                    # </FONT></TD>
                  <TD><FONT face="Verdana, Arial, Helvetica, sans-serif" size=1> 
                    <INPUT 
                  size=15 name="TN_Model">
                    </FONT></TD>
                </TR>
                <TR align=center bgColor=#083681> 
                  <TD 
              colSpan=4><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> 
                    <INPUT type=submit value=Submit name=Submit>
                    </font></TD>
                </TR>
              </TBODY>
            </TABLE></td>
        </tr>
      </table></td>
  </tr>
</table></form>
<div align="center"><br>
  <FONT face="Arial, Helvetica, sans-serif" 
            size=1>Business Partners<br>
  <img src="http://www.ins-america1.com/a/images/hp.jpg" width="60" height="50" align="absmiddle"><img src="http://www.ins-america1.com/a/images/brother.jpg" width="59" height="54" hspace="3" align="absmiddle"></FONT> 
  <img src="http://www.ins-america1.com/a/images/lexmark.jpg" width="111" height="43" align="absmiddle"> <img src="http://www.ins-america1.com/a/images/oki_logo.gif" hspace="3" align="absmiddle"></div>
<p align="center"><font face="Arial" color="#000080" size="1">You are receiving 
this message as an opt-in subscriber to Ins America or one of our marketing 
partners. <br>
If you no longer wish to receive further offers, please send an email with 
discontinue to: <a href="mailto:support@ins-america1.com?subject=Discontinue">
support@ins-america1.com</a><br>
Your email address will be removed within 24 hours.</font></p>
<p align="center"><font face="Arial" color="#000080" size="1"><br>
Ins America<br>
137 74th Street<br>
North Bergen, NJ <br>
07047</font></p>
</body>
</html>



--===============0130866120==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0130866120==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0130866120==--
