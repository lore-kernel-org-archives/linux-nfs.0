From: "Alan Witz" <awitz@magstarinc.com>
Subject: Corrupt Data when using NFS on Linux
Date: Mon, 28 Oct 2002 15:06:47 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <002d01c27ebd$8c017660$2864a8c0@alanw>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_002A_01C27E93.A2FC2100"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail4.uunet.ca ([209.167.141.34])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186GA6-0004mD-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Oct 2002 12:06:58 -0800
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

------=_NextPart_000_002A_01C27E93.A2FC2100
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I work for a small software company that recently began using NFS to =
implement a solution using a lesser-known database (Appgen).  The =
problem is that we're getting lots of corrupt database files in those =
files modified via NFS.  The on-line manual on linux.org makes the =
following reference which I think may be relevant:

  7.10. File Corruption When Using Multiple Clients
  If a file has been modified within one second of its previous =
modification and left the same size, it will continue to generate the =
same inode number. Because of this, constant reads and writes to a file =
by multiple clients may cause file corruption. Fixing this bug requires =
changes deep within the filesystem layer, and therefore it is a 2.5 =
item.=20

I was wondering if someone could clarify what is meant by this.  What is =
the relevance of the inode number?  And doesn't the inode of the file =
stay the same even if it is being modified?  Any help would be greatly =
appreciated.  Even some direction as to where else I might look would be =
helpful.  Thanks,

Alan Witz
------=_NextPart_000_002A_01C27E93.A2FC2100
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1106" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV>
<DIV><FONT face=3DArial size=3D2>I work for a small software company =
that recently=20
began using NFS to implement a solution using&nbsp;a lesser-known =
database=20
(Appgen).&nbsp; The problem is that we're getting lots of corrupt =
database files=20
in those files modified via NFS.&nbsp;&nbsp;The on-line manual&nbsp;on =
linux.org=20
makes the following reference which I think may be =
relevant:</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV class=3DSECT2>
<BLOCKQUOTE dir=3Dltr style=3D"MARGIN-RIGHT: 0px">
  <H2 class=3DSECT2><A name=3DSYMPTOM10><FONT face=3DArial =
size=3D2>7.10. File=20
  Corruption When Using Multiple Clients</FONT></H2>
  <P><FONT face=3DArial size=3D2>If a file has been modified within one =
second of=20
  its previous modification and left the same size, it will continue to =
generate=20
  the same inode number. Because of this, constant reads and writes to a =
file by=20
  multiple clients may cause file corruption. Fixing this bug requires =
changes=20
  deep within the filesystem layer, and therefore it is a 2.5 item.=20
</FONT></P></BLOCKQUOTE>
<P><FONT face=3DArial size=3D2>I was wondering if someone could clarify =
what is=20
meant by this.&nbsp; What is the relevance of the inode number?&nbsp; =
And=20
doesn't the inode of the file stay the same even if it is being =
modified?&nbsp;=20
Any help would be greatly appreciated.&nbsp; Even some direction as to =
where=20
else I might look would be helpful.&nbsp; Thanks,</FONT></P></DIV>
<DIV><FONT face=3DArial size=3D2>Alan =
Witz</FONT></DIV></A></DIV></BODY></HTML>

------=_NextPart_000_002A_01C27E93.A2FC2100--




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
