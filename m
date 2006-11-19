From: "Chris Wornell" <CWornell@peerless.com>
Subject: NFS Help! Terrible performance with sync,
	fast performance with async
Date: Sun, 19 Nov 2006 04:57:17 -0500
Message-ID: <49BCFA109293624D9AE0EC6558C0D3B802A8B327@ATL1VEXC017.usdom004.tco.tc>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0189757274=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GljQT-000289-QO
	for nfs@lists.sourceforge.net; Sun, 19 Nov 2006 01:57:26 -0800
Received: from out002.iad.hostedmail.net ([209.225.56.24])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GljQT-0007gw-LT
	for nfs@lists.sourceforge.net; Sun, 19 Nov 2006 01:57:27 -0800
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

--===============0189757274==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C70BC1.1BE19EF7"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C70BC1.1BE19EF7
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I've got a problem that I've spent quite a bit of time on, though I'm
not an expert at NFS. In summary, operations that require meta-data
changes (such as file/directory creations/deletions), perform extremely
slow over sync, but over 10x faster using async.

I have two systems, connected to a GigE switch using intel pro 1000 NICs
(jumbo frames is currently not enabled on any of the points).=20

The NFS server is a dual-core opteron system with 1GB of RAM and 3x300
SAS disk RAID-5 on a Perc5/i controller with 256MB battery backed cache
(write cache is enabled). The file system is ext3. I've configured nfsd
to spawn 32 processes upon startup. I'm using defaults for export the
nfs shares, no changes to rsize or wsize.

The NFS client is a dual Xeon with 4GB of RAM and a single 7200rpm SATA
disk. Both systems are running RHEL WS 3 Update 8 and kernel
2.4.21-47.0.1.ELsmp.=20

For testing, I'm using bonnie++. The following are some sample test
results that sum up the problem:

Test on NFS server directly (not NFS loopback)
-Sequential File Creation: 2976
-Sequential File Deletion: N/A
-Random File Creation: 3077
-Random File Deletion: 9922

NFS test with sync enabled
-Sequential File Creation: 39
-Sequential File Deletion: 79
-Random File Creation: 39
-Random File Delection: 65

NFS test with async enabled
-Sequential File Creation: 575
-Sequential File Deletion: 1718
-Random File Creation: 543
-Random File Deletion: 1228

Based on the local performance of the NFS server, it does not appear the
IO setup is the culprit. My understanding of the sync operation is a
commit happens which means the NFS server doesn't reply back until the
change has actually been committed to stable storage. There is something
happening behind the scenes though which is causing a huge delay before
the NFS server replies back the commit was complete.

This question is actually work related and I'm planning to put the NFS
server into production, but I'd rather not use async, even with a UPS
and dual PSU's on the server. With the newer nfs-utils, sync is the
default option as well so it seems like sync should perform relatively
well.

Another question is I don't quite understand how the data corruption
happens if a power loss occurs on an NFS server using async. Even with
sync, data transferred over the wire maybe loss if the nfs server gets
shut down before that data is committed. Can anyone go into more detail
on how the data corruption happens?

Thanks a bunch!

=20

Thanks,

Chris Wornell
Network Administrator, Information Technology
Peerless Systems Corporation
http://www.peerless.com <http://www.peerless.com/>=20
office: 310.727.5723
fax: 310.727.5715
mailto:cwornell@peerless.com <mailto:cwornell@peerless.com> =20

=20


------_=_NextPart_001_01C70BC1.1BE19EF7
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 11 (filtered medium)">
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
	{mso-style-type:personal-compose;
	font-family:Arial;
	color:windowtext;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.25in 1.0in 1.25in;}
div.Section1
	{page:Section1;}
-->
</style>

</head>

<body lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span =
style=3D'font-size:
12.0pt'>I've got a problem that I've spent quite a bit of time on, =
though I'm not
an expert at NFS. In summary, operations that require meta-data changes =
(such
as file/directory creations/deletions), perform extremely slow over =
sync, but
over 10x faster using async.<br>
<br>
I have two systems, connected to a GigE switch using intel pro 1000 NICs =
(jumbo
frames is currently not enabled on any of the points). <br>
<br>
The NFS server is a dual-core opteron system with 1GB of RAM and 3x300 =
SAS disk
RAID-5 on a Perc5/i controller with 256MB battery backed cache (write =
cache is
enabled). The file system is ext3. I've configured nfsd to spawn 32 =
processes
upon startup. I'm using defaults for export the nfs shares, no changes =
to rsize
or wsize.<br>
<br>
The NFS client is a dual Xeon with 4GB of RAM and a single 7200rpm SATA =
disk.
Both systems are running RHEL WS 3 Update 8 and kernel =
2.4.21-47.0.1.ELsmp. <br>
<br>
For testing, I'm using bonnie++. The following are some sample test =
results
that sum up the problem:<br>
<br>
Test on NFS server directly (not NFS loopback)<br>
-Sequential File Creation: 2976<br>
-Sequential File Deletion: N/A<br>
-Random File Creation: 3077<br>
-Random File Deletion: 9922<br>
<br>
NFS test with sync enabled<br>
-Sequential File Creation: 39<br>
-Sequential File Deletion: 79<br>
-Random File Creation: 39<br>
-Random File Delection: 65<br>
<br>
NFS test with async enabled<br>
-Sequential File Creation: 575<br>
-Sequential File Deletion: 1718<br>
-Random File Creation: 543<br>
-Random File Deletion: 1228<br>
<br>
Based on the local performance of the NFS server, it does not appear the =
IO
setup is the culprit. My understanding of the sync operation is a commit
happens which means the NFS server doesn't reply back until the change =
has
actually been committed to stable storage. There is something happening =
behind
the scenes though which is causing a huge delay before the NFS server =
replies
back the commit was complete.<br>
<br>
This question is actually work related and I'm planning to put the NFS =
server
into production, but I'd rather not use async, even with a UPS and dual =
PSU's
on the server. With the newer nfs-utils, sync is the default option as =
well so
it seems like sync should perform relatively well.<br>
<br>
Another question is I don't quite understand how the data corruption =
happens if
a power loss occurs on an NFS server using async. Even with sync, data
transferred over the wire maybe loss if the nfs server gets shut down =
before
that data is committed. Can anyone go into more detail on how the data
corruption happens?<br>
<br>
Thanks a bunch!</span></font><font size=3D2 face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3D"Times New Roman"><span =
style=3D'font-size:
10.0pt'>Thanks,<br>
<br>
Chris Wornell<br>
Network Administrator, Information Technology<br>
Peerless Systems Corporation<br>
</span></font><a href=3D"http://www.peerless.com/"
title=3D"http://www.peerless.com/"><font size=3D2><span =
style=3D'font-size:10.0pt'>http://www.peerless.com</span></font></a><br>
<font size=3D2><span style=3D'font-size:10.0pt'>office: 310.727.5723<br>
fax: 310.727.5715<br>
</span></font><a href=3D"mailto:cwornell@peerless.com"
title=3D"mailto:cwornell@peerless.com"><font size=3D2><span =
style=3D'font-size:10.0pt'>mailto:cwornell@peerless.com</span></font></a>=

<o:p></o:p></p>

<p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span =
style=3D'font-size:
12.0pt'><o:p>&nbsp;</o:p></span></font></p>

</div>

</body>

</html>

------_=_NextPart_001_01C70BC1.1BE19EF7--


--===============0189757274==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0189757274==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0189757274==--
