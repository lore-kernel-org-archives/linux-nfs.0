From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS sync write performance
Date: Tue, 24 Feb 2004 12:42:23 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020ACC45@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C3FB16.B4A327FE"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvjOt-0002S6-EQ
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 12:43:31 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvjBe-0007OK-UO
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 12:29:50 -0800
To: "Alex Wun" <alexwun@consensys.com>
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

------_=_NextPart_001_01C3FB16.B4A327FE
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

hi alex-
=20
sync writes are slow, that should be expected.  the Linux NFS client
writes a page at a time, for architectural reasons, but could be =
improved
if we could get it to write a whole "wsize" chunk at a time.
=20

-----Original Message-----
From: Alex Wun [mailto:alexwun@consensys.com]
Sent: Tuesday, February 24, 2004 9:07 AM
To: nfs@lists.sourceforge.net
Subject: [NFS] NFS sync write performance


Hi.
=20
I'm interested in the knowing what kind of performance numbers people =
are getting with NFSv3 synchronous writes.
(i.e. what should I be expecting?)
=20
My system:
=20
RedHat9.0 linux-2.4.20
Dual Intel Xeon P3 1.1Ghz
1GB ram
7-disk Raid5
XFS Filesystem
IntelPRO1000 GigE
=20
Sequential local writes (rewrites) to a 2GB file on the Raid5 go at over =
100MB/s.  But
over NFS (v3, sync) it's less than 10MB/s. Is this roughly what's =
expected or is something
wrong with my setup?
=20
As a side note, after modifying some code in the nfs client, nfs server, =
and xfs filesystem, I was able to
get performance up to ~45MB/s on the 7-disk Raid5 and ~60MB/s on a =
7-disk Raid0.  These customizations
are still very primitive but they might be worth looking into.  I know =
the nfs developers are busy, but would
they be interested in providing some feedback?
=20
Thanks,
Alex Wun
alexwun@consensys.com <mailto:alexwun@consensys.comConsensys>=20
Consensys Computers Inc.


------_=_NextPart_001_01C3FB16.B4A327FE
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">


<META content=3D"MSHTML 6.00.2800.1400" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2><SPAN =
class=3D786314120-24022004>hi=20
alex-</SPAN></FONT></DIV>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2><SPAN=20
class=3D786314120-24022004></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2><SPAN =
class=3D786314120-24022004>sync=20
writes are slow, that should be expected.&nbsp; the Linux NFS=20
client</SPAN></FONT></DIV>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2><SPAN =
class=3D786314120-24022004>writes=20
a page at a time, for architectural reasons, but could be=20
improved</SPAN></FONT></DIV>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2><SPAN =
class=3D786314120-24022004>if we=20
could get it to write a whole "wsize" chunk at a =
time.</SPAN></FONT></DIV>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2><SPAN=20
class=3D786314120-24022004></SPAN></FONT>&nbsp;</DIV>
<BLOCKQUOTE dir=3Dltr=20
style=3D"PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px =
solid; MARGIN-RIGHT: 0px">
  <DIV class=3DOutlookMessageHeader dir=3Dltr align=3Dleft><FONT =
face=3DTahoma=20
  size=3D2>-----Original Message-----<BR><B>From:</B> Alex Wun=20
  [mailto:alexwun@consensys.com]<BR><B>Sent:</B> Tuesday, February 24, =
2004 9:07=20
  AM<BR><B>To:</B> nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] =
NFS sync=20
  write performance<BR><BR></FONT></DIV>
  <DIV><FONT color=3D#000080>Hi.</FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT color=3D#000080>I'm interested in the knowing what kind of=20
  performance numbers people are getting with NFSv3 synchronous=20
  writes.</FONT></DIV>
  <DIV><FONT color=3D#000080>(i.e. what should I be =
expecting?)</FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT color=3D#000080>My system:</FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT color=3D#000080>RedHat9.0 linux-2.4.20</FONT></DIV>
  <DIV><FONT color=3D#000080>Dual Intel Xeon P3 1.1Ghz</FONT></DIV>
  <DIV><FONT color=3D#000080>1GB ram</FONT></DIV>
  <DIV><FONT color=3D#000080>7-disk Raid5</FONT></DIV>
  <DIV><FONT color=3D#000080>XFS Filesystem</FONT></DIV>
  <DIV><FONT color=3D#000080>IntelPRO1000 GigE</FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT color=3D#000080>Sequential local writes (rewrites) to a 2GB =
file on=20
  the Raid5 go at over 100MB/s.&nbsp; But</FONT></DIV>
  <DIV><FONT color=3D#000080>over NFS (v3, sync) it's less than 10MB/s. =
Is this=20
  roughly what's expected or is something</FONT></DIV>
  <DIV><FONT color=3D#000080>wrong with my setup?</FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT color=3D#000080>As a side note, after modifying&nbsp;some =
code in the=20
  nfs client, nfs server, and xfs filesystem, I was able to</FONT></DIV>
  <DIV><FONT color=3D#000080>get&nbsp;performance up to ~45MB/s on the =
7-disk=20
  Raid5 and ~60MB/s on a 7-disk Raid0.&nbsp; </FONT><FONT =
color=3D#000080>These=20
  customizations</FONT></DIV>
  <DIV><FONT color=3D#000080>are still very primitive but&nbsp;they =
might be worth=20
  looking into.&nbsp; I know the nfs developers are busy, but =
would</FONT></DIV>
  <DIV><FONT color=3D#000080>they be interested in providing some=20
  feedback?</FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT color=3D#000080>Thanks,</FONT></DIV>
  <DIV><FONT color=3D#000080>Alex Wun</FONT></DIV>
  <DIV><FONT color=3D#000080><A=20
  =
href=3D"mailto:alexwun@consensys.comConsensys">alexwun@consensys.com</A><=
/FONT></DIV>
  <DIV><FONT color=3D#000080>Consensys Computers=20
Inc.</FONT></DIV></BLOCKQUOTE></BODY></HTML>

------_=_NextPart_001_01C3FB16.B4A327FE--


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
