From: "Stuckless, Colin  709 778-3815" <cstuckless@petro-canada.ca>
Subject: RE: Linux / tcp-nfs / NetApp problems (summary)
Date: Wed, 11 Jun 2003 11:44:39 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <B9F4645CD7B0D511BE8300508B68C327025EA9A8@tnscapp02.pcacorp.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C33041.21CABA8C"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pcx1.petro-canada.ca ([209.82.98.50] helo=pcaxs03.petro-canada.ca)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Q9eP-0000Y0-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Jun 2003 10:44:45 -0700
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

------_=_NextPart_001_01C33041.21CABA8C
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


> -----Original Message-----
> From: gb [mailto:bakerg3@yahoo.com]
> Sent: Wednesday, June 11, 2003 2:58 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] Linux / tcp-nfs / NetApp problems (summary)
>=20
>=20
>=20
> I'd like to thank Charles Lever and Trond for not only
> helping narrow down where the problem was occuring,
> but for providing a fix (patches) for our linux
> clients that enable them to once again play nicely
> with NetApps using tcp-nfs when under heavy network
> load. =20
<...>
> server/directory/mount options:
>=20
> vger:/vol/vol2/admin-test2 /u/admin-test2 nfs
> rw,v3,rsize=3D32768,wsize=3D32768,hard,intr,tcp,lock,addr=3Dvger
> 0 0=20
<...>
> Problem Summary:
>=20
> When the linux clients (2.4.18) begin accessing the
> same partition on the filer (reads/writes), the linux
> clients process performing the access "hangs".  Syslog
>  output contains these messages:
>=20
>  can't get request slot
>  nfs server not responding


Greg,

Can you tell us what the client performance is like with
the fix in place?

I (and many others) have experienced the same problem
with RedHat 7.3 against Solaris file servers when using
UDP as the transport. I had to cut back from a 32K w/rsize
to 8K, and even then the Linux clients were still able to
consume all the Solaris file server's resources, causing
other clients to suffer the "can not get request slot"
problem.

It sounds like the fix Trond has supplied would work for
my situation as well. At the moment I'm running kernel
2.4.18-27.7.xsmp from RedHat which has also proven to=20
provide a workaround, although I don't know if their
solution is the same as Trond's or not.

Colin Stuckless



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

------_=_NextPart_001_01C33041.21CABA8C
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
<TITLE>RE: [NFS] Linux / tcp-nfs / NetApp problems (summary)</TITLE>
</HEAD>
<BODY>
<BR>

<P><FONT SIZE=3D2>&gt; -----Original Message-----</FONT>
<BR><FONT SIZE=3D2>&gt; From: gb [<A =
HREF=3D"mailto:bakerg3@yahoo.com">mailto:bakerg3@yahoo.com</A>]</FONT>
<BR><FONT SIZE=3D2>&gt; Sent: Wednesday, June 11, 2003 2:58 PM</FONT>
<BR><FONT SIZE=3D2>&gt; To: nfs@lists.sourceforge.net</FONT>
<BR><FONT SIZE=3D2>&gt; Subject: [NFS] Linux / tcp-nfs / NetApp =
problems (summary)</FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; I'd like to thank Charles Lever and Trond for =
not only</FONT>
<BR><FONT SIZE=3D2>&gt; helping narrow down where the problem was =
occuring,</FONT>
<BR><FONT SIZE=3D2>&gt; but for providing a fix (patches) for our =
linux</FONT>
<BR><FONT SIZE=3D2>&gt; clients that enable them to once again play =
nicely</FONT>
<BR><FONT SIZE=3D2>&gt; with NetApps using tcp-nfs when under heavy =
network</FONT>
<BR><FONT SIZE=3D2>&gt; load.&nbsp; </FONT>
<BR><FONT SIZE=3D2>&lt;...&gt;</FONT>
<BR><FONT SIZE=3D2>&gt; server/directory/mount options:</FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; vger:/vol/vol2/admin-test2 /u/admin-test2 =
nfs</FONT>
<BR><FONT SIZE=3D2>&gt; =
rw,v3,rsize=3D32768,wsize=3D32768,hard,intr,tcp,lock,addr=3Dvger</FONT>
<BR><FONT SIZE=3D2>&gt; 0 0 </FONT>
<BR><FONT SIZE=3D2>&lt;...&gt;</FONT>
<BR><FONT SIZE=3D2>&gt; Problem Summary:</FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; When the linux clients (2.4.18) begin accessing =
the</FONT>
<BR><FONT SIZE=3D2>&gt; same partition on the filer (reads/writes), the =
linux</FONT>
<BR><FONT SIZE=3D2>&gt; clients process performing the access =
&quot;hangs&quot;.&nbsp; Syslog</FONT>
<BR><FONT SIZE=3D2>&gt;&nbsp; output contains these messages:</FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt;&nbsp; can't get request slot</FONT>
<BR><FONT SIZE=3D2>&gt;&nbsp; nfs server not responding</FONT>
</P>
<BR>

<P><FONT SIZE=3D2>Greg,</FONT>
</P>

<P><FONT SIZE=3D2>Can you tell us what the client performance is like =
with</FONT>
<BR><FONT SIZE=3D2>the fix in place?</FONT>
</P>

<P><FONT SIZE=3D2>I (and many others) have experienced the same =
problem</FONT>
<BR><FONT SIZE=3D2>with RedHat 7.3 against Solaris file servers when =
using</FONT>
<BR><FONT SIZE=3D2>UDP as the transport. I had to cut back from a 32K =
w/rsize</FONT>
<BR><FONT SIZE=3D2>to 8K, and even then the Linux clients were still =
able to</FONT>
<BR><FONT SIZE=3D2>consume all the Solaris file server's resources, =
causing</FONT>
<BR><FONT SIZE=3D2>other clients to suffer the &quot;can not get =
request slot&quot;</FONT>
<BR><FONT SIZE=3D2>problem.</FONT>
</P>

<P><FONT SIZE=3D2>It sounds like the fix Trond has supplied would work =
for</FONT>
<BR><FONT SIZE=3D2>my situation as well. At the moment I'm running =
kernel</FONT>
<BR><FONT SIZE=3D2>2.4.18-27.7.xsmp from RedHat which has also proven =
to </FONT>
<BR><FONT SIZE=3D2>provide a workaround, although I don't know if =
their</FONT>
<BR><FONT SIZE=3D2>solution is the same as Trond's or not.</FONT>
</P>

<P><FONT SIZE=3D2>Colin Stuckless</FONT>
</P>
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
------_=_NextPart_001_01C33041.21CABA8C--


-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
