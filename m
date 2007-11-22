From: Timo Sirainen <tss@iki.fi>
Subject: Re: [NFS] Cache flushing
Date: Thu, 22 Nov 2007 02:52:09 +0200
Message-ID: <1195692729.28091.16.camel@hurina>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina> <1195524890.6039.315.camel@hurina>
	<1195602454.7234.100.camel@heimdal.trondhjem.org>
	<1195650851.6039.425.camel@hurina>
	<1195653389.8374.4.camel@heimdal.trondhjem.org>
	<D30D2934-0124-4AD4-B184-DCC3EF62440E@iki.fi>
	<1195677569.8374.18.camel@heimdal.trondhjem.org>
	<1195678584.6039.436.camel@hurina>
	<1195679737.8374.34.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0282295923=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iv0If-0007Sz-UB
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 16:52:14 -0800
Received: from dovecot.org ([82.118.211.50])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iv0Ik-0005jP-Eb
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 16:52:20 -0800
In-Reply-To: <1195679737.8374.34.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--===============0282295923==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-hjNKUJgJcCFuVeGNJq+0"


--=-hjNKUJgJcCFuVeGNJq+0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-11-21 at 16:15 -0500, Trond Myklebust wrote:
> On Wed, 2007-11-21 at 22:56 +0200, Timo Sirainen wrote:
> > On Wed, 2007-11-21 at 15:39 -0500, Trond Myklebust wrote:
> > > I thought you said this was for flushing the attribute cache?
> >=20
> > That was it originally, but this one's more important. :) Also I
> > originally thought that directory's attribute cache flushing also
> > flushed its file handle cache. I'm not actually sure what file handle
> > cache should even really be called. It looks like Linux handles it with
> > page cache the same way as for files?
> >=20
> > So I guess I'm asking for chown(-1,-1) call to invalidate the file's
> > attribute and page cache. Although it's interesting why chown(0,-1)
> > flushes a directory's file handle cache (=3D=3Dpage cache?), but the sa=
me
> > call for a file doesn't flush its page cache. Maybe I'm still
> > misunderstanding something how all of this works.
>=20
> No. I'm not at all comfortable with the idea of overloading chown() to
> invalidate data caches.
>=20
> It is one thing to have it revalidate the attribute cache (you might be
> able to argue that this is consistent with the mission of chown(),
> although I'm not yet convinced of that) but the only effect that chown()
> has on data caching is that we force a sync to disk in order to avoid
> trouble with cached writes that are no longer accepted by the server. It
> has never forced a cache invalidation.

I finally set up my own NFS test setup and figured out how this really
works. As long as nfs_setattr() has something to do, it calls
nfs_end_data_update() at the end, which in turn unconditionally sets
"nfsi->cache_change_attribute =3D jiffies", which causes the file handle
cache to be flushed on next access.

So the only special case here is if nfs_setattr() has nothing to do.
Just moving that check a bit later would be enough:

--- inode.c.old	2007-11-16 22:18:46.000000000 +0200
+++ inode.c	2007-11-22 02:50:04.000000000 +0200
@@ -323,7 +323,7 @@
 {
 	struct inode *inode =3D dentry->d_inode;
 	struct nfs_fattr fattr;
-	int error;
+	int error =3D 0;
=20
 	nfs_inc_stats(inode, NFSIOS_VFSSETATTR);
=20
@@ -332,11 +332,6 @@
 			attr->ia_valid &=3D ~ATTR_SIZE;
 	}
=20
-	/* Optimization: if the end result is no change, don't RPC */
-	attr->ia_valid &=3D NFS_VALID_ATTRS;
-	if (attr->ia_valid =3D=3D 0)
-		return 0;
-
 	lock_kernel();
 	nfs_begin_data_update(inode);
 	/* Write all dirty data */
@@ -349,9 +344,14 @@
 	 */
 	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) !=3D 0)
 		nfs_inode_return_delegation(inode);
-	error =3D NFS_PROTO(inode)->setattr(dentry, &fattr, attr);
-	if (error =3D=3D 0)
-		nfs_refresh_inode(inode, &fattr);
+
+	/* Optimization: if the end result is no change, don't RPC */
+	attr->ia_valid &=3D NFS_VALID_ATTRS;
+	if (attr->ia_valid !=3D 0) {
+		error =3D NFS_PROTO(inode)->setattr(dentry, &fattr, attr);
+		if (error =3D=3D 0)
+			nfs_refresh_inode(inode, &fattr);
+	}
 	nfs_end_data_update(inode);
 	unlock_kernel();
 	return error;


> IMO, the right interface for manipulating the page cache is rather
> posix_fadvise(). I can certainly see an argument for adding a
> "POSIX_FADV_UNCACHE" option in order to force a cache invalidation for
> those applications that need stronger cache consistency.

Yes, that would be nice. Perhaps I'll try to implement it some day.

> Note, however, that even if such a thing is accepted into the mainstream
> kernel, you still have to convince all the distros to backport this
> interface to their older kernels. If not, you will still have a problem
> with legacy clients...

I don't mind as long as I can say a newer kernel will solve the problem.
It's still a lot easier to upgrade the kernel than requiring to change
the whole NFS server/filesystem.

--=-hjNKUJgJcCFuVeGNJq+0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHRNK5yUhSUUBViskRAjM9AJ4sJmelXNNWSxGK0tNo6gW10fhNIACcCfm8
LofyVHyxe2h0rzYwqJVs96U=
=+5Zh
-----END PGP SIGNATURE-----

--=-hjNKUJgJcCFuVeGNJq+0--



--===============0282295923==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============0282295923==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============0282295923==--



