From: "Mita Baxi" <mbaxi@quark.com>
Subject: crossplatform File locking
Date: Wed, 14 Sep 2005 14:58:54 +0530
Message-ID: <40C32CE74F3011459C9F204D034EC36E020FC8CE@EXCH-IND-EVS2.india.quark.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5B90E.B2EE11C0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFTaS-0001ja-OM
	for nfs@lists.sourceforge.net; Wed, 14 Sep 2005 02:29:52 -0700
Received: from [203.200.99.77] (helo=mail4.quark.co.in)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EFTaP-0005MQ-PS
	for nfs@lists.sourceforge.net; Wed, 14 Sep 2005 02:29:52 -0700
Received: from EXCH-IND-EVS2.india.quark.com ([10.92.0.201])
	by mail4.quark.co.in (8.12.8/8.12.8) with ESMTP id j8E9R69R000824
	for <nfs@lists.sourceforge.net>; Wed, 14 Sep 2005 14:57:09 +0530
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

------_=_NextPart_001_01C5B90E.B2EE11C0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

Hi,

Locking mechanisms being different on MAC OS (advisory) and WIN OS
(mandatory), I'm unable to lock a file lying on MAC OS from my Windows
API and vice-versa.

=20

Does nfs provides support for implementing Platform-independent
File-locking.

=20

Regards,

~mita

=20


------_=_NextPart_001_01C5B90E.B2EE11C0
Content-Type: text/html;
	charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 11 (filtered medium)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"MS Mincho";
	panose-1:2 2 6 9 4 2 5 8 3 4;}
@font-face
	{font-family:"Trebuchet MS";
	panose-1:2 11 6 3 2 2 2 2 2 4;}
@font-face
	{font-family:"\@MS Mincho";
	panose-1:2 2 6 9 4 2 5 8 3 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:12.0pt;
	font-family:"Times New Roman";}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Trebuchet MS";
	color:navy;
	font-weight:normal;
	font-style:normal;
	text-decoration:none none;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:1.0in 1.25in 1.0in 1.25in;}
div.Section1
	{page:Section1;}
-->
</style>

</head>

<body lang=3DEN-GB link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3D"Trebuchet =
MS"><span
lang=3DEN-US style=3D'font-size:10.0pt;font-family:"Trebuchet =
MS";color:navy'>Hi,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3D"Trebuchet =
MS"><span
lang=3DEN-US style=3D'font-size:10.0pt;font-family:"Trebuchet =
MS";color:navy'>Locking
mechanisms being different on MAC OS (advisory) and WIN OS (mandatory), =
I&#8217;m
unable to lock a file lying on MAC OS from my Windows API and =
vice-versa.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3D"Trebuchet =
MS"><span
lang=3DEN-US style=3D'font-size:10.0pt;font-family:"Trebuchet =
MS";color:navy'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3D"Trebuchet =
MS"><span
lang=3DEN-US style=3D'font-size:10.0pt;font-family:"Trebuchet =
MS";color:navy'>Does <b><span
style=3D'font-weight:bold'>nfs</span></b> provides support for =
implementing
Platform-independent File-locking.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3D"Trebuchet =
MS"><span
lang=3DEN-US style=3D'font-size:10.0pt;font-family:"Trebuchet =
MS";color:navy'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3D"Trebuchet =
MS"><span
lang=3DEN-US style=3D'font-size:10.0pt;font-family:"Trebuchet =
MS";color:navy'>Regards,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3D"Trebuchet =
MS"><span
lang=3DEN-US style=3D'font-size:10.0pt;font-family:"Trebuchet =
MS";color:navy'>~mita<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3D"Trebuchet =
MS"><span
lang=3DEN-US style=3D'font-size:10.0pt;font-family:"Trebuchet =
MS";color:navy'><o:p>&nbsp;</o:p></span></font></p>

</div>

</body>

</html>

------_=_NextPart_001_01C5B90E.B2EE11C0--


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
