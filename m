From: "Barriuso Maicas, Rafael" <rbarriuso@indra.es>
Subject: Multiple NICs server and NFS mount problem
Date: Thu, 23 Jun 2005 16:59:51 +0200
Message-ID: <7A9F5FB5F868FC45BA5A4C12361AB169A64AF3@MADTORMAIL.indra.es>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C57804.34E5E76D"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DlTBT-0004dF-Nk
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 08:00:03 -0700
Received: from [213.170.46.108] (helo=madarrsmtp1.indra.es)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DlTBR-0006WH-Jr
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 08:00:03 -0700
To: <nfs@lists.sourceforge.net>
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

------_=_NextPart_001_01C57804.34E5E76D
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello,

I have a machine running Debian Linux as router and NFS server, with two =
network interfaces, one connected to a big switched LAN (called eth1) =
and the other to an isolated LAN (called eth0). The problem is that =
since the day one interface (eth1) changed it's IP address (due to DHCP) =
the NFS clients in the isolated LAN (therefore accesing via eth0 to the =
server) began to have problems mounting the exported directories. The =
NFS clients sometimes succeed in mounting the directory after a long =
delay and sometimes they fail due to a RPC timeout. I have captured the =
network traffic and it seems to be the server which is not responding to =
the mount call (RPC v.2 MNT v.1 CALL).

There are several strange things I've tested:

- When I take down eth1 (the interface which changed IP address) the =
clients can mount the NFS server perfectly without any delay. However if =
I unplug the network cable without doing an "ifdown", it doesn't work. =
What's more, if I force the old IP address which eth1 had, it works =
perfectly (!!).

- I've changed the NICs from two Intel 82540EM Gigabit Ethernet to two =
3Com 3c905B (and therefore the kernel modules) but the behaviour remains =
the same.

- I've tested it with other kernel versions (from 2.6.11 to 2.4.25 and a =
default 2.6.11) and it remains the same.

- I've stopped all non-nfs-related daemons and it remains the same.

- I've looked for that old IP address inside all configuration files, =
but it doesn't appear.

- Finally I've tested in another machine, the same model as the other =
server, but running a RedHat FC4 with it's NFS server, and neither it =
works!!.

Here'sI a software and hardware description:

- Machine: Dell Optiplex GX 270 with two Intel network interfaces (both =
Intel 82540EM Gigabit Ethernet), one PCI and the other integrated in the =
motherboard.
- O.S.: Debian Testing with Linux 2.6.11 kernel, with nfs-common package =
(from apt) version 1:1.0.7-3 and nfs-kernel server package (from apt) =
version 1:1.0.7-3.

I can't understand what's happening!. Does anyone know where's the =
problem?.

Thank you in advance,
  Rafael.



------_=_NextPart_001_01C57804.34E5E76D
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7226.0">
<TITLE>Multiple NICs server and NFS mount problem</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT SIZE=3D2 FACE=3D"Arial">Hello,</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">I have a machine running Debian Linux =
as router and NFS server, with two network interfaces, one connected to =
a big switched LAN (called eth1) and the other to an isolated LAN =
(called eth0). The problem is that since the day one interface (eth1) =
changed it's IP address (due to DHCP) the NFS clients in the isolated =
LAN (therefore accesing via eth0 to the server) began to have problems =
mounting the exported directories. The NFS clients sometimes succeed in =
mounting the directory after a long delay and sometimes they fail due to =
a RPC timeout. I have captured the network traffic and it seems to be =
the server which is not responding to the mount call (RPC v.2 MNT v.1 =
CALL).</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">There are several strange things I've =
tested:</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">- When I take down eth1 (the interface =
which changed IP address) the clients can mount the NFS server perfectly =
without any delay. However if I unplug the network cable without doing =
an &quot;ifdown&quot;, it doesn't work. What's more, if I force the old =
IP address which eth1 had, it works perfectly (!!).</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">- I've changed the NICs from two Intel =
82540EM Gigabit Ethernet to two 3Com 3c905B (and therefore the kernel =
modules) but the behaviour remains the same.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">- I've tested it with other kernel =
versions (from 2.6.11 to 2.4.25 and a default 2.6.11) and it remains the =
same.</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">- I've stopped all non-nfs-related =
daemons and it remains the same.</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">- I've looked for that old IP address =
inside all configuration files, but it doesn't appear.</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">- Finally I've tested in another =
machine, the same model as the other server, but running a RedHat FC4 =
with it's NFS server, and neither it works!!.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Here'sI a software and hardware =
description:</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">- Machine: Dell Optiplex GX 270 with =
two Intel network interfaces (both Intel 82540EM Gigabit Ethernet), one =
PCI and the other integrated in the motherboard.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">- O.S.: Debian Testing with Linux =
2.6.11 kernel, with nfs-common package (from apt) version 1:1.0.7-3 and =
nfs-kernel server package (from apt) version 1:1.0.7-3.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">I can't understand what's happening!. =
Does anyone know where's the problem?.</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Thank you in advance,</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp; Rafael.</FONT>
</P>
<BR>

</BODY>
</HTML>
------_=_NextPart_001_01C57804.34E5E76D--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
