From: "Matt Heaton" <admin@0catch.com>
Subject: Question about performance...
Date: Fri, 31 Jan 2003 09:05:41 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <010d01c2c942$9c7c94f0$6601a8c0@userl3x55qxqed>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_010A_01C2C907.EE1012A0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc53.attbi.com ([204.127.198.39])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18edfr-0006kG-00
	for <nfs@lists.sourceforge.net>; Fri, 31 Jan 2003 08:05:51 -0800
To: <nfs@lists.sourceforge.net>
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

This is a multi-part message in MIME format.

------=_NextPart_000_010A_01C2C907.EE1012A0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello all... I have 3 HUGE NFS servers (Each one with 2 -3 terabytes =
each), and 10 clients that pull a consistent 20-25 MBit total off of
the 3 NFS servers.  Everything is running fine, but performance isn't =
the greatest... I can never pull more than 1 Megabyte per second off of =
any of the servers (Even though local performance of drives on the =
servers is GREAT)...  My question is this?  How would switching =
everything to gigabit copper instead of 100 MBit lines help.   Obviously =
Gig is faster, but since I am not even using the 100 MBit I am =
wondering?  The latency should go down because it transfers so much =
faster?  Any ideas for me?  Anyone do this themselves that can answer?

Thanks,
Matt


------=_NextPart_000_010A_01C2C907.EE1012A0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2722.900" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hello all... I have 3 HUGE NFS servers =
(Each one=20
with 2 -3 terabytes each), and 10 clients that pull a consistent 20-25 =
MBit=20
total off of</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>the 3 NFS servers.&nbsp; Everything is =
running=20
fine, but performance isn't the greatest... I can never pull more than 1 =

Megabyte per second off of any of the servers (Even though local =
performance of=20
drives on the servers is GREAT)...&nbsp; My question is this?&nbsp; How =
would=20
switching everything to gigabit copper instead of 100 MBit lines=20
help.&nbsp;&nbsp; Obviously Gig is faster, but since I am not even using =
the 100=20
MBit I am wondering?&nbsp; The latency should go down because it =
transfers so=20
much faster?&nbsp; Any ideas for me?&nbsp; Anyone do this themselves =
that can=20
answer?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Thanks,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Matt</FONT></DIV>
<DIV>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_010A_01C2C907.EE1012A0--



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
