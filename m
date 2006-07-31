From: "Dan McNulty" <dan.mcnulty@eckoh.com>
Subject: Unable to copy large files to NFS server
Date: Mon, 31 Jul 2006 17:20:51 +0100
Message-ID: <E092A2FD32592642884987B611E09A09024BAB@ukth008-2kaex-t.eckoh.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0847718984=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7aVq-0000a4-Fo
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 09:21:02 -0700
Received: from mail.eckoh.com ([81.20.37.77])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7aVo-0001ZJ-Uz
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 09:21:02 -0700
To: <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.

--===============0847718984==
Content-Transfer-Encoding: 7bit
Content-Class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C6B4BD.4A7D2ABA"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C6B4BD.4A7D2ABA
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

=20

We have recently purchased a new EMC NAS solution. I have successfully
configured our newer (Fedora4) servers to access this successfully.

=20

However we have a number of RedHat 7.2 servers (kernel 2.4.18), which I
have successfully mounted to the Server, and can copy small files OK.
However, when I try to copy larger files to the Server, the system just
hangs, and then the mount becomes unusable; I'm unable to kill the hung
process and cannot unmount. I have tried to edit the rsize/wsize options
but this hasn't worked. The current entry in /etc/fstab looks like this:

=20

Servername:/path1/path2/Production    /mnt/Production nfs
rsize=3D4096,wsize=3D4096,nfsvers=3D3 0 0

=20

In /var/log/messages I see lots of these errors:

=20

Jul 31 16:29:51 client1 kernel: nfs: server Servername not responding,
still trying

Jul 31 16:31:40 client1 kernel: nfs: task 189 can't get a request slot

Jul 31 16:31:40 client1 kernel: nfs: task 190 can't get a request slot

=20

The main problem is that I can write small files and it works OK. As
soon as I try to transfer a larger file, the client writes a 0 byte file
to the server (with the correct filename) then just hangs. I then can't
do anything with the mount. Any help on what I should be looking at
would be much appreciated!

=20

Regards,

=20

Dan.=20
=20
--
 =20
Dan McNulty
Systems Administrator
Eckoh Technologies (UK) Limited
Telford House, Corner Hall,
Hemel Hempstead, Hertfordshire HP3 9HN=20
=20
T 01442 458390
F 01442 458443
M 07917 395719
W  www.eckoh.com
=20
Eckoh Technologies - Winner, Product of the Year - European Call Centre =
Awards 2005
http://www.eckoh.com/Investor_Relations/News/story_1022.shtml
=20
This communication contains information, which is confidential and may =
also be privileged. It is for the exclusive use of the intended =
recipient(s) only. If you are not the intended recipient(s) please note =
that any form of distribution, copying or use of this communication or =
the information in it is strictly prohibited and may be unlawful. If you =
have received this communication in error please return it to the sender =
and then delete it. Opinions expressed in this message are those of the =
author, and are not binding on the company.=20
=20
Registered in England and Wales, No. 2796531
Registered office: Telford House, Corner Hall, Hemel Hempstead, =
Hertfordshire HP3 9HN=20
=20
A member of the Eckoh Technologies plc group of companies.

------_=_NextPart_001_01C6B4BD.4A7D2ABA
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<HTML >
<HEAD>
<META http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dus-ascii">



<meta name=3DGenerator content=3D"Microsoft Word 11 (filtered medium)">
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
	{mso-style-type:personal-compose;
	font-family:Arial;
	color:windowtext;}
@page Section1
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.Section1
	{page:Section1;}
-->
</style>

