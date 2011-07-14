Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34043 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932140Ab1GNUuh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jul 2011 16:50:37 -0400
Date: Thu, 14 Jul 2011 16:50:36 -0400
To: Alex Elder <aelder@sgi.com>, xfs-masters@oss.sgi.com
Cc: xfs@oss.sgi.com, linux-nfs@vger.kernel.org
Subject: [PATCH] xfs: failure mapping nfs fh to inode should return ESTALE
Message-ID: <20110714205036.GA19457@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

On xfs exports, nfsd is incorrectly returning ENOENT instead of ESTALE
on attempts to use a filehandle of a deleted file (spotted with pynfs
test PUTFH3).  The ENOENT was coming from xfs_iget.

(It's tempting to wonder whether we should just map all xfs_iget errors
to ESTALE, but I don't believe so--xfs_iget can also return ENOMEM at
least, which we wouldn't want mapped to ESTALE.)

While we're at it, the other return of ENOENT in xfs_nfs_get_inode()
also looks wrong.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/xfs/linux-2.6/xfs_export.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_export.c b/fs/xfs/linux-2.6/xfs_export.c
index f4f878f..75e5d32 100644
--- a/fs/xfs/linux-2.6/xfs_export.c
+++ b/fs/xfs/linux-2.6/xfs_export.c
@@ -151,14 +151,14 @@ xfs_nfs_get_inode(
 		 * We don't use ESTALE directly down the chain to not
 		 * confuse applications using bulkstat that expect EINVAL.
 		 */
-		if (error == EINVAL)
+		if (error == EINVAL || error == ENOENT)
 			error = ESTALE;
 		return ERR_PTR(-error);
 	}
 
 	if (ip->i_d.di_gen != generation) {
 		IRELE(ip);
-		return ERR_PTR(-ENOENT);
+		return ERR_PTR(-ESTALE);
 	}
 
 	return VFS_I(ip);
-- 
1.7.4.1

