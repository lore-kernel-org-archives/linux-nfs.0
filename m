From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Disabling the client cache - O_DIRECT?
Date: Mon, 23 May 2005 13:47:13 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539B84@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C55FD8.98DAA116"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DaJpc-0006es-13
	for nfs@lists.sourceforge.net; Mon, 23 May 2005 13:47:24 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DaJpb-0003in-AS
	for nfs@lists.sourceforge.net; Mon, 23 May 2005 13:47:23 -0700
To: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
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

------_=_NextPart_001_01C55FD8.98DAA116
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

the alignment issues are different depending on which kernel you use.
=20
in 2.6 there should be no alignment issues, you can do O_DIRECT I/O on
NFS files at any offset and alignment.
=20
in 2.4, O_DIRECT is supported on NFS files after 2.4.22 ish.  buffer and
offset alignment is restricted.  at some point we may have changed the
behavior, but i'm not remembering when and which kernels, because we
backported some of the 2.6 behavior into the Red Hat kernels.  i believe
it depends on what your server returns as its on-disk block size (NFSv3
PATHCONF).
=20

	-----Original Message-----
	From: Edward Hibbert [mailto:Edward.Hibbert@dataconnection.com]=20
	Sent: Monday, May 23, 2005 4:13 PM
	To: nfs@lists.sourceforge.net
	Subject: RE: [NFS] Disabling the client cache - O_DIRECT?
=09
=09
	And then there's O_DIRECT, which might do just what I want.  Is
that working over NFS now? =20
	=20
	I'm trying to use it but getting EINVAL back - can someone
explain whether O_DIRECT over NFS has the alignment restrictions that
O_DIRECT does in general?
	=20

		-----Original Message-----
		From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net]On Behalf Of Edward Hibbert
		Sent: 23 May 2005 15:43
		To: nfs@lists.sourceforge.net
		Subject: [NFS] Disabling the client cache using file
locks
	=09
	=09

		The NFS FAQ says:=20

		For greater consistency among clients, applications can
use file locking, where a client purges file data when a file is locked,
and flushes changes back to the server before unlocking a file.

		My experience with this is that to force a read to go to
the NFS server, I:=20
		- lock an area in the file (I think any area works, it
doesn't need to overlap with what you want to read)=20
		- read the data=20
		- unlock it=20

		When I want a write to go to the NFS server, I do the
same.  Obviously if I'm reading and writing the same area, I can save on
the locks.

		This produces a lot of lock and unlock operations, and I
find that:=20
		- NFS servers aren't as good at handling a high volume
of these as they are at reads and writes. =20
		- lockd/statd on the client may also be a serialisation
point (I have suggestive but not conclusive evidence).=20

		So I'm looking for ways of reducing the number of locks.
Possibilities:=20
		- Make a patch to the kernel (or NFS utils?) to
_entirely_ disable client-side caching of file contents over NFS.  I
have dedicated boxes which have no requirement to do client-side caching
at all so this is a serious option.  Any code pointers?

		- Use nolock to prevent the locks hitting the NFS server
- but I think that would still hit lockd/statd on the client?=20
		- Not to bother with the locks round the writes, but use
fsync instead.  Do folk think that would work?=20

		Any comments or other ideas?=20

		Edward.=20




------_=_NextPart_001_01C55FD8.98DAA116
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><TITLE>Message</TITLE>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2800.1498" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D823254320-23052005><FONT face=3DArial color=3D#0000ff =
size=3D2>the=20
alignment issues are different depending on which kernel you=20
use.</FONT></SPAN></DIV>
<DIV><SPAN class=3D823254320-23052005><FONT face=3DArial color=3D#0000ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D823254320-23052005><FONT face=3DArial color=3D#0000ff =
size=3D2>in 2.6=20
there should be no alignment issues, you can do O_DIRECT I/O on NFS =
files at any=20
offset and alignment.</FONT></SPAN></DIV>
<DIV><SPAN class=3D823254320-23052005><FONT face=3DArial color=3D#0000ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D823254320-23052005><FONT face=3DArial color=3D#0000ff =
size=3D2>in=20
2.4, O_DIRECT is supported on NFS files after 2.4.22 ish.&nbsp; buffer =
and=20
offset alignment is restricted.&nbsp; at some point we may have changed =
the=20
behavior, but i'm not remembering when and which kernels, because we =
backported=20
some of the 2.6 behavior into the Red Hat kernels.&nbsp; i believe it =
depends on=20
what your server returns as its on-disk block size (NFSv3=20
PATHCONF).</FONT></SPAN></DIV>
<DIV><SPAN class=3D823254320-23052005><FONT face=3DArial color=3D#0000ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<BLOCKQUOTE dir=3Dltr=20
style=3D"PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px =
solid; MARGIN-RIGHT: 0px">
  <DIV></DIV>
  <DIV class=3DOutlookMessageHeader lang=3Den-us dir=3Dltr =
align=3Dleft><FONT=20
  face=3DTahoma size=3D2>-----Original Message-----<BR><B>From:</B> =
Edward Hibbert=20
  [mailto:Edward.Hibbert@dataconnection.com] <BR><B>Sent:</B> Monday, =
May 23,=20
  2005 4:13 PM<BR><B>To:</B> =
nfs@lists.sourceforge.net<BR><B>Subject:</B> RE:=20
  [NFS] Disabling the client cache - O_DIRECT?<BR><BR></FONT></DIV>
  <DIV><SPAN class=3D838394019-23052005><FONT face=3DArial =
color=3D#ff00ff size=3D2>And=20
  then there's O_DIRECT, which might do just what I want.&nbsp; Is that =
working=20
  over NFS now?&nbsp; </FONT></SPAN></DIV>
  <DIV><SPAN class=3D838394019-23052005><FONT face=3DArial =
color=3D#ff00ff=20
  size=3D2></FONT></SPAN>&nbsp;</DIV>
  <DIV><SPAN class=3D838394019-23052005><FONT face=3DArial =
color=3D#ff00ff size=3D2>I'm=20
  trying to use it but getting EINVAL back - can someone explain whether =

  O_DIRECT over NFS has the alignment restrictions that O_DIRECT does in =

  general?</FONT></SPAN></DIV>
  <DIV><SPAN class=3D838394019-23052005><FONT face=3DArial =
color=3D#ff00ff=20
  size=3D2></FONT></SPAN>&nbsp;</DIV>
  <BLOCKQUOTE>
    <DIV class=3DOutlookMessageHeader dir=3Dltr align=3Dleft><FONT =
face=3DTahoma=20
    size=3D2>-----Original Message-----<BR><B>From:</B>=20
    nfs-admin@lists.sourceforge.net=20
    [mailto:nfs-admin@lists.sourceforge.net]<B>On Behalf Of </B>Edward=20
    Hibbert<BR><B>Sent:</B> 23 May 2005 15:43<BR><B>To:</B>=20
    nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] Disabling the =
