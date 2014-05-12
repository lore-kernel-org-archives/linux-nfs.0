Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48674 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751393AbaELDu2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 23:50:28 -0400
Date: Mon, 12 May 2014 13:50:19 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: revalidate on open if dcache is negative.
Message-ID: <20140512135019.56e5c465@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/6N0KNe6p7/2Jbm6QyQjKcUI"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/6N0KNe6p7/2Jbm6QyQjKcUI
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



NFS CTO semantics require that (absent a delegation) the server
must be contacted at each open.

nfs_lookup_verify_inode() implements this when the dcache contains
a positive cached entry.  However it is not called when the dcache
contains a negative cached entry.  That path uses nfs_neg_need_reval()
which doesn't impose CTO semantics.

So a sequence like:

   rm -f testfile
   ls -l testfile
   ssh $server touch testfile
   cat testfile

will fail:

  cat: testfile: No such file or directory

an 'strace' will confirm that this resulted from an 'open' system
call.

So add code to nfs_neg_need_reval implement CTO semantics much like
that in nfs_lookup_verify_inode().

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index d9f3d067cd15..f8022da72460 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1062,6 +1062,8 @@ int nfs_neg_need_reval(struct inode *dir, struct dent=
ry *dentry,
 	/* Don't revalidate a negative dentry if we're creating a new file */
 	if (flags & LOOKUP_CREATE)
 		return 0;
+	if ((flags & LOOKUP_OPEN) && !(NFS_SERVER(dir)->flags & NFS_MOUNT_NOCTO))
+		return 1;
 	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG)
 		return 1;
 	return !nfs_check_verifier(dir, dentry);

--Sig_/6N0KNe6p7/2Jbm6QyQjKcUI
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU3BE+znsnt1WYoG5AQJayg/6A8DYCG3h2eMfSeBP48PqhfvO+Yftpu6m
mPkpDZdau0pFojL+56i3V9mnSVtPgugvzSDNR015J0CiqlZs4yq+72MMaPysXnki
rx7BoPfbgv5ZpcLzQBEfBCVsB7QLyrGwCCHR4c7MNstMy+NEkDZdDIACZKTE/xo8
hc5qwpKROKXM77qBSZBofJifOw8oqTVRtzBKqrfYudb/UjZptugWmAomnn1JB0XA
c+o7gXzlvoyD/TGidw1E3vfyAfrUk7GHU3dMIuaLOkF6ixtuEly58w0v+ElUSfCY
eeIHm1+ziyWzcYF+VELXZD6sexr+NG4zTa0fP4TPNdTfwJHcIiSI3YdaeXrC9AcT
Q4OeWvBdRP3NRo6XbYSRkXQ/1wpwH81HCFSmdCOjOIDAsSOWv/BREKUWtBxr8gi6
S428iI+xi2GbEMsQQJ5lNBEyGlW1NPlzFooWNObRMMrdyVOc7okMnzDbWldSndVE
4e5xkTJGsTE++BGRsXFKcvVwYN1SVVX6EaM2cLe+8aUF+dY0Ye0lbtRdh4lOM1hu
y4/Ss3S08YGfvIwhuCfzz+xIdNknbkLaoeSYA2jzLEce5BtByAW9vWm7R2/Nsu/4
FfOW7n5QDrGpu1jnSpvgDwq8U0JyL5EP6Kw6me4zvfz+H55nQRe6e/F5wXUDeIkK
UoKDO4TlTk0=
=P5+m
-----END PGP SIGNATURE-----

--Sig_/6N0KNe6p7/2Jbm6QyQjKcUI--
