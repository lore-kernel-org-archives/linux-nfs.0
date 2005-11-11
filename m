From: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
Subject: Rename window
Date: Fri, 11 Nov 2005 11:42:01 -0000
Message-ID: <9E621559095AA746B22B21CD4FAF99A557356D@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5E6B4.EEBE73D1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EaXIN-0007Ad-LT
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 03:42:15 -0800
Received: from smtp.dataconnection.com ([192.91.191.4])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EaXIL-0004IG-6v
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 03:42:15 -0800
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

------_=_NextPart_001_01C5E6B4.EEBE73D1
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I have noticed a atomicity problem with the handling of rename by the
Linux NFS client, and just wanted to check if this is something that we
just have to work-around, or is there some other solution.
=20
The problem arises when two different machines issue a file rename which
is identical.
=20
E.g. rename oldname newname
=20
You would expect that one machine would be successful, and the other
would fail.    However, the NFS client seems to be issuing 3 NFS
operations to perform the rename

*	LOOKUP oldname=20
*	LOOKUP newname=20
*	RENAME oldname newname

There is a timing window where both LOOKUPs can succeed (if the other
machine does the rename at the right time).   In this case, the Linux
NFS client does not issue the final NFS RENAME operation - BUT still
returns success to the caller.
=20
Thus both machines have succeeded in renaming the file.
=20
You might argue that since they are performing the same operation that
it is OK for both to succeed, but I have an application that depends on
the atomicity of the operation, as it uses the filename to hold a
counter, and rename to assign a unique counter to a process.
=20
Any help appreciated.=20
=20
Edward.=20
=20
=20

------_=_NextPart_001_01C5E6B4.EEBE73D1
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2800.1515" name=3DGENERATOR></HEAD>
<BODY>
<DIV><FONT face=3DArial><FONT color=3D#ff00ff><FONT size=3D2><SPAN=20
class=3D271523311-11112005>I have noticed a atomicity problem with the =
handling of=20
rename by the Linux NFS client, and just wanted to check<SPAN=20
class=3D686104111-11112005>&nbsp;</SPAN></SPAN><SPAN =
class=3D271523311-11112005>if=20
this is something that we just have to work-around, or is there some =
other=20
solution.</SPAN></FONT></FONT></FONT></DIV>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial color=3D#ff00ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial color=3D#ff00ff =
size=3D2>The=20
problem arises when two different machines issue a file rename which is=20
identical.</FONT></SPAN></DIV>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial color=3D#ff00ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial color=3D#ff00ff =
size=3D2>E.g.=20
rename oldname newname</FONT></SPAN></DIV>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial color=3D#ff00ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><FONT face=3DArial><FONT color=3D#ff00ff><FONT size=3D2><SPAN=20
class=3D271523311-11112005>You would expect that one machine would be =
successful,=20
and the other would fail.<SPAN class=3D686104111-11112005>&nbsp;&nbsp;=20
&nbsp;</SPAN></SPAN><SPAN class=3D271523311-11112005>However, the NFS =
client seems=20
to be issuing 3 NFS operations to perform the=20
rename</SPAN></FONT></FONT></FONT></DIV>
<UL>
  <LI><FONT face=3DArial><FONT size=3D2><FONT color=3D#ff00ff><SPAN=20
  class=3D271523311-11112005>LOOKUP oldname</SPAN> </FONT></FONT></FONT>
  <LI><FONT face=3DArial><FONT size=3D2><FONT color=3D#ff00ff><SPAN=20
  class=3D271523311-11112005>LOOKUP newname</SPAN> </FONT></FONT></FONT>
  <LI><SPAN class=3D271523311-11112005><FONT face=3DArial =
color=3D#ff00ff=20
  size=3D2>RENAME oldname newname</FONT></SPAN></LI></UL>
<DIV><FONT face=3DArial><FONT color=3D#ff00ff><FONT size=3D2><SPAN=20
class=3D271523311-11112005>There is a timing window where both LOOKUPs =
can succeed=20
(if the other machine does the rename at the right time).<SPAN=20
class=3D686104111-11112005>&nbsp; &nbsp;</SPAN></SPAN><SPAN=20
class=3D271523311-11112005>In this case, the Linux NFS client does not =
issue the=20
final NFS RENAME operation - BUT still returns success to the=20
caller.</SPAN></FONT></FONT></FONT></DIV>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial color=3D#ff00ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial color=3D#ff00ff =
size=3D2>Thus=20
both machines have succeeded in renaming the file.</FONT></SPAN></DIV>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial color=3D#ff00ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><FONT face=3DArial><FONT color=3D#ff00ff><FONT size=3D2><SPAN=20
class=3D271523311-11112005>You might argue that since they are =
performing the same=20
operation that it is OK for both to succeed, but I have an application =
that<SPAN=20
class=3D686104111-11112005>&nbsp;</SPAN></SPAN><SPAN=20
class=3D271523311-11112005>depends on the atomicity of the operation, as =
it uses=20
the filename to hold a counter, and rename to assign a unique counter to =
a=20
process.</SPAN></FONT></FONT></FONT></DIV>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial color=3D#ff00ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial><FONT =
color=3D#ff00ff><FONT=20
size=3D2>Any help appreciated.<SPAN=20
class=3D686104111-11112005>&nbsp;</SPAN></FONT></FONT></FONT></SPAN></DIV=
>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial><FONT =
color=3D#ff00ff><FONT=20
size=3D2><SPAN=20
class=3D686104111-11112005></SPAN></FONT></FONT></FONT></SPAN>&nbsp;</DIV=
>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial><FONT =
color=3D#ff00ff><FONT=20
size=3D2><SPAN=20
class=3D686104111-11112005>Edward.&nbsp;</SPAN></FONT></FONT></FONT></SPA=
N></DIV>
<DIV><SPAN class=3D271523311-11112005><FONT face=3DArial color=3D#ff00ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><FONT face=3DArial color=3D#808000 size=3D2><SPAN=20
class=3D271523311-11112005></SPAN></FONT>&nbsp;</DIV></BODY></HTML>

------_=_NextPart_001_01C5E6B4.EEBE73D1--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
