From: "Jeff Davis" <jeff@jrdavis.net>
Subject: linux nfs with dhcp using static hostnames and dynamic ips sometimes give getfh's on server
Date: Wed, 11 Feb 2004 22:23:27 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <008101c3f11f$f84fded0$0401a8c0@dell>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_007E_01C3F0ED.ABBBE8C0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ar8Oz-0003gQ-9C
	for nfs@lists.sourceforge.net; Wed, 11 Feb 2004 20:24:37 -0800
Received: from mail.hal-pc.org ([206.180.145.133])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ar8MJ-0001iB-H9
	for nfs@lists.sourceforge.net; Wed, 11 Feb 2004 20:21:51 -0800
Received: from [206.180.129.179] (HELO dell)
  by mail.hal-pc.org (CommuniGate Pro SMTP 3.5.9)
  with SMTP id 84577454 for nfs@lists.sourceforge.net; Wed, 11 Feb 2004 22:23:31 -0600
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

------=_NextPart_000_007E_01C3F0ED.ABBBE8C0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

linux clients running dhcp with static hostnames and dynamic ip. =
sometimes client host get different ip and start getting
permission denied on clients and on ther server see getfh errors

Feb 11 17:08:35 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:08:55 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:08:58 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:09:13 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:09:39 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:10:04 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:12:52 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:15:40 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:18:49 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:19:06 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:22:54 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:23:33 beo226 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:27:35 beo226 rpc.mountd: getfh failed: Operation not permitted

Feb 11 17:08:46 beo210 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:13:02 beo210 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:23:05 beo210 rpc.mountd: getfh failed: Operation not permitted
Feb 11 17:27:46 beo210 rpc.mountd: getfh failed: Operation not permitted

Feb 11 14:36:47 wolf126 rpc.mountd: getfh failed: Operation not =
permitted
Feb 11 14:43:28 wolf126 rpc.mountd: getfh failed: Operation not =
permitted
Feb 11 15:06:34 wolf126 rpc.mountd: getfh failed: Operation not =
permitted
Feb 11 15:10:14 wolf126 rpc.mountd: getfh failed: Operation not =
permitted
Feb 11 16:19:21 wolf126 rpc.mountd: getfh failed: Operation not =
permitted
Feb 11 16:25:34 wolf126 rpc.mountd: getfh failed: Operation not =
permitted
Feb 11 16:26:06 wolf126 rpc.mountd: getfh failed: Operation not =
permitted


variety of servers exhibiting this behavior
redhat 7.3 servers running 2.4.20 kernel and nfs-utils-1.0.6-1
redhat 6.2 servers running 2.2.4 and using redhat nfs-utils =
nfs-utils-0.3.3-1
redhat 7.3 server running 2.4.18-5 using redhat nfs-utils =
nfs-utils-0.3.3-6.73

not having problems accessing network appliance just linux nfs servers =
of various ilks

for most part clients and servers are working fine, just seems like =
problem
when ip is reused. exportfs -r and reboots helps but problem can still =
re-occur

clients are redhat enterprise linux ws v3.0 with all errata applied

none of these servers had problems for years until i started using dhcp =
clients with
static hostnames and dynamic ip addresses

i can provide any info that might be helpful

any ideas
------=_NextPart_000_007E_01C3F0ED.ABBBE8C0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1276" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>linux clients running dhcp with static =
hostnames=20
and dynamic ip. sometimes client host get different ip and start=20
getting</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>permission denied on clients and on =
ther server see=20
getfh errors</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Feb 11 17:08:35 beo226 rpc.mountd: =
getfh failed:=20
Operation not permitted</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Feb 11 17:08:55 beo226 rpc.mountd: =
getfh failed:=20
Operation not permitted<BR>Feb 11 17:08:58 beo226 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:09:13 beo226 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:09:39 beo226 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:10:04 beo226 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:12:52 beo226 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:15:40 beo226 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:18:49 beo226 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:19:06 beo226 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:22:54 beo226 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:23:33 beo226 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:27:35 beo226 rpc.mountd: getfh =
failed:=20
Operation not permitted</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Feb 11 17:08:46 beo210 rpc.mountd: =
getfh failed:=20
Operation not permitted<BR>Feb 11 17:13:02 beo210 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:23:05 beo210 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 17:27:46 beo210 rpc.mountd: getfh =
failed:=20
Operation not permitted</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Feb 11 14:36:47 wolf126 rpc.mountd: =
getfh failed:=20
Operation not permitted<BR>Feb 11 14:43:28 wolf126 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 15:06:34 wolf126 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 15:10:14 wolf126 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 16:19:21 wolf126 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 16:25:34 wolf126 rpc.mountd: getfh =
failed:=20
Operation not permitted<BR>Feb 11 16:26:06 wolf126 rpc.mountd: getfh =
failed:=20
Operation not permitted</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>variety of servers exhibiting this=20
behavior</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>redhat 7.3 servers running 2.4.20 =
kernel and=20
nfs-utils-1.0.6-1</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>redhat 6.2 servers running 2.2.4 and =
using redhat=20
nfs-utils nfs-utils-0.3.3-1</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>redhat 7.3 server running 2.4.18-5 =
using redhat=20
nfs-utils nfs-utils-0.3.3-6.73</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>not having problems accessing network =
appliance=20
just linux nfs servers of various ilks</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>for most part clients and servers are =
working fine,=20
just seems like problem</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>when ip is reused. exportfs -r and =
reboots helps=20
but problem can still re-occur</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>clients are redhat enterprise linux ws =
v3.0 with=20
all errata applied</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>none of these servers had problems for =
years until=20
i started using dhcp clients with</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>static hostnames and dynamic ip=20
addresses</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>i can provide any info that might be=20
helpful</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>any ideas</FONT></DIV></BODY></HTML>

------=_NextPart_000_007E_01C3F0ED.ABBBE8C0--



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
