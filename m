From: Vinay Kaval <vkaval@z-force.com>
Subject: RE: TCP Patches for NFS ver 3.0
Date: Fri, 25 Jul 2003 11:39:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <FD5123AC079C844396A2E2BA89BF796E084DD8@zfsmail.z-force.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C352DB.F8AE6500"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [65.223.53.1] (helo=zfimc.z-force.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19g7TX-0003Km-00
	for <nfs@lists.sourceforge.net>; Fri, 25 Jul 2003 11:39:31 -0700
To: "'Nelson, Allan'" <anelson@midf.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C352DB.F8AE6500
Content-Type: text/plain

Hi Nelson,
   I am using RH 7.3 and this kernel viz : 2.4.18-3 does not have inbuilt
tcp support, The  Config.in file does not have an option to enable TCP
support, so the kernel cannot be complied to support TCP without some
patches applied.
 
Correct me if I am wrong....
 
Thx
--Vinay
 
-----Original Message-----
From: Nelson, Allan [mailto:anelson@midf.com] 
Sent: Friday, July 25, 2003 11:17 AM
To: Vinay Kaval
Subject: RE: [NFS] TCP Patches for NFS ver 3.0
 
Did you rebuild the kernel to support TCP serving for NFS?
-----Original Message-----
From: Vinay Kaval [mailto:vkaval@z-force.com] 
Sent: Friday, July 25, 2003 1:07 PM
To: 'nfs@lists.sourceforge.net'
Subject: [NFS] TCP Patches for NFS ver 3.0
Hi All,
  I am in urgent need for TCP patches for NFS. I am using Redhat 7.3 kernel:
2.4.18-3. I will appreciate any help in locating these.
 
Thanks in advance,
 
Regards
--Vinay
____________________________________________________________________________
__
This email is intended solely for the person or entity to which it is
addressed and may contain confidential and/or privileged information.
Copying, forwarding or distributing this message by persons or entities
other than the addressee is prohibited. If you have received this email in
error, please contact the sender immediately and delete the material from
any computer. This email may have been monitored for policy compliance.
[021216]


------_=_NextPart_001_01C352DB.F8AE6500
Content-Type: text/html
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:st1=3D"urn:schemas-microsoft-com:office:smarttags" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">


<meta name=3DProgId content=3DWord.Document>
<meta name=3DGenerator content=3D"Microsoft Word 10">
<meta name=3DOriginator content=3D"Microsoft Word 10">
<link rel=3DFile-List href=3D"cid:filelist.xml@01C352A1.A69300D0">
<title>Message</title>
<o:SmartTagType =
namespaceuri=3D"urn:schemas-microsoft-com:office:smarttags"
 name=3D"time"/>
<o:SmartTagType =
namespaceuri=3D"urn:schemas-microsoft-com:office:smarttags"
 name=3D"date"/>
<!--[if gte mso 9]><xml>
 <o:OfficeDocumentSettings>
  <o:DoNotRelyOnCSS/>
 </o:OfficeDocumentSettings>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:DocumentKind>DocumentEmail</w:DocumentKind>
  <w:EnvelopeVis/>
  <w:Compatibility>
   <w:BreakWrappedTables/>
   <w:SnapToGridInCell/>
   <w:WrapTextWithPunct/>
   <w:UseAsianBreakRules/>
  </w:Compatibility>
  <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel>
 </w:WordDocument>
