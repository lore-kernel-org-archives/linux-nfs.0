From: "Muhammad Sibtain Bashir" <sibtain@pseb.org.pk>
Subject: NFS Problem
Date: Wed, 11 Dec 2002 16:41:50 +0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <000801c2a10a$4c393e40$08a0d7cb@pseb2>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0005_01C2A134.346598C0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [203.215.160.2] (helo=isb.pseb.org.pk ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18M5FZ-000333-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Dec 2002 03:42:01 -0800
Received: from pseb2 ([203.215.160.8])
	by isb.pseb.org.pk (8.11.0/8.11.0) with SMTP id gBBBeqc30755
	for <nfs@lists.sourceforge.net>; Wed, 11 Dec 2002 16:40:52 +0500
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

------=_NextPart_000_0005_01C2A134.346598C0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Dear sir=20

i am using NFS server , instead of using the domain names i am using the =
IP addresses of my clients machines=20
 the file /etc/export looks like

/google                     203.215.160.2(rw)
/345                        203.215.160.2(rw)
/mnt/cdrom              203.215.160.2(rw)

now when i mount the directories on my client machine it get mounted =
okay and i can read any file in the mounted directories but as above i =
have given the write permision as well ,but i cant write any thing  and =
this message show   * permission denied*.


waiting for response plz .

regards

Muhammad Sibtain

------=_NextPart_000_0005_01C2A134.346598C0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1126" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Dear sir </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>i am using NFS server , instead of =
using the domain=20
names i am using the IP addresses of my clients machines </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;the file /etc/export looks =
like</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial=20
size=3D2>/google&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp;=20
203.215.160.2(rw)<BR>/345&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp;=20
203.215.160.2(rw)<BR>/mnt/cdrom&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
203.215.160.2(rw)</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>now when i mount the directories on my =
client=20
machine it get mounted okay and i can read any file in the mounted =
directories=20
but as above i have given the write permision as well ,but i cant write =
any=20
thing&nbsp; and this message show&nbsp;&nbsp;&nbsp;* permission=20
denied*.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>waiting for response plz .</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>regards</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Muhammad =
Sibtain<BR></FONT></DIV></BODY></HTML>

------=_NextPart_000_0005_01C2A134.346598C0--




-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
