From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Stale NFS file handle
Date: Wed, 23 Mar 2005 06:42:41 -0800
Message-ID: <482A3FA0050D21419C269D13989C6113085398EB@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DE74N-00005P-1r
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 06:42:51 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DE74J-0001wo-Gq
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 06:42:50 -0800
To: "Filipe Brandenburger" <branden@terra.com.br>
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

i saw trond's post.  he is correct, your use case is broken.  the
patches will fix ESTALE for open(2), but not for read(2).  i don't know
of any NFS implementation that will recover from an ESTALE on a read
operation.

you need to understand that NFS is not a cluster file system.  it does
not provide single-system semantics.  for a better understanding of the
limitations of NFS's caching model, take a look at Callaghan's "NFS
Illustrated."

> -----Original Message-----
> From: Filipe Brandenburger [mailto:branden@terra.com.br]=20
> Sent: Wednesday, March 23, 2005 9:35 AM
> To: Lever, Charles
> Subject: Re: [NFS] Stale NFS file handle
>=20
>=20
> Hi, there.
>=20
> Thanks for your answer. Do you know of such a patch that=20
> would solve this issue at the Linux Kernel level? I'm using=20
> kernel 2.4, do you know if 2.6 is any better on that? Do you=20
> know if other client implementations actually recover from=20
> these errors? I googled around and found out that this may be=20
> an issue on Solaris as well...
>=20
> Thanks,
> Filipe
>=20
>=20
>=20
> * Wed, 23 Mar 2005 05:53:39 -0800, "Lever, Charles"=20
> <Charles.Lever@netapp.com>:
> > when you replaced the file, client 2 still had the old file handle=20
> > cached.  when it used that old file handle again, the=20
> server reported=20
> > the file no longer existed with an ESTALE error.
> >=20
> > the problem is that Linux NFS clients don't recover from=20
> ESTALE errors.
> > it's a deficiency in the client implementation that, at=20
> this point, is=20
> > fixed only by patches.  at some point soon the patches will be=20
> > integrated into the mainline and distributions.
>=20
>=20


-------------------------------------------------------
This SF.net email is sponsored by: 2005 Windows Mobile Application Contest
Submit applications for Windows Mobile(tm)-based Pocket PCs or Smartphones
for the chance to win $25,000 and application distribution. Enter today at
http://ads.osdn.com/?ad_id=6882&alloc_id=15148&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
