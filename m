From: "Kedar Sovani" <kedar@calsoftinc.com>
Subject: Re: rpc.mountd + rpc.nfsd
Date: Tue, 3 Sep 2002 11:11:30 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001601c2530c$93e9ef10$4f0010ac@Ashwamedha>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0011_01C2533A.A75C2E40"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from silver.he.net ([216.218.151.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17m6Qb-0004T6-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Sep 2002 22:40:41 -0700
To: <Jean-Eric.Cuendet@linkvest.com>
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

This is a multi-part message in MIME format.

------=_NextPart_000_0011_01C2533A.A75C2E40
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi,
    i think, the nfsd is a kernel mode daemon, while the mountd is a =
userspace daemon.
    The mountd does the initial processing of the mount request, gets =
the file handle from the server and then sends it into the kernel by the =
nfsservctl interface.
     As to, why the mountd is not in kernel space, IMHO, it might not =
have beeen qualified to be there in the kernel.=20
=20

rgds,
Kedar.

------=_NextPart_000_0011_01C2533A.A75C2E40
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2600.0" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; i think, the nfsd is =
a kernel=20
mode daemon, while the mountd is a userspace daemon.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; The mountd does the =
initial=20
processing of the mount request, gets the file handle from the server =
and then=20
sends it into the kernel by the nfsservctl interface.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp;&nbsp; As to, why the =
mountd is=20
not in kernel space, IMHO, it might not have beeen qualified to be there =
in the=20
kernel.&nbsp;</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>rgds,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Kedar.</FONT></DIV></BODY></HTML>

------=_NextPart_000_0011_01C2533A.A75C2E40--



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
