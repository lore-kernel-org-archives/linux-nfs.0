From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: Multiple NICs server and NFS mount problem
Date: Thu, 23 Jun 2005 10:19:03 -0500
Message-ID: <EXCHG2003jQHtMFauky00000282@EXCHG2003.microtech-ks.com>
References: <7A9F5FB5F868FC45BA5A4C12361AB169A64AF3@MADTORMAIL.indra.es>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0481_01C577DC.FAFAFB70"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DlTSC-0005Q1-BF
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 08:17:20 -0700
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DlTSB-0002Lr-Kl
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 08:17:20 -0700
To: "'Barriuso Maicas, Rafael'" <rbarriuso@indra.es>,
	<nfs@lists.sourceforge.net>
In-Reply-To: <7A9F5FB5F868FC45BA5A4C12361AB169A64AF3@MADTORMAIL.indra.es>
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

------=_NextPart_000_0481_01C577DC.FAFAFB70
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

 
The only thing that comes to mind is check the dns setup ie
(/etc/resolv.conf) and 
see what it is doing.
 
If dns is slow lots of things get rather messy, and also make sure that the
addresses
you are using on the internal network is a proper public network, and not
one that
is owned by someone else, as if it is someone elses you machine will attempt
to hit their dns server every time.
 
                                      Roger 
                                      Atipa Technologies


  _____  

From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Barriuso Maicas,
Rafael
Sent: Thursday, June 23, 2005 10:00 AM
To: nfs@lists.sourceforge.net
Subject: [NFS] Multiple NICs server and NFS mount problem



Hello, 

I have a machine running Debian Linux as router and NFS server, with two
network interfaces, one connected to a big switched LAN (called eth1) and
the other to an isolated LAN (called eth0). The problem is that since the
day one interface (eth1) changed it's IP address (due to DHCP) the NFS
clients in the isolated LAN (therefore accesing via eth0 to the server)
began to have problems mounting the exported directories. The NFS clients
sometimes succeed in mounting the directory after a long delay and sometimes
they fail due to a RPC timeout. I have captured the network traffic and it
seems to be the server which is not responding to the mount call (RPC v.2
MNT v.1 CALL).

There are several strange things I've tested: 

- When I take down eth1 (the interface which changed IP address) the clients
can mount the NFS server perfectly without any delay. However if I unplug
the network cable without doing an "ifdown", it doesn't work. What's more,
if I force the old IP address which eth1 had, it works perfectly (!!).

- I've changed the NICs from two Intel 82540EM Gigabit Ethernet to two 3Com
3c905B (and therefore the kernel modules) but the behaviour remains the
same.

- I've tested it with other kernel versions (from 2.6.11 to 2.4.25 and a
default 2.6.11) and it remains the same. 

- I've stopped all non-nfs-related daemons and it remains the same. 

- I've looked for that old IP address inside all configuration files, but it
doesn't appear. 

- Finally I've tested in another machine, the same model as the other
server, but running a RedHat FC4 with it's NFS server, and neither it
works!!.

Here'sI a software and hardware description: 

- Machine: Dell Optiplex GX 270 with two Intel network interfaces (both
Intel 82540EM Gigabit Ethernet), one PCI and the other integrated in the
motherboard.

- O.S.: Debian Testing with Linux 2.6.11 kernel, with nfs-common package
(from apt) version 1:1.0.7-3 and nfs-kernel server package (from apt)
version 1:1.0.7-3.

I can't understand what's happening!. Does anyone know where's the problem?.


Thank you in advance, 
  Rafael. 



------=_NextPart_000_0481_01C577DC.FAFAFB70
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><TITLE>Multiple NICs server and NFS mount problem</TITLE>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2800.1400" name=3DGENERATOR></HEAD>
<BODY>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#0000ff=20
size=3D2></FONT>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
color=3D#0000ff size=3D2>The only thing that comes to mind is check the =
dns setup ie=20
(/etc/resolv.conf) and </FONT></SPAN></DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
color=3D#0000ff size=3D2>see what it is doing.</FONT></SPAN></DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
color=3D#0000ff size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
color=3D#0000ff size=3D2>If dns is slow lots of things get rather messy, =
and also=20
make sure that the addresses</FONT></SPAN></DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
color=3D#0000ff size=3D2>you are using on the internal network is a =
proper public=20
network, and not one that</FONT></SPAN></DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
color=3D#0000ff size=3D2>is owned by someone else, as if it is someone =
elses you=20
machine will attempt</FONT></SPAN></DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
color=3D#0000ff size=3D2>to hit their dns server every =
time.</FONT></SPAN></DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
color=3D#0000ff size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
color=3D#0000ff=20
size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;=20
Roger</FONT>&nbsp;</SPAN></DIV>
<DIV dir=3Dltr align=3Dleft><SPAN=20
class=3D457431615-23062005>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;<FONT=20
face=3DArial color=3D#0000ff size=3D2>&nbsp;&nbsp; Atipa=20
Technologies</FONT></SPAN></DIV><BR>
<BLOCKQUOTE=20
style=3D"PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px =
solid; MARGIN-RIGHT: 0px">
  <DIV class=3DOutlookMessageHeader lang=3Den-us dir=3Dltr align=3Dleft>
  <HR tabIndex=3D-1>
  <FONT face=3DTahoma size=3D2><B>From:</B> =
