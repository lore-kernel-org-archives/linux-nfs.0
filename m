From: "Bennett, Paul" <Paul_Bennett@nrgn.com>
Subject: stale nfs handle
Date: Thu, 16 May 2002 16:49:12 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <68DD016AFCDBD3118B3000508B6C6B1701287768@nrgn.nrgn.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C1FD1B.2224DCB0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host5.neurogen.com ([208.255.81.5] helo=exchanger.nrgn.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178SFX-0005RT-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 13:53:23 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C1FD1B.2224DCB0
Content-Type: text/plain;
	charset="iso-8859-1"

I have a Irix 6.5.14 client mounting a 2.4.17 Linux server ext3 filesystem. 

One heavily used account occasionally gets stale nfs handles. I believe

it happens when files are being created.

 

I saw an instance where someone ran into a similar problem with reiser fs

and they used a "conv" parameter when mounting the filesystem on the server

to control the recycling of inode numbers to fix it.

 

Does anyone know of a similar parameter for ext3? or something else to try?

 

Thanks,

 

Paul


------_=_NextPart_001_01C1FD1B.2224DCB0
Content-Type: text/html;
	charset="iso-8859-1"

<html>

<head>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">


<meta name=Generator content="Microsoft Word 10 (filtered)">

<style>
<!--
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
	{font-family:Arial;
	color:windowtext;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.25in 1.0in 1.25in;}
div.Section1
	{page:Section1;}
-->
</style>

</head>

<body lang=EN-US link=blue vlink=purple>

<div class=Section1>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>I have a Irix 6.5.14 client mounting a 2.4.17 Linux server
ext3 filesystem. </span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>One heavily used account occasionally gets stale nfs
handles. I believe</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>it happens when files are being created.</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>I saw an instance where someone ran into a similar problem with
reiser fs</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>and they used a &quot;conv&quot; parameter when mounting the
filesystem on the server</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>to control the recycling of inode numbers to fix it.</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>Does anyone know of a similar parameter for ext3? or
something else to try?</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>Thanks,</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>Paul</span></font></p>

</div>

</body>

</html>

------_=_NextPart_001_01C1FD1B.2224DCB0--

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
