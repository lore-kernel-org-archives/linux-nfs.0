From: "Stuckless, Colin  709 778-3815" <cstuckless@petro-canada.ca>
Subject: RE: Need help with NFSD hang in 2.4.20+NFS_ALL
Date: Tue, 10 Jun 2003 13:35:25 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <B9F4645CD7B0D511BE8300508B68C327025EA99C@tnscapp02.pcacorp.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C32F87.70C9A720"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pcx1.petro-canada.ca ([209.82.98.50] helo=pcaxs03.petro-canada.ca)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Pou3-00027i-00
	for <nfs@lists.sourceforge.net>; Tue, 10 Jun 2003 12:35:33 -0700
To: nfs@lists.sourceforge.net
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C32F87.70C9A720
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


> -----Original Message-----
> From: Matthew Mitchell [mailto:matthew@geodev.com]
> Sent: Tuesday, June 10, 2003 1:26 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] Need help with NFSD hang in 2.4.20+NFS_ALL
>=20
>=20
> Everyone,
>=20
> This morning I arrived at the office to find an NFS server=20
> hung up and=20
> users whining at me.
>=20
> It appeared that an updatedb launched from a cron job had gotten hung =

> up.  Perhaps it caused some sort of overload, I'm not really sure.=20
> System load was over 130, which is about what I expected=20
> given that we=20
> had 128 nfs daemon threads, all of which were presumably waiting.


Matthew,

I don't have a proper solution to offer, but I feel your pain.

We're running a couple of dual-CPU boxes for our reservoir simulations
on RedHat 7.3 and ran into the same issue. I removed the offending=20
slocate.cron entry from /etc/cron.daily as it didn't seem to be=20
obeying the default switch to skip NFS mounted filesystems.

I have a question for you though - what distribution are you running
and what's the background on the 2.4.20+NFS_ALL kernel? I've been
running 2.4.18-27.7xsmp lately to try to find a decent NFS client
implementation that doesn't bring our Solaris 2.6 fileserver to
it's knees under heavy write activity (using NFS v3, UDP, =
r/wsize=3D8192).

Colin Stuckless=20







                         ********************

This email communication is intended as a private communication for the =
sole
use of the primary addressee and those individuals listed for copies in =
the
original message. The information contained in this email is private =
and
confidential and if you are not an intended recipient you are hereby
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
par les pr=E9sentes que toute reproduction, tout transfert ou toute =
autre
forme de diffusion de cette communication par quelque moyen que ce soit =
est
interdit.  Si vous n'=EAtes pas sp=E9cifiquement autoris=E9 =E0 =
recevoir ce courriel
ou si vous croyez l'avoir re=E7u par erreur, veuillez en aviser =
l'exp=E9diteur
original imm=E9diatement.  Nous respectons les demandes similaires qui
touchent la confidentialit=E9 des communications par courrier =
=E9lectronique.

------_=_NextPart_001_01C32F87.70C9A720
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
5.5.2655.35">
<TITLE>RE: [NFS] Need help with NFSD hang in 2.4.20+NFS_ALL</TITLE>
</HEAD>
<BODY>
<BR>

<P><FONT SIZE=3D2>&gt; -----Original Message-----</FONT>
<BR><FONT SIZE=3D2>&gt; From: Matthew Mitchell [<A =
HREF=3D"mailto:matthew@geodev.com">mailto:matthew@geodev.com</A>]</FONT>=

