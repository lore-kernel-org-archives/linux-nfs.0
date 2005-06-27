From: "Barriuso Maicas, Rafael" <rbarriuso@indra.es>
Subject: RE: Multiple NICs server and NFS mount problem
Date: Mon, 27 Jun 2005 16:12:35 +0200
Message-ID: <7A9F5FB5F868FC45BA5A4C12361AB169A64B14@MADTORMAIL.indra.es>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C57B22.4469C205"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DmuM4-0007nb-UV
	for nfs@lists.sourceforge.net; Mon, 27 Jun 2005 07:12:56 -0700
Received: from [213.170.46.108] (helo=madarrsmtp1.indra.es)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DmuM1-0002Xz-Rd
	for nfs@lists.sourceforge.net; Mon, 27 Jun 2005 07:12:56 -0700
To: "Roger Heflin" <rheflin@atipa.com>, <nfs@lists.sourceforge.net>
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

------_=_NextPart_001_01C57B22.4469C205
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

We've solved it!!!.
We wrote some names for the IP addresses of the NFS clients in the file =
/etc/hosts of the server and now it works!.
We think the problem was that the NFS server tried to do an inverse name =
lookup using a slow external DNS server which blocked it and caused the =
NFS clients to timeout.
It's curious that the NFS server has to do an inverse name lookup.
=20
Thank you all.
  Rafael.
=20
=20
=20

-----Mensaje original-----
De: Roger Heflin [mailto:rheflin@atipa.com]
Enviado el: jueves, 23 de junio de 2005 17:19
Para: Barriuso Maicas, Rafael; nfs@lists.sourceforge.net
Asunto: RE: [NFS] Multiple NICs server and NFS mount problem


=20
The only thing that comes to mind is check the dns setup ie =
(/etc/resolv.conf) and=20
see what it is doing.
=20
If dns is slow lots of things get rather messy, and also make sure that =
the addresses
you are using on the internal network is a proper public network, and =
not one that
is owned by someone else, as if it is someone elses you machine will =
attempt
to hit their dns server every time.
=20
                                      Roger=20
                                      Atipa Technologies


  _____ =20

From: nfs-admin@lists.sourceforge.net =
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Barriuso Maicas, =
Rafael
Sent: Thursday, June 23, 2005 10:00 AM
To: nfs@lists.sourceforge.net
Subject: [NFS] Multiple NICs server and NFS mount problem



Hello,=20

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

There are several strange things I've tested:=20

- When I take down eth1 (the interface which changed IP address) the =
clients can mount the NFS server perfectly without any delay. However if =
I unplug the network cable without doing an "ifdown", it doesn't work. =
What's more, if I force the old IP address which eth1 had, it works =
perfectly (!!).

- I've changed the NICs from two Intel 82540EM Gigabit Ethernet to two =
3Com 3c905B (and therefore the kernel modules) but the behaviour remains =
the same.

- I've tested it with other kernel versions (from 2.6.11 to 2.4.25 and a =
default 2.6.11) and it remains the same.=20

- I've stopped all non-nfs-related daemons and it remains the same.=20

- I've looked for that old IP address inside all configuration files, =
but it doesn't appear.=20

- Finally I've tested in another machine, the same model as the other =
server, but running a RedHat FC4 with it's NFS server, and neither it =
works!!.

Here'sI a software and hardware description:=20

- Machine: Dell Optiplex GX 270 with two Intel network interfaces (both =
Intel 82540EM Gigabit Ethernet), one PCI and the other integrated in the =
motherboard.

- O.S.: Debian Testing with Linux 2.6.11 kernel, with nfs-common package =
(from apt) version 1:1.0.7-3 and nfs-kernel server package (from apt) =
version 1:1.0.7-3.

I can't understand what's happening!. Does anyone know where's the =
problem?.=20

Thank you in advance,=20
  Rafael.=20



------_=_NextPart_001_01C57B22.4469C205
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<TITLE>Multiple NICs server and NFS mount problem</TITLE>

