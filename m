From: "Matt Heaton" <admin@0catch.com>
Subject: Problem with requests...
Date: Wed, 4 Jun 2003 12:28:18 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <11b201c32ac7$12191cc0$e2a446a6@mattscomputer>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_11AF_01C32A94.C75E7A90"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mgr1.xmission.com ([198.60.22.201])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Nd0g-0008Pk-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Jun 2003 11:29:18 -0700
Received: from mail by mgr1.xmission.com with spam-scanned (Exim 3.35 #1)
	id 19Nd0f-00089l-01
	for nfs@lists.sourceforge.net; Wed, 04 Jun 2003 12:29:17 -0600
Received: from [166.70.164.233] (helo=mattscomputer)
	by mgr1.xmission.com with smtp (Exim 3.35 #1)
	id 19Nd0f-000891-01
	for nfs@lists.sourceforge.net; Wed, 04 Jun 2003 12:29:17 -0600
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

------=_NextPart_000_11AF_01C32A94.C75E7A90
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi all, I have a pretty big NFS server (2 Terabytes), running redhat =
linux with custom 2.4.20 kernel with XFS fs.

In the last 48 hours I have started getting the following error:

"kernel BUG at ll_rw_blk.c:1192!"

Jun  4 03:49:38 catchusers2 kernel:  kernel BUG at ll_rw_blk.c:1192!
Jun  4 03:49:38 catchusers2 kernel: invalid operand: 0000
Jun  4 03:49:38 catchusers2 kernel: CPU:    0
Jun  4 03:49:38 catchusers2 kernel: EIP:    0010:[<c024b027>]    Not =
tainted
Jun  4 03:49:38 catchusers2 kernel: EFLAGS: 00010206
Jun  4 03:49:38 catchusers2 kernel: eax: 00000410   ebx: 00000008   ecx: =
cefd0d20   edx: cefd0d20
Jun  4 03:49:38 catchusers2 kernel: esi: 00000001   edi: cefd0d20   ebp: =
c1b6c1b0   esp: e02d3cbc
Jun  4 03:49:38 catchusers2 kernel: ds: 0018   es: 0018   ss: 0018
Jun  4 03:49:38 catchusers2 kernel: Process nfsd (pid: 1368, =
stackpage=3De02d3000)
Jun  4 03:49:38 catchusers2 kernel: Stack: cefd0d20 00000001 cefd0d20 =
00000001 c0145a10 00000001 cefd0d20=20

I get two of three of these and then NFS locks up completely and my =
server shuts down.  This sounds like some kind of request queue filling =
up from what I can gather on the net.  I am desperate now!  Does anyone =
know what causes this exactly and if there is any remedy.  I would most =
appreciative if anyone can offer any suggestions.  I know my NFS server =
will go down a couple of more times today until I fix it.

Thanks,
Matt


------=_NextPart_000_11AF_01C32A94.C75E7A90
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2726.2500" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi all, I have a pretty big NFS server =
(2=20
Terabytes), running redhat linux with custom 2.4.20 kernel with XFS=20
fs.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>In the last 48 hours I have started =
getting the=20
following error:</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>"kernel BUG at =
ll_rw_blk.c:1192!"</FONT></DIV><FONT=20
face=3DArial size=3D2>
<DIV><BR>Jun&nbsp; 4 03:49:38 catchusers2 kernel:&nbsp; kernel BUG at=20
ll_rw_blk.c:1192!<BR>Jun&nbsp; 4 03:49:38 catchusers2 kernel: invalid =
operand:=20
0000<BR>Jun&nbsp; 4 03:49:38 catchusers2 kernel: CPU:&nbsp;&nbsp;&nbsp;=20
0<BR>Jun&nbsp; 4 03:49:38 catchusers2 kernel: EIP:&nbsp;&nbsp;&nbsp;=20
0010:[&lt;c024b027&gt;]&nbsp;&nbsp;&nbsp; Not tainted<BR>Jun&nbsp; 4 =
03:49:38=20
catchusers2 kernel: EFLAGS: 00010206<BR>Jun&nbsp; 4 03:49:38 catchusers2 =
kernel:=20
eax: 00000410&nbsp;&nbsp; ebx: 00000008&nbsp;&nbsp; ecx: =
cefd0d20&nbsp;&nbsp;=20
edx: cefd0d20<BR>Jun&nbsp; 4 03:49:38 catchusers2 kernel: esi:=20
00000001&nbsp;&nbsp; edi: cefd0d20&nbsp;&nbsp; ebp: c1b6c1b0&nbsp;&nbsp; =
esp:=20
e02d3cbc<BR>Jun&nbsp; 4 03:49:38 catchusers2 kernel: ds: =
0018&nbsp;&nbsp; es:=20
0018&nbsp;&nbsp; ss: 0018<BR>Jun&nbsp; 4 03:49:38 catchusers2 kernel: =
Process=20
nfsd (pid: 1368, stackpage=3De02d3000)<BR>Jun&nbsp; 4 03:49:38 =
catchusers2 kernel:=20
Stack: cefd0d20 00000001 cefd0d20 00000001 c0145a10 00000001 cefd0d20 =
</DIV>
<DIV>&nbsp;</DIV>
<DIV>I get two of three of these and then NFS locks up completely and my =
server=20
shuts down.&nbsp; This sounds like some kind of request queue filling up =
from=20
what I can gather on the net.&nbsp; I am desperate now!&nbsp; Does =
anyone know=20
what causes this exactly and if there is any remedy.&nbsp; I would most=20
appreciative if anyone can offer any suggestions.&nbsp; I know my NFS =
server=20
will go down a couple of more times today until I fix it.</DIV>
<DIV>&nbsp;</DIV>
<DIV>Thanks,</DIV>
<DIV>Matt</DIV>
<DIV></FONT>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_11AF_01C32A94.C75E7A90--




-------------------------------------------------------
This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
thread debugger on the planet. Designed with thread debugging features
you've never dreamed of, try TotalView 6 free at www.etnus.com.
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
