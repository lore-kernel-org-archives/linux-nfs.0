From: "Wendy Cheng" <wendy.cheng@falconstor.com>
Subject: the inode semaphore
Date: Tue, 11 Feb 2003 12:17:53 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <006401c2d1f1$84401170$c5e31a42@tamarac>
Reply-To: "Wendy Cheng" <wendy.cheng@falconstor.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0061_01C2D1C7.9A665510"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [66.105.142.2] (helo=falconstorex.falconstor.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ie39-0003dm-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Feb 2003 09:18:27 -0800
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

------=_NextPart_000_0061_01C2D1C7.9A665510
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset="iso-8859-1"

We're working on a high availability experiment
project for our linux-based server and the nfsds hang=20
from times to times. It is observed that the version 3=20
procedure 12/13 (rmdir and remove) obtains an inode=20
semaphore within fh_lock()/nfsd_unlink() but never=20
releases it. Theoretically this inode is going to get=20
released but what can prevent the following two cases=20
that would end up hanging the nfsd ?

1. Due to slow network and/or system, the client re-
sends the same request but using a different xid. The=20
nfsd that accepts the new request would be stuck in=20
nfsd_unlink() waiting for the inode semaphore.=20
2. A "create" immediately follows the "remove" for the=20
same file.=20

There is a flag called fh_locked but it is passed in=20
from each individual nfs request (a local copy, not=20
from dcache) that doesn't help. I also browse thru=20
some file system's (say ext3) inode free code but=20
can't find anywhere this semaphore gets released.=20
We're still debugging our failover logic but if=20
someone could confirm the above are indeed a bug (or=20
explain why it will not happen) would be of great=20
helps.

Or should this semaphore get "zero"ed out by file=20
system (say, ext3) ?=20

We're on 2.4.19 kernel.

Thanks for the help.

Wendy

------=_NextPart_000_0061_01C2D1C7.9A665510
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset="iso-8859-1"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1141" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>We=92re working on a high availability=20
experiment<BR>project for our linux-based server and the nfsds hang =
<BR>from=20
times to times. It is observed that the version 3 <BR>procedure 12/13 =
(rmdir and=20
remove) obtains an inode <BR>semaphore within fh_lock()/nfsd_unlink() =
but never=20
<BR>releases it. Theoretically this inode is going to get <BR>released =
but what=20
can prevent the following two cases <BR>that would end up hanging the =
nfsd=20
?</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>1. Due to slow network and/or system, =
the client=20
re-<BR>sends the same request but using a different xid. The <BR>nfsd =
that=20
accepts the new request would be stuck in <BR>nfsd_unlink() waiting for =
the=20
inode semaphore. <BR>2. A =93create=94 immediately follows the =
=93remove=94 for the=20
<BR>same file. </FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>There is a flag called fh_locked but it =
is passed=20
in <BR>from each individual nfs request (a local copy, not <BR>from =
dcache) that=20
doesn=92t help. I also browse thru <BR>some file system=92s (say ext3) =
inode free=20
code but <BR>can=92t find anywhere this semaphore gets released. =
<BR>We=92re still=20
debugging our failover logic but if <BR>someone could confirm the above =
are=20
indeed a bug (or <BR>explain why it will not happen) would be of great=20
<BR>helps.</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Or should this semaphore get =
=93zero=94ed out by file=20
<BR>system (say, ext3) ? </FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>We=92re on 2.4.19 kernel.</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Thanks for the help.</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Wendy<BR></FONT></DIV></BODY></HTML>

------=_NextPart_000_0061_01C2D1C7.9A665510--



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