<META content=3D"MSHTML 6.00.2800.1479" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D990580514-27062005><FONT face=3DArial color=3D#0000ff =
size=3D2>We've=20
solved it!!!.</FONT></SPAN></DIV>
<DIV><SPAN class=3D990580514-27062005><FONT face=3DArial color=3D#0000ff =
size=3D2>We=20
wrote some names for the IP addresses of the NFS clients in the file =
/etc/hosts=20
of the server and now it works!.</FONT></SPAN></DIV>
<DIV><SPAN class=3D990580514-27062005><FONT face=3DArial color=3D#0000ff =
size=3D2>We=20
think the problem was that the NFS server tried to do an inverse name =
lookup=20
using a slow external DNS server which blocked it and caused the NFS =
clients to=20
timeout.</FONT></SPAN></DIV>
<DIV><SPAN class=3D990580514-27062005><FONT face=3DArial color=3D#0000ff =
size=3D2>It's=20
curious that the NFS server has to do an inverse name=20
lookup.</FONT></SPAN></DIV>
<DIV><SPAN class=3D990580514-27062005><FONT face=3DArial color=3D#0000ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D990580514-27062005><FONT face=3DArial color=3D#0000ff =
size=3D2>Thank=20
you all.</FONT></SPAN></DIV>
<DIV><SPAN class=3D990580514-27062005><FONT face=3DArial color=3D#0000ff =
size=3D2>&nbsp;=20
Rafael.</FONT></SPAN></DIV>
<DIV><SPAN class=3D990580514-27062005><FONT face=3DArial color=3D#0000ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D990580514-27062005><FONT face=3DArial color=3D#0000ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D990580514-27062005><FONT face=3DArial color=3D#0000ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<BLOCKQUOTE dir=3Dltr style=3D"MARGIN-RIGHT: 0px">
  <DIV class=3DOutlookMessageHeader dir=3Dltr align=3Dleft><FONT =
face=3DTahoma=20
  size=3D2>-----Mensaje original-----<BR><B>De:</B> Roger Heflin=20
  [mailto:rheflin@atipa.com]<BR><B>Enviado el:</B> jueves, 23 de junio =
de 2005=20
  17:19<BR><B>Para:</B> Barriuso Maicas, Rafael;=20
  nfs@lists.sourceforge.net<BR><B>Asunto:</B> RE: [NFS] Multiple NICs =
server and=20
  NFS mount problem<BR><BR></FONT></DIV>
  <DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#0000ff=20
  size=3D2></FONT>&nbsp;</DIV>
  <DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
  color=3D#0000ff size=3D2>The only thing that comes to mind is check =
the dns setup=20
  ie (/etc/resolv.conf) and </FONT></SPAN></DIV>
  <DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
  color=3D#0000ff size=3D2>see what it is doing.</FONT></SPAN></DIV>
  <DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
  color=3D#0000ff size=3D2></FONT></SPAN>&nbsp;</DIV>
  <DIV dir=3Dltr align=3Dleft><SPAN class=3D457431615-23062005><FONT =
face=3DArial=20
  color=3D#0000ff size=3D2>If dns is slow lots of things get rather =
messy, and also=20
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
  =
size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;=20
  Roger</FONT>&nbsp;</SPAN></DIV>
  <DIV dir=3Dltr align=3Dleft><SPAN=20
  =
class=3D457431615-23062005>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;<FONT=20
  face=3DArial color=3D#0000ff size=3D2>&nbsp;&nbsp; Atipa=20
  Technologies</FONT></SPAN></DIV><BR>
  <BLOCKQUOTE=20
  style=3D"PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px =
solid; MARGIN-RIGHT: 0px">
    <DIV class=3DOutlookMessageHeader lang=3Den-us dir=3Dltr =
align=3Dleft>
    <HR tabIndex=3D-1>
    <FONT face=3DTahoma size=3D2><B>From:</B> =
