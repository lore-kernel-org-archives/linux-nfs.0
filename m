From: Garrick Staples <garrick@usc.edu>
Subject: Re: mountd segfault on itanium2
Date: Mon, 3 May 2004 11:18:05 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040503181805.GO23287@polop.usc.edu>
References: <20040430212414.GF22498@polop.usc.edu> <20040430234327.GM22498@polop.usc.edu> <20040501030730.GE23287@polop.usc.edu> <20040503133546.GA25469@rx8.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="f9b3biUB1f7FHqGn"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKi4U-0005sw-6X
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 11:21:42 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BKi4T-0004rX-SZ
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 11:21:41 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i43II5lv012842
	for <nfs@lists.sourceforge.net>; Mon, 3 May 2004 11:18:05 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i43II5BQ012840
	for nfs@lists.sourceforge.net; Mon, 3 May 2004 11:18:05 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040503133546.GA25469@rx8.ibm.com>
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


--f9b3biUB1f7FHqGn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 03, 2004 at 08:35:46AM -0500, Jose R. Santos alleged:
> On 04/30/04 22:07:30, Garrick Staples wrote:
> > I have an ugly work-around that seems to be working.  It seems that 2.6=
 has a
> > new nfs interface for userspace.  By forcing mountd to use the older 2.4
> > interface, it doesn't segfault anymore.  So something in the new code p=
aths is
> > broken.
> >=20
> > In support/nfs/cachio.c:
> > int
> > check_new_cache(void)
> > {
> >         struct stat stb;
> >=20
> >         return 0;  /* DISABLE NEW 2.6 INTERFACE */
> >=20
> >         return  (stat("/proc/fs/nfs/filehandle", &stb) =3D=3D 0) ||
> >                 (stat("/proc/fs/nfsd/filehandle", &stb) =3D=3D 0);
> > }
>=20
> If you want to use the old syscall interface, all you need to do is make=
=20
> sure nfsd is not mounted in /proc/fs/nfsd.

Thank you.  That's much easier.

=20
> > Am I losing any functionality by doing this?  I can't actually find any
> > problems.
>=20
> I think there are no functionality losses but I have seen issues with usi=
ng
> the syscall interface on large memory systems.  The syscall mount and=20
> unmount the nfsdfs for every syscall.  This will cause the inode and dent=
ry
> for this filesystem to be flush, but in order to do that it needs to walk=
=20
> through all inode and dentry caches under lock.  If you have a system with
> 16GB of ram, mounting and unmounting can take a really long time.
>=20
> -JRS

Both machines have 8GB.  I definitly see the slower mounting, but it's not
prohibitive.  And slow mounting is better than a segfault.


--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--f9b3biUB1f7FHqGn
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAlozd0SBUxJbm9HMRAp8iAJ9gnn1JLcf2ExbeVYg0+ncP2FfSQQCggdWY
hDedSU0s7JT1XzRJBbpFtRo=
=JWzJ
-----END PGP SIGNATURE-----

--f9b3biUB1f7FHqGn--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
