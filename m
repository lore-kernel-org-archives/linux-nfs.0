Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:32887 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932728Ab1KPAqm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Nov 2011 19:46:42 -0500
Date: Wed, 16 Nov 2011 11:46:31 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>, Josef Bacik <josef@redhat.com>,
        Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH] NFS - fix recent breakage to NFS error handling.
Message-ID: <20111116114631.3bf69abf@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/nqypx_4LzjHkD+XnnKIyI9/"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/nqypx_4LzjHkD+XnnKIyI9/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

=46rom c6d615d2b97fe305cbf123a8751ced859dca1d5e Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Nov 2011 09:39:05 +1100
Subject: [PATCH] NFS - fix recent breakage to NFS error handling.

commit 02c24a82187d5a628c68edfe71ae60dc135cd178 made a small and
presumably unintended change to write error handling in NFS.

Previously an error from filemap_write_and_wait_range would only be of
interest if nfs_file_fsync did not return an error.  After this commit,
an error from filemap_write_and_wait_range would mean that (the rest of)
nfs_file_fsync would not even be called.

This means that:
 1/ you are more likely to see EIO than e.g. EDQUOT or ENOSPC.
 2/ NFS_CONTEXT_ERROR_WRITE remains set for longer so more writes are
    synchronous.

This patch restores previous behaviour.

Cc: stable@kernel.org
Cc: Josef Bacik <josef@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/file.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 0a1f831..3099d55 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -312,13 +312,13 @@ nfs_file_fsync(struct file *file, loff_t start, loff_=
t end, int datasync)
 			datasync);
=20
 	ret =3D filemap_write_and_wait_range(inode->i_mapping, start, end);
-	if (ret)
-		return ret;
 	mutex_lock(&inode->i_mutex);
=20
 	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
 	have_error =3D test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 	status =3D nfs_commit_inode(inode, FLUSH_SYNC);
+	if (status >=3D 0 && ret < 0)
+		status =3D ret;
 	have_error |=3D test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 	if (have_error)
 		ret =3D xchg(&ctx->error, 0);
--=20
1.7.7.3


--Sig_/nqypx_4LzjHkD+XnnKIyI9/
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTsMH5znsnt1WYoG5AQK9+Q//Q8sR7u/SHDbnj6I/8z0PP4d1LB3L1rMW
rUku6Yr0ZGjkTRkuh0s8F8Se0hYqYpeKaM16Ptux87mjGKiojfA+MO+YZOORpbfh
7Qb50d+cm5V6sttcokV4sqyUi9TyoLKUGxN/EGApGqtmOi7Dx7w6yQfUNDVmsyHD
db3eWUGBLzrOZiXVY5hA5qCmIW8Nom7oE7mD8ZcvJi0BZ43hD8RIG05w8iEocWLa
34pmy1hREHOH+NpnPYiD0uzllVCUjNdy/5QjNsM2XY8yGMae6FrzIwu9/t+IeAp1
QdB6Q4jZ3p6gALiwNkZokSHeT6SclWVCo0JEV2guQOe8bGmvs/opHyQVL/Cklmk9
SWiexfhmi2IiajHtM76vLx2qb1+50/Mr7SV5+mgVb+PMQ3kz8G5vn3I7rxXvvNeZ
nyLxip/3Not+me+rvk2ol2S7SRGWL3lSZH+vyvgdwrMUFPvoZskeYlAzvkyvXEnX
6EH3B8Pt7hXmdDZMTg/DZ2ZvrYwDqX3wNwkp/CKzBnb+E3b6Ve2Oxxj9J7yTrXC3
jSj3TnoBt6Q0uz/yhvQmZdhqEPHTBFVjfC/+gMQl8nEDq2SYGAXlZDNtRdMGj/A1
0zVP3/cej33N+0bFAUsutx75Cub0cts5iQWYzt0LOrDU2nagH0QWzX5eIvXLScoS
fVZD76GXBgA=
=1NcK
-----END PGP SIGNATURE-----

--Sig_/nqypx_4LzjHkD+XnnKIyI9/--
