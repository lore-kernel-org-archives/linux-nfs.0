From: "=?iso-8859-1?Q?Thorsten_G=F6llner?=" <Thorsten.Goellner@Q1AG.de>
Subject: NFS performance question / (a)sync
Date: Fri, 26 Nov 2004 13:31:14 +0100
Message-ID: <021801c4d3b3$e40fe470$9842a8c0@thorsten1te>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0211_01C4D3BC.33B09760"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CXfEy-0005f8-Ed
	for nfs@lists.sourceforge.net; Fri, 26 Nov 2004 04:30:20 -0800
Received: from q1gw.q1ag.de ([213.61.218.181] helo=smtp.q1ag.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CXfEu-0004Do-5k
	for nfs@lists.sourceforge.net; Fri, 26 Nov 2004 04:30:20 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

------=_NextPart_000_0211_01C4D3BC.33B09760
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi,

i just installed an current kernel (2.4.27) with NFS V3 support and want =
to access via an nfs-mount from another machine.

My /etc/exports look like that:
/data     clientname(rw,sync,no_root_squash)

I mount it with "mount -t nfs servername:/data /data". Nothing uncommon =
so far.

When copying a file to the NFS-server I get a speed of 0,5 - 2,0 =
megabyte per second. Not really much.

When changing my /etc/exports to (ASYNC):
/data     clientname(rw,async,no_root_squash)

I get a speed of about 11 megabyte per sonds. That is what I expect from =
a 100 Mbit-Ethernet-card.

Is it "normal" that I reach only 0,5 - 2,0 megabyte per socond when =
using sync-transfer? I know what this means, but I did not expect such a =
performance drop.

Because I want to setup a heartbeat-cluster (with drbd) I think I have =
to use SYNC. I will try ASYNC tomorrow, but I expect corrupted files =
when the primary server fails and the ressources switch to the secondary =
server (with nfs service takeover).

Thank for any comments,
-Thorsten-
------=_NextPart_000_0211_01C4D3BC.33B09760
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2900.2180" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>i just installed an current kernel =
(2.4.27) with=20
NFS V3 support and want to access via an nfs-mount from another=20
machine.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>My /etc/exports look like =
that:</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>/data&nbsp;&nbsp;&nbsp;&nbsp;=20
clientname(rw,sync,no_root_squash)</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I mount it with "mount -t nfs =
servername:/data=20
/data". </FONT><FONT face=3DArial size=3D2>Nothing uncommon so =
far.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>When copying a file to the NFS-server I =
get a speed=20
of 0,5 - 2,0 megabyte per second. Not really much.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>When changing my /etc/exports to=20
(ASYNC):</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>
<DIV><FONT face=3DArial size=3D2>/data&nbsp;&nbsp;&nbsp;&nbsp;=20
clientname(rw,async,no_root_squash)</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV>I get a speed of about 11 megabyte per sonds. That is what I=20
expect&nbsp;from a 100 Mbit-Ethernet-card.</DIV>
<DIV>&nbsp;</DIV>
<DIV>Is it "normal" that I reach only 0,5 - 2,0 megabyte per socond when =
using=20
sync-transfer? I know what this means, but I did not expect such a =
performance=20
drop.</DIV>
<DIV>&nbsp;</DIV>
<DIV>Because I want to setup a heartbeat-cluster (with drbd) I think I =
have to=20
use SYNC. I will try ASYNC tomorrow, but I expect corrupted files when =
the=20
primary server fails and the ressources switch to the secondary server =
(with nfs=20
service takeover).</DIV>
<DIV>&nbsp;</DIV>
<DIV>Thank for any comments,</DIV>
<DIV>-Thorsten-</DIV></FONT></DIV></BODY></HTML>

------=_NextPart_000_0211_01C4D3BC.33B09760--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
