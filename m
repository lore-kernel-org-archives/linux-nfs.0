From: "Tony" <tony@games-master.co.uk>
Subject: Newbie NFS permissions question.
Date: Wed, 19 Apr 2006 11:23:32 +0100
Message-ID: <200604191020.k3JAKclw007010@main.games-master.co.uk>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0000_01C663A3.B0FDA5F0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FW9qm-0003is-F1
	for nfs@lists.sourceforge.net; Wed, 19 Apr 2006 03:23:56 -0700
Received: from [213.253.152.202] (helo=main.games-master.co.uk)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FW9qk-0008Mm-Jq
	for nfs@lists.sourceforge.net; Wed, 19 Apr 2006 03:23:56 -0700
Received: from asguard ([213.253.152.193])
	by main.games-master.co.uk (8.13.1/8.13.1) with ESMTP id k3JAKclw007010
	for <nfs@lists.sourceforge.net>; Wed, 19 Apr 2006 11:20:38 +0100
To: <nfs@lists.sourceforge.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_0000_01C663A3.B0FDA5F0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all.

 

I've used NFS in the past but only for file sharing, but now I need to use
it in a live environment for uses email/web etc across load balanced
servers.

The problem I have is that the maildirs have to be owned by the user they
belong to as does the web content.

However when I mount an NFS share on both servers it's mounted as root with
full permissions.

The problem is every file/directory created in the mounted NFS share is also
created owned by root, even when I try to change the permission to a
different owner or try to chmod a file or directory it doesn't do anything.

Is there a way of being able to use NFS in the way I want?

 

I'm running this on Centos 4.3 servers with nfs-utils-1.0.6-65.EL4.

 

Thanks

Tony


-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.


------=_NextPart_000_0000_01C663A3.B0FDA5F0
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" xmlns:w=3D"urn:sc=
hemas-microsoft-com:office:word" xmlns=3D"http://www.w3.org/TR/REC-html40">=
=0A=
=0A=
<head>=0A=
<meta http-equiv=3DContent-Type content=3D"text/html; charset=3Dus-ascii">=
=0A=
<meta name=3DGenerator content=3D"Microsoft Word 11 (filtered medium)">=0A=
<style>=0A=
<!--=0A=
 /* Style Definitions */=0A=
 p.MsoNormal, li.MsoNormal, div.MsoNormal=0A=
	{margin:0cm;=0A=
	margin-bottom:.0001pt;=0A=
	font-size:12.0pt;=0A=
	font-family:"Times New Roman";}=0A=
a:link, span.MsoHyperlink=0A=
	{color:blue;=0A=
	text-decoration:underline;}=0A=
a:visited, span.MsoHyperlinkFollowed=0A=
	{color:purple;=0A=
	text-decoration:underline;}=0A=
span.EmailStyle17=0A=
	{mso-style-type:personal-compose;=0A=
	font-family:Arial;=0A=
	color:windowtext;}=0A=
@page Section1=0A=
	{size:595.3pt 841.9pt;=0A=
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}=0A=
div.Section1=0A=
	{page:Section1;}=0A=
-->=0A=
</style>=0A=
=0A=
</head>=0A=
=0A=
<body lang=3DEN-GB link=3Dblue vlink=3Dpurple>=0A=
=0A=
<div class=3DSection1>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'>Hi all.<o:p></o:p></span></font></p>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'>I&#8217;ve used NFS in the past but only for file sharin=
g,=0A=
but now I need to use it in a live environment for uses email/web etc across=
=0A=
load balanced servers.<o:p></o:p></span></font></p>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'>The problem I have is that the maildirs have to be owned=
 by=0A=
the user they belong to as does the web content.<o:p></o:p></span></font></=
p>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'>However when I mount an NFS share on both servers it&#82=
17;s=0A=
mounted as root with full permissions.<o:p></o:p></span></font></p>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'>The problem is every file/directory created in the mount=
ed=0A=
NFS share is also created owned by root, even when I try to change the perm=
ission=0A=
to a different owner or try to chmod a file or directory it doesn&#8217;t do=
=0A=
anything.<o:p></o:p></span></font></p>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'>Is there a way of being able to use NFS in the way I wan=
t?<o:p></o:p></span></font></p>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'>I&#8217;m running this on Centos 4.3 servers with nfs-ut=
ils-1.0.6-65.EL4.<o:p></o:p></span></font></p>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'>Thanks<o:p></o:p></span></font></p>=0A=
=0A=
<p class=3DMsoNormal><font size=3D2 face=3DArial><span style=3D'font-size:1=
0.0pt;=0A=
font-family:Arial'>Tony<o:p></o:p></span></font></p>=0A=
=0A=
</div>=0A=
=0A=
</body>=0A=
=0A=
<br />--=20=0A=
<br />This message has been scanned for viruses and=0A=
<br />dangerous content by=0A=
<a href=3D"http://www.mailscanner.info/"><b>MailScanner</b></a>, and is=0A=
<br />believed to be clean.=0A=
</html>=0A=

------=_NextPart_000_0000_01C663A3.B0FDA5F0--



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
