From: "Thomas, Dave" <Dave.Thomas@savvis.net>
Subject: NFS inconsistencies experienced between server and client.
Date: Thu, 10 Nov 2005 12:42:54 -0000
Message-ID: <51E1B8DFD9EE6747889DB802751770B906FE7E@S229378RGEW08.apptix-01.savvis.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5E5F4.71B4D967"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EaBmt-0001g2-Lk
	for nfs@lists.sourceforge.net; Thu, 10 Nov 2005 04:44:19 -0800
Received: from out001.uk.email.savvis.net ([213.174.205.44])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EaBmp-0006fj-6T
	for nfs@lists.sourceforge.net; Thu, 10 Nov 2005 04:44:19 -0800
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

------_=_NextPart_001_01C5E5F4.71B4D967
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

=20

I currently a web site consisting of one NFS server and 2 clients
running RedHat AS3.0 (kernel 2.4.21-9.0.1.ELsmp)

=20

Clients run:-

Apache/2.0.52

jakarta-tomcat-5.5.4

nfs-utils-1.0.6-33EL

=20

Server runs:-

mysql  Ver 14.7 Distrib 4.1.13, for pc-linux-gnu (i686) using readline
4.3

nfs-utils-1.0.6-33EL

=20

The server shares out a directory /data01/www, mounted as /www on the
clients, which contains the DocumentRoot used by apache.

=20

New content is uploaded to the server at /data01/www, several times a
day.

=20

I am seeing inconsistencies between some files on the server, and the
same files on the client, index.shtml files in particular.

When I run a checksum on certain files on the clients and server,
different results are obtained. The checksums, and the files, only
become identical if the file is deleted before being uploaded onto the
server, but this is not an option.

If the file is not deleted, before being uploaded, they remain different
indefinitely.=20

=20

The filesystem is exported with the options (rw,async), and mounted with
following (rsize=3D8192,wsize=3D8192,timeo=3D15,rw,hard,intr).

We have tested by changing several mount options, including:-

Server export with ro, client mount with ro, client mount with noac. We
have increased the number of nfs threads on the server from 8 to 16.

=20

But the problem is still being experienced, and is becoming a critical
issue, as the website shows different data, depending upon which client
you connect to.

=20

=20

Any thoughts would be welcome.

=20

Thanks,

=20

Dave.

=20


------_=_NextPart_001_01C5E5F4.71B4D967
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>

<head>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 11 (filtered)">
<style>
<!--
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
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
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.Section1
	{page:Section1;}
-->
</style>

</head>

<body lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Hi,</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>I currently a web site consisting of one NFS server =
and 2 clients
running RedHat AS3.0 (kernel 2.4.21-9.0.1.ELsmp)</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Clients run:-</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Apache/2.0.52</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>jakarta-tomcat-5.5.4</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>nfs-utils-1.0.6-33EL</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Server runs:-</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>mysql &nbsp;Ver 14.7 Distrib 4.1.13, for pc-linux-gnu =
(i686)
using readline 4.3</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>nfs-utils-1.0.6-33EL</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>The server shares out a directory /data01/www, =
mounted as
/www on the clients, which contains the DocumentRoot used by =
apache.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>New content is uploaded to the server at /data01/www,
several times a day.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>I am seeing inconsistencies between some files on the
server, and the same files on the client, index.shtml files in =
particular.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>When I run a checksum on certain files on the clients =
and
server, different results are obtained. The checksums, and the files, =
only
become identical if the file is deleted before being uploaded onto the =
server,
but this is not an option.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>If the file is not deleted, before being uploaded, =
they
remain different indefinitely. </span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>The filesystem is exported with the options =
(rw,async), and
mounted with following =
(rsize=3D8192,wsize=3D8192,timeo=3D15,rw,hard,intr).</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>We have tested by changing several mount options,
including:-</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Server export with ro, client mount with ro, client =
mount
with noac. We have increased the number of nfs threads on the server =
from 8 to
16.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>But the problem is still being experienced, and is =
becoming
a critical issue, as the website shows different data, depending upon =
which
client you connect to.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Any thoughts would be welcome.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Thanks,</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Dave.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

</div>

</body>

</html>

------_=_NextPart_001_01C5E5F4.71B4D967--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
