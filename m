From: "Alex Wun" <alexwun@consensys.com>
Subject: NFS sync write performance
Date: Tue, 24 Feb 2004 12:07:04 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <01e201c3faf8$a0d67af0$9002a8c0@consensys.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_01DF_01C3FACE.B7AF6CC0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avg2E-0003Dn-9w
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 09:07:54 -0800
Received: from [216.187.68.150] (helo=c.pexit.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Avg1T-0000YP-GR
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 09:07:07 -0800
Received: from consensyxdlcmm (CPE0002b38c45e3-CM000a73663c88.cpe.net.cable.rogers.com [63.139.198.156])
	by c.pexit.com (8.11.6/8.11.6) with SMTP id i1OH6ks21739
	for <nfs@lists.sourceforge.net>; Tue, 24 Feb 2004 12:06:46 -0500
To: <nfs@lists.sourceforge.net>
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

------=_NextPart_000_01DF_01C3FACE.B7AF6CC0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi.

I'm interested in the knowing what kind of performance numbers people =
are getting with NFSv3 synchronous writes.
(i.e. what should I be expecting?)

My system:

RedHat9.0 linux-2.4.20
Dual Intel Xeon P3 1.1Ghz
1GB ram
7-disk Raid5
XFS Filesystem
IntelPRO1000 GigE

Sequential local writes (rewrites) to a 2GB file on the Raid5 go at over =
100MB/s.  But
over NFS (v3, sync) it's less than 10MB/s. Is this roughly what's =
expected or is something
wrong with my setup?

As a side note, after modifying some code in the nfs client, nfs server, =
and xfs filesystem, I was able to
get performance up to ~45MB/s on the 7-disk Raid5 and ~60MB/s on a =
7-disk Raid0.  These customizations
are still very primitive but they might be worth looking into.  I know =
the nfs developers are busy, but would
they be interested in providing some feedback?

Thanks,
Alex Wun
alexwun@consensys.com
Consensys Computers Inc.

------=_NextPart_000_01DF_01C3FACE.B7AF6CC0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META content=3D"text/html; charset=3Diso-8859-1" =
http-equiv=3DContent-Type>
<META content=3D"MSHTML 5.00.3502.5390" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT color=3D#000080>Hi.</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT color=3D#000080>I'm interested in the knowing what kind of =
performance=20
numbers people are getting with NFSv3 synchronous writes.</FONT></DIV>
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
file on the=20
Raid5 go at over 100MB/s.&nbsp; But</FONT></DIV>
<DIV><FONT color=3D#000080>over NFS (v3, sync) it's less than 10MB/s. Is =
this=20
roughly what's expected or is something</FONT></DIV>
<DIV><FONT color=3D#000080>wrong with my setup?</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT color=3D#000080>As a side note, after modifying&nbsp;some =
code in the=20
nfs client, nfs server, and xfs filesystem, I was able to</FONT></DIV>
<DIV><FONT color=3D#000080>get&nbsp;performance up to ~45MB/s on the =
7-disk Raid5=20
and ~60MB/s on a 7-disk Raid0.&nbsp; </FONT><FONT color=3D#000080>These=20
customizations</FONT></DIV>
<DIV><FONT color=3D#000080>are still very primitive but&nbsp;they might =
be worth=20
looking into.&nbsp; I know the nfs developers are busy, but =
would</FONT></DIV>
<DIV><FONT color=3D#000080>they be interested in providing some=20
feedback?</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT color=3D#000080>Thanks,</FONT></DIV>
<DIV><FONT color=3D#000080>Alex Wun</FONT></DIV>
<DIV><FONT color=3D#000080><A=20
href=3D"mailto:alexwun@consensys.comConsensys">alexwun@consensys.com</A><=
/FONT></DIV>
<DIV><FONT color=3D#000080>Consensys Computers =
Inc.</FONT></DIV></BODY></HTML>

------=_NextPart_000_01DF_01C3FACE.B7AF6CC0--



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