nfs-admin@lists.sourceforge.net=20
  [mailto:nfs-admin@lists.sourceforge.net] <B>On Behalf Of </B>Barriuso =
Maicas,=20
  Rafael<BR><B>Sent:</B> Thursday, June 23, 2005 10:00 AM<BR><B>To:</B>=20
  nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] Multiple NICs =
server and=20
  NFS mount problem<BR></FONT><BR></DIV>
  <DIV></DIV><!-- Converted from text/rtf format -->
  <P><FONT face=3DArial size=3D2>Hello,</FONT> </P>
  <P><FONT face=3DArial size=3D2>I have a machine running Debian Linux =
as router and=20
  NFS server, with two network interfaces, one connected to a big =
switched LAN=20
  (called eth1) and the other to an isolated LAN (called eth0). The =
problem is=20
  that since the day one interface (eth1) changed it's IP address (due =
to DHCP)=20
  the NFS clients in the isolated LAN (therefore accesing via eth0 to =
the=20
  server) began to have problems mounting the exported directories. The =
NFS=20
  clients sometimes succeed in mounting the directory after a long delay =
and=20
  sometimes they fail due to a RPC timeout. I have captured the network =
traffic=20
  and it seems to be the server which is not responding to the mount =
call (RPC=20
  v.2 MNT v.1 CALL).</FONT></P>
  <P><FONT face=3DArial size=3D2>There are several strange things I've=20
  tested:</FONT> </P>
  <P><FONT face=3DArial size=3D2>- When I take down eth1 (the interface =
which=20
  changed IP address) the clients can mount the NFS server perfectly =
without any=20
  delay. However if I unplug the network cable without doing an =
"ifdown", it=20
  doesn't work. What's more, if I force the old IP address which eth1 =
had, it=20
  works perfectly (!!).</FONT></P>
  <P><FONT face=3DArial size=3D2>- I've changed the NICs from two Intel =
82540EM=20
  Gigabit Ethernet to two 3Com 3c905B (and therefore the kernel modules) =
but the=20
  behaviour remains the same.</FONT></P>
  <P><FONT face=3DArial size=3D2>- I've tested it with other kernel =
versions (from=20
  2.6.11 to 2.4.25 and a default 2.6.11) and it remains the same.</FONT> =
</P>
  <P><FONT face=3DArial size=3D2>- I've stopped all non-nfs-related =
daemons and it=20
  remains the same.</FONT> </P>
  <P><FONT face=3DArial size=3D2>- I've looked for that old IP address =
inside all=20
  configuration files, but it doesn't appear.</FONT> </P>
  <P><FONT face=3DArial size=3D2>- Finally I've tested in another =
machine, the same=20
  model as the other server, but running a RedHat FC4 with it's NFS =
server, and=20
  neither it works!!.</FONT></P>
  <P><FONT face=3DArial size=3D2>Here'sI a software and hardware =
description:</FONT>=20
  </P>
  <P><FONT face=3DArial size=3D2>- Machine: Dell Optiplex GX 270 with =
two Intel=20
  network interfaces (both Intel 82540EM Gigabit Ethernet), one PCI and =
the=20
  other integrated in the motherboard.</FONT></P>
  <P><FONT face=3DArial size=3D2>- O.S.: Debian Testing with Linux =
2.6.11 kernel,=20
  with nfs-common package (from apt) version 1:1.0.7-3 and nfs-kernel =
server=20
  package (from apt) version 1:1.0.7-3.</FONT></P>
  <P><FONT face=3DArial size=3D2>I can't understand what's happening!. =
Does anyone=20
  know where's the problem?.</FONT> </P>
  <P><FONT face=3DArial size=3D2>Thank you in advance,</FONT> <BR><FONT =
face=3DArial=20
  size=3D2>&nbsp; Rafael.</FONT> </P><BR></BLOCKQUOTE></BODY></HTML>

------=_NextPart_000_0481_01C577DC.FAFAFB70--



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