</HEAD>
<BODY lang=3DEN-US link=3Dblue vlink=3Dpurple>
<DIV>
<FONT FACE=3D"Verdana" SIZE=3D"2">

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>Hi,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>We have recently purchased a new EMC NAS =
solution. I
have successfully configured our newer (Fedora4) servers to access this
successfully.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>However we have a number of RedHat 7.2 servers
(kernel 2.4.18), which I have successfully mounted to the Server, and =
can copy
small files OK. However, when I try to copy larger files to the Server, =
the
system just hangs, and then the mount becomes unusable; I&#8217;m unable =
to
kill the hung process and cannot unmount. I have tried to edit the =
rsize/wsize
options but this hasn&#8217;t worked. The current entry in /etc/fstab =
looks
like this:<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblue face=3DArial><span =
lang=3DEN-GB
style=3D'font-size:10.0pt;font-family:Arial;color:blue'>Servername:/path1=
/path2/Production&nbsp;&nbsp;&nbsp;
/mnt/Production nfs&nbsp;&nbsp;&nbsp;&nbsp; =
rsize=3D4096,wsize=3D4096,nfsvers=3D3 0 0<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>In /var/log/messages I see lots of these =
errors:<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblue face=3DArial><span =
lang=3DEN-GB
style=3D'font-size:10.0pt;font-family:Arial;color:blue'>Jul 31 16:29:51 =
client1
kernel: nfs: server Servername not responding, still =
trying<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblue face=3DArial><span =
lang=3DEN-GB
style=3D'font-size:10.0pt;font-family:Arial;color:blue'>Jul 31 16:31:40 =
client1
kernel: nfs: task 189 can't get a request =
slot<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblue face=3DArial><span =
lang=3DEN-GB
style=3D'font-size:10.0pt;font-family:Arial;color:blue'>Jul 31 16:31:40 =
client1
kernel: nfs: task 190 can't get a request =
slot<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>The main problem is that I can write small =
files and
it works OK. As soon as I try to transfer a larger file, the client =
writes a 0
byte file to the server (with the correct filename) then just hangs. I =
then can&#8217;t
do anything with the mount. Any help on what I should be looking at =
would be
much appreciated!<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>Regards,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span lang=3DEN-GB =
style=3D'font-size:
10.0pt;font-family:Arial'>Dan.<o:p></o:p></span></font></p>

</div>

 </FONT>
