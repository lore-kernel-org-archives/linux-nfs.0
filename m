From: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
Subject: Disabling the client cache using file locks
Date: Mon, 23 May 2005 15:43:20 +0100
Message-ID: <9E621559095AA746B22B21CD4FAF99A50FA5C8@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C55FA5.C3BC099C"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DaE9P-0004Nc-TI
	for nfs@lists.sourceforge.net; Mon, 23 May 2005 07:43:27 -0700
Received: from smtp2.dataconnection.com ([192.91.191.8])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DaE9O-0002rI-92
	for nfs@lists.sourceforge.net; Mon, 23 May 2005 07:43:27 -0700
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

------_=_NextPart_001_01C55FA5.C3BC099C
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> The NFS FAQ says:
>=20
> For greater consistency among clients, applications can use file =
locking, where a client purges file data when a file is locked, and =
flushes changes back to the server before unlocking a file.
>=20
> My experience with this is that to force a read to go to the NFS =
server, I:
> - lock an area in the file (I think any area works, it doesn't need to =
overlap with what you want to read)
> - read the data
> - unlock it=20
>=20
> When I want a write to go to the NFS server, I do the same.  Obviously =
if I'm reading and writing the same area, I can save on the locks.
>=20
> This produces a lot of lock and unlock operations, and I find that:
> - NFS servers aren't as good at handling a high volume of these as =
they are at reads and writes. =20
> - lockd/statd on the client may also be a serialisation point (I have =
suggestive but not conclusive evidence).
>=20
> So I'm looking for ways of reducing the number of locks.  =
Possibilities:
> - Make a patch to the kernel (or NFS utils?) to _entirely_ disable =
client-side caching of file contents over NFS.  I have dedicated boxes =
which have no requirement to do client-side caching at all so this is a =
serious option.  Any code pointers?
> - Use nolock to prevent the locks hitting the NFS server - but I think =
that would still hit lockd/statd on the client?
> - Not to bother with the locks round the writes, but use fsync =
instead.  Do folk think that would work?
>=20
> Any comments or other ideas?
>=20
> Edward.
>=20
>=20
>=20

------_=_NextPart_001_01C55FA5.C3BC099C
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7232.25">
<TITLE>Disabling the client cache using file locks</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT SIZE=3D2 FACE=3D"Courier New">The NFS FAQ says:</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Courier New">For greater consistency among =
clients, applications can use file locking, where a client purges file =
data when a file is locked, and flushes changes back to the server =
before unlocking a file.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Courier New">My experience with this is that =
to force a read to go to the NFS server, I:</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Courier New">- lock an area in the file (I =
think any area works, it doesn't need to overlap with what you want to =
read)</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Courier New">- read the data</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Courier New">- unlock it </FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Courier New">When I want a write to go to the =
NFS server, I do the same.&nbsp; Obviously if I'm reading and writing =
the same area, I can save on the locks.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Courier New">This produces a lot of lock and =
unlock operations, and I find that:</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Courier New">- NFS servers aren't as good at =
handling a high volume of these as they are at reads and writes.&nbsp; =
</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Courier New">- lockd/statd on the client may =
also be a serialisation point (I have suggestive but not conclusive =
evidence).</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Courier New">So I'm looking for ways of =
reducing the number of locks.&nbsp; Possibilities:</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Courier New">- Make a patch to the kernel (or =
NFS utils?) to _entirely_ disable client-side caching of file contents =
over NFS.&nbsp; I have dedicated boxes which have no requirement to do =
client-side caching at all so this is a serious option.&nbsp; Any code =
pointers?</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Courier New">- Use nolock to prevent the locks =
hitting the NFS server - but I think that would still hit lockd/statd on =
the client?</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Courier New">- Not to bother with the locks =
round the writes, but use fsync instead.&nbsp; Do folk think that would =
work?</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Courier New">Any comments or other =
ideas?</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Courier New">Edward.</FONT>
</P>
<BR>
<BR>

</BODY>
</HTML>
------_=_NextPart_001_01C55FA5.C3BC099C--


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