client=20
    cache using file locks<BR><BR></FONT></DIV><!-- Converted from =
text/rtf format -->
    <P><FONT face=3D"Courier New" size=3D2>The NFS FAQ says:</FONT> </P>
    <P><FONT face=3D"Courier New" size=3D2>For greater consistency among =
clients,=20
    applications can use file locking, where a client purges file data =
when a=20
    file is locked, and flushes changes back to the server before =
unlocking a=20
    file.</FONT></P>
    <P><FONT face=3D"Courier New" size=3D2>My experience with this is =
that to force=20
    a read to go to the NFS server, I:</FONT> <BR><FONT face=3D"Courier =
New"=20
    size=3D2>- lock an area in the file (I think any area works, it =
doesn't need=20
    to overlap with what you want to read)</FONT> <BR><FONT =
face=3D"Courier New"=20
    size=3D2>- read the data</FONT> <BR><FONT face=3D"Courier New" =
size=3D2>- unlock=20
    it </FONT></P>
    <P><FONT face=3D"Courier New" size=3D2>When I want a write to go to =
the NFS=20
    server, I do the same.&nbsp; Obviously if I'm reading and writing =
the same=20
    area, I can save on the locks.</FONT></P>
    <P><FONT face=3D"Courier New" size=3D2>This produces a lot of lock =
and unlock=20
    operations, and I find that:</FONT> <BR><FONT face=3D"Courier New" =
size=3D2>-=20
    NFS servers aren't as good at handling a high volume of these as =
they are at=20
    reads and writes.&nbsp; </FONT><BR><FONT face=3D"Courier New" =
size=3D2>-=20
    lockd/statd on the client may also be a serialisation point (I have=20
    suggestive but not conclusive evidence).</FONT> </P>
    <P><FONT face=3D"Courier New" size=3D2>So I'm looking for ways of =
reducing the=20
    number of locks.&nbsp; Possibilities:</FONT> <BR><FONT =
face=3D"Courier New"=20
    size=3D2>- Make a patch to the kernel (or NFS utils?) to _entirely_ =
disable=20
    client-side caching of file contents over NFS.&nbsp; I have =
dedicated boxes=20
    which have no requirement to do client-side caching at all so this =
is a=20
    serious option.&nbsp; Any code pointers?</FONT></P>
    <P><FONT face=3D"Courier New" size=3D2>- Use nolock to prevent the =
locks hitting=20
    the NFS server - but I think that would still hit lockd/statd on the =

    client?</FONT> <BR><FONT face=3D"Courier New" size=3D2>- Not to =
bother with the=20
    locks round the writes, but use fsync instead.&nbsp; Do folk think =
that=20
    would work?</FONT> </P>
    <P><FONT face=3D"Courier New" size=3D2>Any comments or other =
ideas?</FONT> </P>
    <P><FONT face=3D"Courier New" size=3D2>Edward.</FONT>=20
</P><BR><BR></BLOCKQUOTE></BLOCKQUOTE></BODY></HTML>
=00
------_=_NextPart_001_01C55FD8.98DAA116--


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