</xml><![endif]--><!--[if !mso]>
<style>
st1\:*{behavior:url(#default#ieooui) }
</style>
<![endif]-->
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;
	text-underline:single;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;
	text-underline:single;}
span.EmailStyle17
	{mso-style-type:personal;
	mso-style-noshow:yes;
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-ascii-font-family:Arial;
	mso-hansi-font-family:Arial;
	mso-bidi-font-family:Arial;
	color:windowtext;}
span.EmailStyle18
	{mso-style-type:personal-reply;
	mso-style-noshow:yes;
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-ascii-font-family:Arial;
	mso-hansi-font-family:Arial;
	mso-bidi-font-family:Arial;
	color:navy;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.25in 1.0in 1.25in;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */=20
 table.MsoNormalTable
	{mso-style-name:"Table Normal";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	mso-style-noshow:yes;
	mso-style-parent:"";
	mso-padding-alt:0in 5.4pt 0in 5.4pt;
	mso-para-margin:0in;
	mso-para-margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";}
</style>
<![endif]-->
</head>

<body lang=3DEN-US link=3Dblue vlink=3Dpurple =
style=3D'tab-interval:.5in'>

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'>Hi Nelson,<br>
<span style=3D'mso-spacerun:yes'>&nbsp;&nbsp; </span>I am using RH 7.3 =
and this kernel <span
class=3DGramE>viz :</span> 2.4.18-3 does not have inbuilt tcp support, =
The<span
style=3D'mso-spacerun:yes'>&nbsp; </span>Config.in file does not have =
an option to enable
TCP support, so the kernel cannot be complied to support TCP without =
some patches
applied.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'><o:p>&nbsp;</o:p></span></font></p>=


<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'>Correct me if I am =
wrong....<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'><o:p>&nbsp;</o:p></span></font></p>=


<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'>Thx<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'>--Vinay<o:p></o:p></span></font></p=
>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'><o:p>&nbsp;</o:p></span></font></p>=


<p class=3DMsoNormal style=3D'margin-left:.5in'><font size=3D2 =
face=3DTahoma><span
style=3D'font-size:10.0pt;font-family:Tahoma'>-----Original =
Message-----<br>
<b><span style=3D'font-weight:bold'>From:</span></b> Nelson, Allan
[mailto:anelson@midf.com] <br>
<b><span style=3D'font-weight:bold'>Sent:</span></b> =
</span></font><st1:date
Month=3D"7" Day=3D"25" Year=3D"2003"><font size=3D2 face=3DTahoma><span =
style=3D'font-size:
 10.0pt;font-family:Tahoma'>Friday, July 25, =
2003</span></font></st1:date><font
size=3D2 face=3DTahoma><span =
style=3D'font-size:10.0pt;font-family:Tahoma'> </span></font><st1:time
Hour=3D"11" Minute=3D"17"><font size=3D2 face=3DTahoma><span =
style=3D'font-size:10.0pt;
 font-family:Tahoma'>11:17 AM</span></font></st1:time><font size=3D2 =
face=3DTahoma><span
style=3D'font-size:10.0pt;font-family:Tahoma'><br>
<b><span style=3D'font-weight:bold'>To:</span></b> Vinay Kaval<br>
<b><span style=3D'font-weight:bold'>Subject:</span></b> RE: [NFS] TCP =
Patches for
NFS ver 3.0</span></font></p>

<p class=3DMsoNormal style=3D'margin-left:.5in'><font size=3D3 =
face=3D"Times New Roman"><span
style=3D'font-size:12.0pt'><o:p>&nbsp;</o:p></span></font></p>

<div>

<p class=3DMsoNormal style=3D'margin-left:.5in'><font size=3D2 =
color=3Dblue face=3DArial><span
style=3D'font-size:10.0pt;font-family:Arial;color:blue'>Did you rebuild =
the
kernel to support TCP serving for NFS?</span></font><o:p></o:p></p>

</div>

<blockquote =
style=3D'margin-top:5.0pt;margin-right:0in;margin-bottom:5.0pt'>

<p class=3DMsoNormal =
style=3D'mso-margin-top-alt:0in;margin-right:0in;margin-bottom:
12.0pt;margin-left:.5in'><font size=3D2 face=3DTahoma><span =
style=3D'font-size:10.0pt;
font-family:Tahoma'>-----Original Message-----<br>
<b><span style=3D'font-weight:bold'>From:</span></b> Vinay Kaval
[mailto:vkaval@z-force.com] <br>
<b><span style=3D'font-weight:bold'>Sent:</span></b> =
</span></font><st1:date
Month=3D"7" Day=3D"25" Year=3D"2003"><font size=3D2 face=3DTahoma><span =
style=3D'font-size:
 10.0pt;font-family:Tahoma'>Friday, July 25, =
2003</span></font></st1:date><font
size=3D2 face=3DTahoma><span =
style=3D'font-size:10.0pt;font-family:Tahoma'> </span></font><st1:time
Hour=3D"13" Minute=3D"7"><font size=3D2 face=3DTahoma><span =
style=3D'font-size:10.0pt;
 font-family:Tahoma'>1:07 PM</span></font></st1:time><font size=3D2 =
face=3DTahoma><span
style=3D'font-size:10.0pt;font-family:Tahoma'><br>
<b><span style=3D'font-weight:bold'>To:</span></b> =
'nfs@lists.sourceforge.net'<br>
<b><span style=3D'font-weight:bold'>Subject:</span></b> [NFS] TCP =
Patches for NFS
ver 3.0</span></font><o:p></o:p></p>

<p class=3DMsoNormal style=3D'margin-left:.5in'><font size=3D2 =
face=3DArial><span
style=3D'font-size:10.0pt;font-family:Arial'>Hi All,<br>
<span style=3D'mso-spacerun:yes'>&nbsp; </span>I am in urgent need for =
TCP patches for
NFS. I am using Redhat 7.3 kernel: 2.4.18-3. I will appreciate any help =
in
locating these.<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'margin-left:.5in'><font size=3D2 =
face=3DArial><span
style=3D'font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></f=
ont></p>

<p class=3DMsoNormal style=3D'margin-left:.5in'><font size=3D2 =
face=3DArial><span
style=3D'font-size:10.0pt;font-family:Arial'>Thanks in =
advance,<o:p></o:p></span></font></p>

<p class=3DMsoNormal style=3D'margin-left:.5in'><font size=3D2 =
face=3DArial><span
style=3D'font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></f=
ont></p>

<p class=3DMsoNormal style=3D'margin-left:.5in'><font size=3D2 =
face=3DArial><span
style=3D'font-size:10.0pt;font-family:Arial'>Regards<o:p></o:p></span></=
font></p>

<p class=3DMsoNormal style=3D'margin-left:.5in'><font size=3D2 =
face=3DArial><span
style=3D'font-size:10.0pt;font-family:Arial'>--Vinay<o:p></o:p></span></=
font></p>

</blockquote>

</div>

</body>

</html>
<P>_____________________________________________________________________=
_________<br>
This email is intended solely for the person or entity to which it is =
addressed and may contain confidential and/or privileged information.  =
Copying, forwarding or distributing this message by persons or entities =
other than the addressee is prohibited. If you have received this email =
in error, please contact the sender immediately and delete the material =
from any computer.  This email may have been monitored for policy =
compliance.  [021216]<br>
</P>
------_=_NextPart_001_01C352DB.F8AE6500--


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
