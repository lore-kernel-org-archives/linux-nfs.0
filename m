From: "Stuckless, Colin" <cstuckless@petro-canada.ca>
Subject: RE: Some questions regarding NFS over TCP
Date: Tue, 27 Jul 2004 10:52:12 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <B9F4645CD7B0D511BE8300508B68C327025EB2F5@tnscapp02.pcacorp.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C473FA.1066585C"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpVCU-0000FT-Ns
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 09:53:14 -0700
Received: from pcx1.petro-canada.ca ([209.82.98.50] helo=pcaxs03.petro-canada.ca)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BpVCT-0004uz-Kz
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 09:53:14 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C473FA.1066585C
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net
> [mailto:nfs-admin@lists.sourceforge.net]
> Sent: Tuesday, July 27, 2004 12:41 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] Some questions regarding NFS over TCP
>=20
>=20
> 1)  We have a decent sized cluster utilizing NFS.  We=20
> currently use udp as the transport protocol.  One of the=20
> issues that we have is when running sync transfers are=20
> slow.  We recently moved to async in the /etc/exports=20
> on the servers.  This has helped some, but we still have=20
> some performance issues (I know that the server nodes can=20
> do more than 10 - 15 MB / sec NFS traffic). =20
> One of the things that I have seen alot of on the list lately=20
> is the use of TCP.  I have read the older documentation=20
> concerning NFS over TCP, and was wondering if the old=20
> disadvantages and advantages still hold true (ie,=20
> advantage:  GB servers to 100 MB clients better transfer=20
> rates, disadvantage: =20
> Server crash requires unmount of all cluster nodes that had=20
> the NFS server=20
> mounted).

> Norman Weathers
> SIP Linux Cluster
> TCE UNIX
> ConocoPhillips
> Houston, TX


Norman,

FWIW, my experience is with Solaris servers and Linux clients.
NFS over UDP may give you a small performance increase
in the general case, but it only takes one lost packet
to go from having a well behaved NFS environment to one
that will have you pulling your hair out trying to figure
out what's causing the intermittent performance problems.

The 100Mbit benchmarks I've run on TCP vs. UDP with Solaris as
the server and Linux as the client showed very similar
read/write speeds. If you ramp the wsize/rsize up on
the UDP mounts perhaps you can get a bit more throughput, but
then I found that 32K or larger rsize/wsize was not
reliable (one of the Linux client machines would eventually
bring the Solaris server to a near grinding halt during
heavy writes, like when running a seismic job). It could
takes days or weeks before you'd see a problem, but=20
eventually I always saw a problem when running UDP and=20
going above 8K rsize/wsize.=20

I think the documentation is maybe outdated - I think everyone
should be using TCP. Flow control is important, and TCP
does it much better than the recovery mechanism built
into NFS.


Colin Stuckless=20
cstuckless@petro-canada.ca








                         ********************

This email communication is intended as a private communication for the =
sole
use of the primary addressee and those individuals listed for copies in =
the
original message. The information contained in this email is private =
and
confidential and If you are not an intended recipient you are hereby
notified that copying, forwarding or other dissemination or =
distribution of
this communication by any means is prohibited.  If you are not =
specifically
authorized to receive this email and if you believe that you received =
it in
error please notify the original sender immediately.  We honour similar
requests relating to the privacy of email communications.

Cette communication par courrier =E9lectronique est une communication =
priv=E9e =E0
l'usage exclusif du destinataire principal ainsi que des personnes dont =
les
noms figurent en copie.  Les renseignements contenus dans ce courriel =
sont
confidentiels et si vous n'=EAtes pas le destinataire pr=E9vu, vous =
=EAtes avis=E9,
par les pr=E9sentes que toute reproduction, transfert ou autre forme de
diffusion de cette communication par quelque moyen que ce soit est
interdite.  Si vous n'=EAtes pas sp=E9cifiquement autoris=E9 =E0 =
recevoir ce
courriel ou si vous croyez l'avoir re=E7u par erreur, veuillez en =
aviser
l'exp=E9diteur original imm=E9diatement.  Nous respectons les demandes
similaires qui touchent la confidentialit=E9 des communications par =
courrier
=E9lectronique.

------_=_NextPart_001_01C473FA.1066585C
Content-Type: text/html;
	charset="iso-8859-1"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
<META NAME="Generator" CONTENT="MS Exchange Server version 5.5.2658.2">
<TITLE>RE: [NFS] Some questions regarding NFS over TCP</TITLE>
</HEAD>
<BODY>

