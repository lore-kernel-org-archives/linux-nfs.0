From: "Victor Zamora" <victor77422@yahoo.com.ar>
Subject: NFS Problem
Date: Tue, 15 Oct 2002 12:34:01 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001701c27460$4d7cc460$41af0dd1@default>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0014_01C27447.23E4EA60"
Return-path: <nfs-admin@lists.sourceforge.net>
To: <NFS@lists.sourceforge.net>
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

------=_NextPart_000_0014_01C27447.23E4EA60
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable



Hi,

   I have configured a NFS server and a client in a network (two =
separate machines). This runs over a linux 2.4.18 kernell (mini =
slackware version).=20
    On the server side I've exported a path to the oder specific machine =
(with its IP), and I've executed portmap, nfsd, and mountd daemons. I've =
also executed exportfs -ra so to make sure that the kernell knows about =
the nfs export I want to do.
    On the client side I've run portmap daemon, but when I run the mount =
it appears a message from the server saying "Permison denied".

    I've tryied changing the way I exported the filepath and how I =
mounted the NFS from the client, but I couldn't make it.

   If anyone has any idea of what is causing this permison denial, =
please don't doubt about geting me know it.=20
  I'll be very gratefull to any suggestion.

                                                             Thanks for =
your time,
                                                                         =
               Victor.-
  =20

------=_NextPart_000_0014_01C27447.23E4EA60
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META content=3D"text/html; charset=3Diso-8859-1" =
http-equiv=3DContent-Type>
<META content=3D"MSHTML 5.00.2919.6307" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#b8b8b8>
<DIV>
<DIV><BR></DIV>
<DIV><FONT face=3DArial size=3D2>Hi,</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp; I have&nbsp;configured a =
NFS server=20
and a client in a network (two separate machines). This runs over a =
linux 2.4.18=20
kernell (mini slackware version). </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; On the server side =
I've exported=20
a path to the oder specific machine (with its IP), and I've executed =
portmap,=20
nfsd, and mountd daemons. I've also&nbsp;executed exportfs -ra so to =
make sure=20
that the kernell knows about the nfs export I want to do.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; On the client side =
I've run=20
portmap daemon, but when I&nbsp;run the mount it appears a message from =
the=20
server saying "Permison denied".</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; I've tryied changing =
the way I=20
exported the filepath and how I mounted the NFS from the client, but I =
couldn't=20
make it.</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp; If anyone has any idea of =
what is=20
causing this permison denial, please don't doubt about geting me know =
it.=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp; I'll be very gratefull to any=20
suggestion.</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial=20
size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;=20
Thanks for your time,</FONT></DIV>
<DIV><FONT face=3DArial =
size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;=20
Victor.-</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp; =
</FONT></DIV></DIV></BODY></HTML>

------=_NextPart_000_0014_01C27447.23E4EA60--

Ahora podés usar Yahoo! Messenger desde tu celular. Aprendé cómo hacerlo en Yahoo! Móvil: http://ar.mobile.yahoo.com/sms.html


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