nfs-admin@lists.sourceforge.net=20
    [mailto:nfs-admin@lists.sourceforge.net] <B>On Behalf Of =
</B>Barriuso=20
    Maicas, Rafael<BR><B>Sent:</B> Thursday, June 23, 2005 10:00=20
    AM<BR><B>To:</B> nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] =
Multiple=20
    NICs server and NFS mount problem<BR></FONT><BR></DIV>
    <DIV></DIV><!-- Converted from text/rtf format -->
    <P><FONT face=3DArial size=3D2>Hello,</FONT> </P>
    <P><FONT face=3DArial size=3D2>I have a machine running Debian Linux =
as router=20
    and NFS server, with two network interfaces, one connected to a big =
switched=20
    LAN (called eth1) and the other to an isolated LAN (called eth0). =
The=20
    problem is that since the day one interface (eth1) changed it's IP =
address=20
    (due to DHCP) the NFS clients in the isolated LAN (therefore =
accesing via=20
    eth0 to the server) began to have problems mounting the exported=20
    directories. The NFS clients sometimes succeed in mounting the =
directory=20
    after a long delay and sometimes they fail due to a RPC timeout. I =
have=20
    captured the network traffic and it seems to be the server which is =
not=20
    responding to the mount call (RPC v.2 MNT v.1 CALL).</FONT></P>
    <P><FONT face=3DArial size=3D2>There are several strange things I've =

    tested:</FONT> </P>
    <P><FONT face=3DArial size=3D2>- When I take down eth1 (the =
interface which=20
    changed IP address) the clients can mount the NFS server perfectly =
without=20
    any delay. However if I unplug the network cable without doing an =
"ifdown",=20
    it doesn't work. What's more, if I force the old IP address which =
eth1 had,=20
    it works perfectly (!!).</FONT></P>
    <P><FONT face=3DArial size=3D2>- I've changed the NICs from two =
Intel 82540EM=20
    Gigabit Ethernet to two 3Com 3c905B (and therefore the kernel =
modules) but=20
    the behaviour remains the same.</FONT></P>
    <P><FONT face=3DArial size=3D2>- I've tested it with other kernel =
versions (from=20
    2.6.11 to 2.4.25 and a default 2.6.11) and it remains the =
same.</FONT> </P>
    <P><FONT face=3DArial size=3D2>- I've stopped all non-nfs-related =
daemons and it=20
    remains the same.</FONT> </P>
    <P><FONT face=3DArial size=3D2>- I've looked for that old IP address =
inside all=20
    configuration files, but it doesn't appear.</FONT> </P>
    <P><FONT face=3DArial size=3D2>- Finally I've tested in another =
machine, the=20
    same model as the other server, but running a RedHat FC4 with it's =
NFS=20
    server, and neither it works!!.</FONT></P>
    <P><FONT face=3DArial size=3D2>Here'sI a software and hardware=20
    description:</FONT> </P>
    <P><FONT face=3DArial size=3D2>- Machine: Dell Optiplex GX 270 with =
two Intel=20
    network interfaces (both Intel 82540EM Gigabit Ethernet), one PCI =
and the=20
    other integrated in the motherboard.</FONT></P>
    <P><FONT face=3DArial size=3D2>- O.S.: Debian Testing with Linux =
2.6.11 kernel,=20
    with nfs-common package (from apt) version 1:1.0.7-3 and nfs-kernel =
server=20
    package (from apt) version 1:1.0.7-3.</FONT></P>
    <P><FONT face=3DArial size=3D2>I can't understand what's happening!. =
Does anyone=20
    know where's the problem?.</FONT> </P>
    <P><FONT face=3DArial size=3D2>Thank you in advance,</FONT> =
<BR><FONT face=3DArial=20
    size=3D2>&nbsp; Rafael.</FONT> =
</P><BR></BLOCKQUOTE></BLOCKQUOTE></BODY></HTML>

------_=_NextPart_001_01C57B22.4469C205--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
