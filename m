From: "Matt Heaton" <admin@0catch.com>
Subject: Question about mounting....
Date: Fri, 31 Jan 2003 09:56:38 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <013001c2c949$b8a0d9a0$6601a8c0@userl3x55qxqed>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_012D_01C2C90F.0C174820"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc51.attbi.com ([204.127.198.38])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18eeT6-0008IG-00
	for <nfs@lists.sourceforge.net>; Fri, 31 Jan 2003 08:56:44 -0800
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

------=_NextPart_000_012D_01C2C90F.0C174820
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I am using this mount command on all my NFS clients

mount -o ro,vers=3D3,noatime,rsize=3D8192,intr 192.168.100.xxx:/dir /dir =
-t nfs

Which works very well, but the server is using the XFS filesystem.  =
When/if the server has a problem or goes down normally the=20
mount point is just fine until the server comes back up and then keeps =
going (It does this on our servers that use EXT3), but on our
NFS servers that use XFS filesystem they don't?  The client loses the =
mount (Still  shows up in a df, but shows 0 bytes for the size of the =
nfs mount).  I then have to unmount and then remount EVERY CLIENT =
everytime there is a problem with our NFS servers?!?! =20

Is there a problem with XFS and nfs mount points or am I dumb and =
missing some obvious mount option.  It is weird because it works great =
on all my EXT3 NFS servers.

Thanks,
Matt


------=_NextPart_000_012D_01C2C90F.0C174820
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
<DIV><FONT face=3DArial size=3D2>I am using this mount command on all my =
NFS=20
clients</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>mount -o =
ro,vers=3D3,noatime,rsize=3D8192,intr=20
192.168.100.xxx:/dir /dir -t nfs</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Which works very well, but the server =
is using the=20
XFS filesystem.&nbsp; When/if the server has a problem or goes down =
normally the=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>mount point is just fine until the =
server comes=20
back up and then keeps going (It does this on our servers that use =
EXT3), but on=20
our</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>NFS servers that use XFS filesystem =
they=20
don't?&nbsp; The client loses the mount (Still&nbsp; shows up in a df, =
but shows=20
0 bytes for the size of the nfs mount).&nbsp; I then have to unmount and =
then=20
remount EVERY CLIENT everytime there is a problem with our NFS =
servers?!?!&nbsp;=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Is there a problem with XFS and nfs =
mount points or=20
am I dumb and missing some obvious mount option.&nbsp; It is weird =
because it=20
works great on all my EXT3 NFS servers.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Thanks,<BR>Matt</FONT></DIV>
<DIV>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_012D_01C2C90F.0C174820--



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