</DIV>
<DIV>
<FONT FACE=3D"Verdana" SIZE=3D"2">
</FONT>&nbsp;</DIV>
<DIV>
<FONT FACE=3D"Verdana" SIZE=3D"2">--</FONT>
</DIV>
<DIV>
<FONT FACE=3D"Verdana" SIZE=3D"2">&nbsp;&nbsp;</FONT>
</DIV>
<DIV>
<DIV>
<FONT FACE=3D"Verdana" SIZE=3D"2">Dan McNulty</FONT>
</DIV>
<DIV>
<FONT FACE=3D"Verdana" SIZE=3D"2">Systems Administrator</FONT>
</DIV>
<DIV><STRONG><B><FONT COLOR=3D"black"><SPAN STYLE=3D"FONT-SIZE: 10pt; =
COLOR: black; FONT-FAMILY: Verdana">Eckoh Technologies (UK) =
Limited</SPAN></FONT></B></STRONG><FONT COLOR=3D"black"><SPAN =
STYLE=3D"FONT-SIZE: 10pt; COLOR: black; FONT-FAMILY: =
Verdana"><BR>Telford House, Corner Hall,<BR>Hemel Hempstead, =
Hertfordshire HP3 9HN</SPAN></FONT>
<FONT COLOR=3D"black" SIZE=3D"2"><SPAN STYLE=3D"COLOR: black; =
FONT-FAMILY: Verdana"> </SPAN></FONT>
</DIV>
<DIV>
<FONT COLOR=3D"black"><SPAN STYLE=3D"COLOR: black; FONT-FAMILY: =
Verdana"></SPAN></FONT>
<FONT FACE=3D"Verdana" SIZE=3D"2">&nbsp;</FONT>
</DIV>
<DIV>
<FONT COLOR=3D"black"><SPAN STYLE=3D"COLOR: black; FONT-FAMILY: =
Verdana"></SPAN></FONT>
<FONT COLOR=3D"black"><SPAN STYLE=3D"FONT-SIZE: 10pt; COLOR: black; =
FONT-FAMILY: Verdana"><STRONG>T</STRONG>&nbsp;01442 458390</SPAN></FONT>
<FONT COLOR=3D"black"><SPAN STYLE=3D"FONT-SIZE: 10pt; COLOR: black; =
FONT-FAMILY: Verdana"><BR><STRONG><B>F</B></STRONG>&nbsp;01442 =
458443<BR><STRONG><B>M</B></STRONG>&nbsp;07917 =
395719<BR><STRONG><B>W</B></STRONG> </SPAN></FONT>
<FONT COLOR=3D"black"><SPAN STYLE=3D"COLOR: black"><A =
HREF=3D"http://www.eckoh.com/"><SPAN STYLE=3D"FONT-SIZE: 10pt; =
FONT-FAMILY: Verdana"></SPAN></A><FONT FACE=3D"Verdana" =
SIZE=3D"2">&nbsp;</FONT><A HREF=3D"http://www.eckoh.com/"><FONT =
FACE=3D"Verdana" =
SIZE=3D"2">www.eckoh.com</FONT></A></SPAN></FONT><A></A><SPAN></SPAN><FON=
T SIZE=3D"+0">
</FONT>
<FONT FACE=3D"Verdana" COLOR=3D"black" SIZE=3D"1"><SPAN =
STYLE=3D"FONT-SIZE: 7.5pt; COLOR: black; FONT-FAMILY: =
Verdana"></SPAN></FONT><A></A></DIV>
<DIV>
<FONT FACE=3D"Verdana" COLOR=3D"black" SIZE=3D"1"><SPAN =
STYLE=3D"FONT-SIZE: 7.5pt; COLOR: black; FONT-FAMILY: =
Verdana"></SPAN></FONT>&nbsp;</DIV>
<DIV><STRONG><FONT FACE=3D"Verdana" SIZE=3D"2">Eckoh Technologies - =
Winner, Product of the Year - European Call Centre Awards =
2005</FONT></STRONG></DIV>
<DIV><A =
TITLE=3D"http://www.eckoh.com/Investor_Relations/News/story_1022.shtml" =
HREF=3D"http://www.eckoh.com/Investor_Relations/News/story_1022.shtml"><F=
ONT FACE=3D"Verdana" =
SIZE=3D"2">http://www.eckoh.com/Investor_Relations/News/story_1022.shtml<=
/FONT></A></DIV>
<DIV>&nbsp;</DIV>
<DIV>
<FONT SIZE=3D"1">
<FONT COLOR=3D"black"><SPAN STYLE=3D"FONT-SIZE: 7.5pt; COLOR: black; =
FONT-FAMILY: Verdana">This communication contains information, which is =
confidential and may also be privileged. It is for the exclusive use of =
the intended recipient(s) only. If you are not the intended recipient(s) =
please note that any form of distribution, copying or use of this =
communication or the information in it is strictly prohibited and may be =
unlawful. If you have received this communication in error please return =
it to the sender and then delete it. Opinions expressed in this message =
are those of the author, and are not binding on the =
company.</SPAN></FONT>
<FONT FACE=3D"Verdana" COLOR=3D"black"><SPAN STYLE=3D"COLOR: black"> =
</SPAN></FONT>
</FONT>
</DIV>
<DIV>
<FONT COLOR=3D"black"><SPAN STYLE=3D"COLOR: black"></SPAN></FONT>
<FONT FACE=3D"Verdana" SIZE=3D"1">&nbsp;</FONT>
</DIV>
<DIV>
<FONT COLOR=3D"black"><SPAN STYLE=3D"COLOR: black"></SPAN></FONT>
<FONT SIZE=3D"1">
<FONT COLOR=3D"black"><SPAN STYLE=3D"FONT-SIZE: 7.5pt; COLOR: black; =
FONT-FAMILY: Verdana">Registered in England and Wales, No. =
2796531<BR>Registered office: Telford House, Corner Hall, Hemel =
Hempstead, Hertfordshire HP3 9HN</SPAN></FONT>
<FONT FACE=3D"Verdana" COLOR=3D"black"><SPAN STYLE=3D"COLOR: black"> =
</SPAN></FONT>
</FONT>
</DIV>
<DIV>
<FONT COLOR=3D"black"><SPAN STYLE=3D"COLOR: black"></SPAN></FONT>
<FONT FACE=3D"Verdana" SIZE=3D"1">&nbsp;</FONT>
</DIV>
<DIV>
<FONT COLOR=3D"black"><SPAN STYLE=3D"COLOR: black"></SPAN></FONT>
<FONT COLOR=3D"black" SIZE=3D"1"><SPAN STYLE=3D"FONT-SIZE: 7.5pt; COLOR: =
black; FONT-FAMILY: Verdana">A member of the Eckoh Technologies plc =
group of companies.</SPAN></FONT>
<FONT COLOR=3D"black"><SPAN STYLE=3D"COLOR: black"> </SPAN></FONT>
</DIV>
</DIV></BODY></HTML>

------_=_NextPart_001_01C6B4BD.4A7D2ABA--


--===============0847718984==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0847718984==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0847718984==--
