Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51364 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750849AbdGCF2L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Jul 2017 01:28:11 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 03 Jul 2017 15:27:26 +1000
Subject: [PATCH 2/2] NFS: check for nfs_refresh_inode() errors in nfs_fhget()
Cc: linux-nfs@vger.kernel.org
Message-ID: <149905964683.6926.10116141535154072625.stgit@noble>
In-Reply-To: <149905933708.6926.8527235505351389675.stgit@noble>
References: <149905933708.6926.8527235505351389675.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an NFS server returns a filehandle that we have previously
seen, and reports a different type, then nfs_refresh_inode()
will log a warning and return an error.

nfs_fhget() does not check for this error and may return an
inode with a different type than the one that the server
reported.

This is likely to cause confusion, and is one way that
->open_context() could return a directory inode as discussed
in the previous patch.

So if nfs_refresh_inode() returns and error, return that error
from nfs_fhget() to avoid the confusion propagating.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/inode.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1de93ba78dc9..5751c1310177 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -525,8 +525,14 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		nfs_fscache_init_inode(inode);
 
 		unlock_new_inode(inode);
-	} else
-		nfs_refresh_inode(inode, fattr);
+	} else {
+		int err = nfs_refresh_inode(inode, fattr);
+		if (err < 0) {
+			iput(inode);
+			inode = ERR_PTR(err);
+			goto out_no_inode;
+		}
+	}
 	dprintk("NFS: nfs_fhget(%s/%Lu fh_crc=0x%08x ct=%d)\n",
 		inode->i_sb->s_id,
 		(unsigned long long)NFS_FILEID(inode),