<BR><FONT SIZE=3D2>&gt; Sent: Tuesday, June 10, 2003 1:26 PM</FONT>
<BR><FONT SIZE=3D2>&gt; To: nfs@lists.sourceforge.net</FONT>
<BR><FONT SIZE=3D2>&gt; Subject: [NFS] Need help with NFSD hang in =
2.4.20+NFS_ALL</FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; Everyone,</FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; This morning I arrived at the office to find an =
NFS server </FONT>
<BR><FONT SIZE=3D2>&gt; hung up and </FONT>
<BR><FONT SIZE=3D2>&gt; users whining at me.</FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; It appeared that an updatedb launched from a =
cron job had gotten hung </FONT>
<BR><FONT SIZE=3D2>&gt; up.&nbsp; Perhaps it caused some sort of =
overload, I'm not really sure. </FONT>
<BR><FONT SIZE=3D2>&gt; System load was over 130, which is about what I =
expected </FONT>
<BR><FONT SIZE=3D2>&gt; given that we </FONT>
<BR><FONT SIZE=3D2>&gt; had 128 nfs daemon threads, all of which were =
presumably waiting.</FONT>
</P>
<BR>

<P><FONT SIZE=3D2>Matthew,</FONT>
</P>

<P><FONT SIZE=3D2>I don't have a proper solution to offer, but I feel =
your pain.</FONT>
</P>

<P><FONT SIZE=3D2>We're running a couple of dual-CPU boxes for our =
reservoir simulations</FONT>
<BR><FONT SIZE=3D2>on RedHat 7.3 and ran into the same issue. I removed =
the offending </FONT>
<BR><FONT SIZE=3D2>slocate.cron entry from /etc/cron.daily as it didn't =
seem to be </FONT>
<BR><FONT SIZE=3D2>obeying the default switch to skip NFS mounted =
filesystems.</FONT>
</P>

<P><FONT SIZE=3D2>I have a question for you though - what distribution =
are you running</FONT>
<BR><FONT SIZE=3D2>and what's the background on the 2.4.20+NFS_ALL =
kernel? I've been</FONT>
<BR><FONT SIZE=3D2>running 2.4.18-27.7xsmp lately to try to find a =
decent NFS client</FONT>
<BR><FONT SIZE=3D2>implementation that doesn't bring our Solaris 2.6 =
fileserver to</FONT>
<BR><FONT SIZE=3D2>it's knees under heavy write activity (using NFS v3, =
UDP, r/wsize=3D8192).</FONT>
</P>

<P><FONT SIZE=3D2>Colin Stuckless </FONT>
</P>
<BR>
<BR>
<BR>
<BR>
<BR>
<BR>

<P><FONT =
SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; ********************</FONT>
</P>

<P><FONT SIZE=3D2>This email communication is intended as a private =
communication for the sole use of the primary addressee and those =
individuals listed for copies in the original message. The information =
contained in this email is private and confidential and if you are not =
an intended recipient you are hereby notified that copying, forwarding =
or other dissemination or distribution of this communication by any =
means is prohibited.&nbsp; If you are not specifically authorized to =
receive this email and if you believe that you received it in error =
please notify the original sender immediately.&nbsp; We honour similar =
requests relating to the privacy of email communications.</FONT></P>

<P><FONT SIZE=3D2>Cette communication par courrier =E9lectronique est =
une communication priv=E9e =E0 l'usage exclusif du destinataire =
principal ainsi que des personnes dont les noms figurent en =
copie.&nbsp; Les renseignements contenus dans ce courriel sont =
confidentiels et si vous n'=EAtes pas le destinataire pr=E9vu, vous =
=EAtes avis=E9, par les pr=E9sentes que toute reproduction, tout =
transfert ou toute autre forme de diffusion de cette communication par =
quelque moyen que ce soit est interdit.&nbsp; Si vous n'=EAtes pas =
sp=E9cifiquement autoris=E9 =E0 recevoir ce courriel ou si vous croyez =
l'avoir re=E7u par erreur, veuillez en aviser l'exp=E9diteur original =
imm=E9diatement.&nbsp; Nous respectons les demandes similaires qui =
touchent la confidentialit=E9 des communications par courrier =
=E9lectronique.</FONT></P>

</BODY>
</HTML>
------_=_NextPart_001_01C32F87.70C9A720--


-------------------------------------------------------
This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
thread debugger on the planet. Designed with thread debugging features
you've never dreamed of, try TotalView 6 free at www.etnus.com.
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
