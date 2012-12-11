Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37641 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754115Ab2LKW21 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2012 17:28:27 -0500
Date: Wed, 12 Dec 2012 09:28:13 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: NFS regression - EIO is returned instead of ENOSPC
Message-ID: <20121212092813.23afbc5f@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/.jI5rOcUhwaiUEawiFwst6X"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/.jI5rOcUhwaiUEawiFwst6X
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi Trond et al,
 we seem to have a regression introduced by=20

commit 7b281ee026552f10862b617a2a51acf49c829554
    NFS: fsync() must exit with an error if page writeback failed

which has found it's way (in different form into -stable releases).

The problem is that an NFSERR_NOSPC comes through as EIO.

e.g. if /mnt2/ if an nfs mounted filesystem that has no space then

strace dd if=3D/dev/zero conv=3Dfsync >> /mnt2/afile count=3D1

reported Input/output error and the relevant parts of the strace output are:

write(1, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"=
..., 512) =3D 512
fsync(1)                                =3D -1 EIO (Input/output error)
close(1)                                =3D -1 ENOSPC (No space left on dev=
ice)

i.e. we get an EIO from fsync, then the ENOSPC comes with the close.

If don't do the fsync, then:

strace dd if=3D/dev/zero >> /mnt2/afile count=3D1


write(1, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"=
..., 512) =3D 512
close(1)                                =3D -1 EIO (Input/output error)


we don't see the ENOSPC at all.

The problem is that filemap_fdatawait_range, when it sees a page with
PageError set, will return -EIO unless AS_ENOSPC is set.  NFS never sets
AS_ENOSPC so we get -EIO.

Then nfs_file_fsync() will return as soon as it sees an error from
filemap_write_and_wait_range(), which will be that EIO.

nfs_file_fsync_commit knows to prefer the error from ctx->error over any
other error, but nfs_file_fsync() doesn't.

I see two ways to "fix" this.

We could get nfs{,4}_file_fsync() to always call nfs_file_fsync_commit() and
use the error from the later in preference to the error from
filemap_write_and_wait_range().

That results in this, more correct, behaviour:

write(1, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"=
..., 512) =3D 512
fsync(1)                                =3D -1 ENOSPC (No space left on dev=
ice)
close(1)                                =3D 0

Or we could get nfs_context_set_write_error() to call mapping_set_error(),
which would result in AS_ENOSPC being set and so
filemap_write_and_wait_range() will return the "correct" error.
This results in this behaviour:

write(1, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"=
..., 512) =3D 512
fsync(1)                                =3D -1 ENOSPC (No space left on dev=
ice)
close(1)                                =3D -1 ENOSPC (No space left on dev=
ice)

which is a bit odd.  The first ENOSPC is from AS_ENOSPC.  The second is from
ctx->error.

I feel that calling mapping_set_error() is the "right" thing to do, but it
would need a bit more work to avoid the double errors.

What approach would you prefer?

The two patches I used are:

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 582bb88..19c06b9 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -295,12 +295,12 @@ nfs_file_fsync(struct file *file, loff_t start, loff_=
t end, int datasync)
 	struct inode *inode =3D file->f_path.dentry->d_inode;
=20
 	do {
-		ret =3D filemap_write_and_wait_range(inode->i_mapping, start, end);
-		if (ret !=3D 0)
-			break;
+		int ret1 =3D filemap_write_and_wait_range(inode->i_mapping, start, end);
 		mutex_lock(&inode->i_mutex);
 		ret =3D nfs_file_fsync_commit(file, start, end, datasync);
 		mutex_unlock(&inode->i_mutex);
+		if (ret =3D=3D 0)
+			ret =3D ret1;
 		/*
 		 * If nfs_file_fsync_commit detected a server reboot, then
 		 * resend all dirty pages that might have been covered by
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index afddd66..f0d9a88 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -96,15 +96,15 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t=
 end, int datasync)
 	struct inode *inode =3D file->f_path.dentry->d_inode;
=20
 	do {
-		ret =3D filemap_write_and_wait_range(inode->i_mapping, start, end);
-		if (ret !=3D 0)
-			break;
+		int ret1 =3D filemap_write_and_wait_range(inode->i_mapping, start, end);
 		mutex_lock(&inode->i_mutex);
 		ret =3D nfs_file_fsync_commit(file, start, end, datasync);
 		if (!ret && !datasync)
 			/* application has asked for meta-data sync */
 			ret =3D pnfs_layoutcommit_inode(inode, true);
 		mutex_unlock(&inode->i_mutex);
+		if (ret =3D=3D 0)
+			ret =3D ret1;
 		/*
 		 * If nfs_file_fsync_commit detected a server reboot, then
 		 * resend all dirty pages that might have been covered by


and=20



diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9347ab7..b0f5bb7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -140,6 +140,7 @@ static void nfs_context_set_write_error(struct nfs_open=
_context *ctx, int error)
 	ctx->error =3D error;
 	smp_wmb();
 	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
+	mapping_set_error(ctx->dentry->d_inode->i_mapping, error);
 }
=20
 static struct nfs_page *



Thanks,
NeilBrown

--Sig_/.jI5rOcUhwaiUEawiFwst6X
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUMezfjnsnt1WYoG5AQIWiBAAiZyKlf1Qu7Ar59AVfD1g4TVJ2+Pi8Jai
rAOJRL7/s23M8Z/VtTonMVNk0yHokQ1AllL6dXmYe+oohu8yahGq+TqAxHfhqndz
OGVTPlbIgWz+JKvP0MnmhVbgaimnpGc+U3zEaNXOFwYhvHQ/DCljTtgvZRFM6HsM
s51gsM9HlR9CyY1TnPbWPbsOT0EBoojcJh5MFE8jKLKmNVzrE5s8uel1p9Ait1a7
zl7K3zisINBNNPNZsLkBqFruVyrd8/WfbSEogbDoByZbFzD5OKFF//xiOg97nvnZ
VffVuzQlqqj96nymMKtN1fOz9H3tgTdw1WIcK9D43zqJSYaeG3LudVmYsNYFczon
YfD/GRhLR0rYPMw8rXJDfbwJd+tA0rxuQungFuI+4duHsOHhIvNkUgejm20XNp9O
vuqimjXD0ueJ6AvdcmdlfJzCj4LSYbmRWYUEOkioMxyFKJJjOBeh8c4i11jDhexI
i53tskJ18B5tapHEsZ2y17xkSoji95dBuJE7dnbjO1lzBT0H8QJkkHf0UdMAgsSt
dRuK70Z/tBiqoN6COwSjVOS/OJFzyCiTymP9toPlmLAVsUluYdonRfG/j9DvAeCt
7vCr/IcW3bAGiZRlbVkmGawjd0BqRGtfoivk8XfZsI1uEpW3oWv7DgCezs5p3KI3
XCGMN3IBgEs=
=52g4
-----END PGP SIGNATURE-----

--Sig_/.jI5rOcUhwaiUEawiFwst6X--