<P><FONT SIZE=2>&gt; -----Original Message-----</FONT>
<BR><FONT SIZE=2>&gt; From: nfs-admin@lists.sourceforge.net</FONT>
<BR><FONT SIZE=2>&gt; [<A HREF="mailto:nfs-admin@lists.sourceforge.net">mailto:nfs-admin@lists.sourceforge.net</A>]</FONT>
<BR><FONT SIZE=2>&gt; Sent: Tuesday, July 27, 2004 12:41 PM</FONT>
<BR><FONT SIZE=2>&gt; To: nfs@lists.sourceforge.net</FONT>
<BR><FONT SIZE=2>&gt; Subject: [NFS] Some questions regarding NFS over TCP</FONT>
<BR><FONT SIZE=2>&gt; </FONT>
<BR><FONT SIZE=2>&gt; </FONT>
<BR><FONT SIZE=2>&gt; 1)&nbsp; We have a decent sized cluster utilizing NFS.&nbsp; We </FONT>
<BR><FONT SIZE=2>&gt; currently use udp as the transport protocol.&nbsp; One of the </FONT>
<BR><FONT SIZE=2>&gt; issues that we have is when running sync transfers are </FONT>
<BR><FONT SIZE=2>&gt; slow.&nbsp; We recently moved to async in the /etc/exports </FONT>
<BR><FONT SIZE=2>&gt; on the servers.&nbsp; This has helped some, but we still have </FONT>
<BR><FONT SIZE=2>&gt; some performance issues (I know that the server nodes can </FONT>
<BR><FONT SIZE=2>&gt; do more than 10 - 15 MB / sec NFS traffic).&nbsp; </FONT>
<BR><FONT SIZE=2>&gt; One of the things that I have seen alot of on the list lately </FONT>
<BR><FONT SIZE=2>&gt; is the use of TCP.&nbsp; I have read the older documentation </FONT>
<BR><FONT SIZE=2>&gt; concerning NFS over TCP, and was wondering if the old </FONT>
<BR><FONT SIZE=2>&gt; disadvantages and advantages still hold true (ie, </FONT>
<BR><FONT SIZE=2>&gt; advantage:&nbsp; GB servers to 100 MB clients better transfer </FONT>
<BR><FONT SIZE=2>&gt; rates, disadvantage:&nbsp; </FONT>
<BR><FONT SIZE=2>&gt; Server crash requires unmount of all cluster nodes that had </FONT>
<BR><FONT SIZE=2>&gt; the NFS server </FONT>
<BR><FONT SIZE=2>&gt; mounted).</FONT>
</P>

<P><FONT SIZE=2>&gt; Norman Weathers</FONT>
<BR><FONT SIZE=2>&gt; SIP Linux Cluster</FONT>
<BR><FONT SIZE=2>&gt; TCE UNIX</FONT>
<BR><FONT SIZE=2>&gt; ConocoPhillips</FONT>
<BR><FONT SIZE=2>&gt; Houston, TX</FONT>
</P>
<BR>

<P><FONT SIZE=2>Norman,</FONT>
</P>

<P><FONT SIZE=2>FWIW, my experience is with Solaris servers and Linux clients.</FONT>
<BR><FONT SIZE=2>NFS over UDP may give you a small performance increase</FONT>
<BR><FONT SIZE=2>in the general case, but it only takes one lost packet</FONT>
<BR><FONT SIZE=2>to go from having a well behaved NFS environment to one</FONT>
<BR><FONT SIZE=2>that will have you pulling your hair out trying to figure</FONT>
<BR><FONT SIZE=2>out what's causing the intermittent performance problems.</FONT>
</P>

<P><FONT SIZE=2>The 100Mbit benchmarks I've run on TCP vs. UDP with Solaris as</FONT>
<BR><FONT SIZE=2>the server and Linux as the client showed very similar</FONT>
<BR><FONT SIZE=2>read/write speeds. If you ramp the wsize/rsize up on</FONT>
<BR><FONT SIZE=2>the UDP mounts perhaps you can get a bit more throughput, but</FONT>
<BR><FONT SIZE=2>then I found that 32K or larger rsize/wsize was not</FONT>
<BR><FONT SIZE=2>reliable (one of the Linux client machines would eventually</FONT>
<BR><FONT SIZE=2>bring the Solaris server to a near grinding halt during</FONT>
<BR><FONT SIZE=2>heavy writes, like when running a seismic job). It could</FONT>
<BR><FONT SIZE=2>takes days or weeks before you'd see a problem, but </FONT>
<BR><FONT SIZE=2>eventually I always saw a problem when running UDP and </FONT>
<BR><FONT SIZE=2>going above 8K rsize/wsize. </FONT>
</P>

<P><FONT SIZE=2>I think the documentation is maybe outdated - I think everyone</FONT>
<BR><FONT SIZE=2>should be using TCP. Flow control is important, and TCP</FONT>
<BR><FONT SIZE=2>does it much better than the recovery mechanism built</FONT>
<BR><FONT SIZE=2>into NFS.</FONT>
</P>
<BR>

<P><FONT SIZE=2>Colin Stuckless </FONT>
<BR><FONT SIZE=2>cstuckless@petro-canada.ca</FONT>
</P>
<BR>
<BR>
<BR>
<BR>
<BR>
<BR>
<BR>

<P><FONT SIZE=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ********************</FONT>
</P>

<P><FONT SIZE=2>This email communication is intended as a private communication for the sole use of the primary addressee and those individuals listed for copies in the original message. The information contained in this email is private and confidential and If you are not an intended recipient you are hereby notified that copying, forwarding or other dissemination or distribution of this communication by any means is prohibited.&nbsp; If you are not specifically authorized to receive this email and if you believe that you received it in error please notify the original sender immediately.&nbsp; We honour similar requests relating to the privacy of email communications.</FONT></P>

<P><FONT SIZE=2>Cette communication par courrier électronique est une communication privée à l'usage exclusif du destinataire principal ainsi que des personnes dont les noms figurent en copie.&nbsp; Les renseignements contenus dans ce courriel sont confidentiels et si vous n'êtes pas le destinataire prévu, vous êtes avisé, par les présentes que toute reproduction, transfert ou autre forme de diffusion de cette communication par quelque moyen que ce soit est interdite.&nbsp; Si vous n'êtes pas spécifiquement autorisé à recevoir ce courriel ou si vous croyez l'avoir reçu par erreur, veuillez en aviser l'expéditeur original immédiatement.&nbsp; Nous respectons les demandes similaires qui touchent la confidentialité des communications par courrier électronique.</FONT></P>

</BODY>
</HTML>
------_=_NextPart_001_01C473FA.1066585C--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
