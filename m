From: "Matt Heaton" <admin@0catch.com>
Subject: Caching
Date: Thu, 28 Mar 2002 11:39:19 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <01c201c1d716$5fae10e0$6601a8c0@c1886657a>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_01BF_01C1D6DB.B32F06B0"
Received: from rwcrmhc51.attbi.com ([204.127.198.38])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16qYDS-00018h-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Mar 2002 03:37:14 -0800
Received: from c1886657a ([12.254.138.126]) by rwcrmhc51.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with SMTP
          id <20020328113708.DYGD2626.rwcrmhc51.attbi.com@c1886657a>
          for <nfs@lists.sourceforge.net>; Thu, 28 Mar 2002 11:37:08 +0000
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_01BF_01C1D6DB.B32F06B0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I have an NFS server that is 99% reads and 1% writes.   When I do writes =
the NFS server (Or maybe the client) seems to cache files so that when a
write occurs my NFS clients don't get the updated files for a while.  Is =
there some way to expire the cache whenever a write occurs for a =
specific
file?  I want the cache to be in place as 99% of all NFS service is =
reads on my network, I just want updates available right away for the =
writes?  Any
clues?  I am running 2.4.18 with NFS_ALL patch compiled in on the =
clients, and 2.4.18 (No patch) for the server.

Thanks,
Matt


------=_NextPart_000_01BF_01C1D6DB.B32F06B0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2713.1100" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>I have an NFS server that is 99% reads =
and 1%=20
writes.&nbsp;&nbsp; When I do writes the NFS server (Or maybe the =
client) seems=20
to cache files so that when&nbsp;a</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>write occurs my NFS clients don't get =
the updated=20
files for a while.&nbsp; Is there some way to expire the cache whenever =
a write=20
occurs for a specific</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>file?&nbsp; I want the cache to be in =
place as 99%=20
of all NFS service is reads on&nbsp;my network, I just want updates =
available=20
right away for the writes?&nbsp; Any</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>clues?&nbsp; I am running 2.4.18 with =
NFS_ALL patch=20
compiled in on the clients, and 2.4.18 (No patch) for the =
server.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Thanks,<BR>Matt</FONT></DIV>
<DIV>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_01BF_01C1D6DB.B32F06B0--


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
