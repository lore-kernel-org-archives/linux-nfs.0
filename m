Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34728 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751553AbeCTUyA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:54:00 -0400
Received: by mail-it0-f67.google.com with SMTP id z7-v6so13983866iti.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:54:00 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] NFS: Don't force unnecessary cache invalidation in nfs_update_inode()
Date: Tue, 20 Mar 2018 16:53:30 -0400
Message-Id: <20180320205332.94132-5-trond.myklebust@primarydata.com>
In-Reply-To: <20180320205332.94132-4-trond.myklebust@primarydata.com>
References: <20180320205332.94132-1-trond.myklebust@primarydata.com>
 <20180320205332.94132-2-trond.myklebust@primarydata.com>
 <20180320205332.94132-3-trond.myklebust@primarydata.com>
 <20180320205332.94132-4-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we managed to revalidate all the attributes, then there is no reason
to mark them as invalid again. We do, however want to ensure that we
set nfsi->attrtimeo correctly.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index d8e8bf9da211..6e5a96e2e9a0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1799,6 +1799,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 					| NFS_INO_INVALID_DATA
 					| NFS_INO_INVALID_ACCESS
 					| NFS_INO_INVALID_ACL;
+				/* Force revalidate of all attributes */
+				save_cache_validity |= NFS_INO_INVALID_ATTR;
 				if (S_ISDIR(inode->i_mode))
 					nfs_force_lookup_revalidate(inode);
 			}
@@ -1937,6 +1939,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 
 	/* Update attrtimeo value if we're out of the unstable period */
 	if (invalid & NFS_INO_INVALID_ATTR) {
+		invalid &= ~NFS_INO_INVALID_ATTR;
 		nfs_inc_stats(inode, NFSIOS_ATTRINVALIDATE);
 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
 		nfsi->attrtimeo_timestamp = now;
@@ -1957,10 +1960,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			nfsi->attr_gencount = fattr->gencount;
 	}
 
-	/* Don't declare attrcache up to date if there were no attrs! */
-	if (cache_revalidated)
-		invalid &= ~NFS_INO_INVALID_ATTR;
-
 	/* Don't invalidate the data if we were to blame */
 	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
 				|| S_ISLNK(inode->i_mode)))
-- 
2.14.3

