From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS client write performance issue ... thoughts?
Date: Tue, 6 Jan 2004 08:17:28 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020AC990@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Adtti-0004xR-39
	for nfs@lists.sourceforge.net; Tue, 06 Jan 2004 08:17:38 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Adtth-00048j-9f
	for nfs@lists.sourceforge.net; Tue, 06 Jan 2004 08:17:37 -0800
To: "Paul Smith" <pausmith@nortelnetworks.com>, <nfs@lists.sourceforge.net>
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

paul-

large commercial databases write whole pages, and never
parts of pages, at once, to their data files.  and they
write log files by extending them in a single write
request.

thus the single-write-request per-page limit is not a
problem for them.

> -----Original Message-----
> From: Paul Smith [mailto:pausmith@nortelnetworks.com]=20
> Sent: Monday, January 05, 2004 5:11 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] NFS client write performance issue ... thoughts?
>=20
>=20
> Hi all; we've been doing some examination of NFS client=20
> performance, and
> have seen this apparently sub-optimal behavior: anyone here have any
> comments on this observation or thoughts about it?
>=20
> Thanks!
>=20
> > I was looking at the code (which doesn't appear to be fixed in 2.6),
> > and here's what I think it's doing.
> >=20
> > The Linux NFS client code is capable of only remembering a=20
> write to a
> > single contiguous chunk in each 4KB page of a file.  If a second
> > non-contiguous write occurs to the page, the first write has to be
> > flushed to the server.  So if the view server is seeking around in a
> > file writing a few bytes here and a few there, whenever it does a
> > write to a page that has already been written, the first=20
> write has to
> > be flushed to the server.  The code that does most of this is in
> > fs/nfs/write.c, function nfs_update_request().  That's the routine
> > that, given a new write request, searches for an existing=20
> one that is
> > contiguous with the new one.  If it finds a contiguous request, the
> > new one is coalesced with it and no NFS activitity is required.  If
> > instead it finds a pending write to the same page, it=20
> returns EBUSY to
> > its caller, which tells the caller (nfs_updatepage()) to=20
> synchronously
> > write the existing request to the server.
> >=20
> > The Solaris NFS client (and probably most other NFS client
> > implementations) doesn't work this way.  Whenever a small write is
> > made to a block of a file, the block is read from the=20
> server, and then
> > the write is applied to the cached block.  If the block is=20
> already in
> > cache, the write is applied to block without any NFS transactions
> > being required.  When the file is closed or fsync()ed, the entire
> > block is written to the server.  So the client code doesn't need to
> > record each individual small write to a block, it just modifies the
> > cached block as necessary.
> >=20
> > I don't know why the Linux NFS client doesn't work this way, but I
> > think it wouldn't be difficult to make it work that way.  In some
> > scenarios, this might be a performance hit (because an=20
> entire block of
> > the file has to be read from the server just to write a few bytes to
> > it), but I think that in most cases, doing it the Solaris=20
> way would be
> > a performance win.  I'd guess that if any sort of database,=20
> such as a
> > GDBM database, is accessed over NFS, the Linux method would=20
> result in
> > much poorer performance than the Solaris method.
>=20
>=20
> --=20
> --------------------------------------------------------------
> -----------------
>  Paul D. Smith <psmith@nortelnetworks.com>   HASMAT: HA=20
> Software Mthds & Tools
>  "Please remain calm...I may be mad, but I am a=20
> professional." --Mad Scientist
> --------------------------------------------------------------
> -----------------
>    These are my opinions---Nortel Networks takes no=20
> responsibility for them.
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by: IBM Linux Tutorials.
> Become an expert in LINUX or just sharpen your skills.  Sign=20
> up for IBM's
> Free Linux Tutorials.  Learn everything from the bash shell=20
> to sys admin.
> Click now! =
http://ads.osdn.com/?ad_id=3D1278&alloc_id=3D3371&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
