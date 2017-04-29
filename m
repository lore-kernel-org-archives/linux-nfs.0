Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32964 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1036058AbdD2Ssw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Apr 2017 14:48:52 -0400
Received: by mail-io0-f193.google.com with SMTP id k87so15903534ioi.0
        for <linux-nfs@vger.kernel.org>; Sat, 29 Apr 2017 11:48:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] pNFS: Ensure we commit the layout if it has been invalidated
Date: Sat, 29 Apr 2017 14:48:45 -0400
Message-Id: <20170429184845.58057-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170429184845.58057-3-trond.myklebust@primarydata.com>
References: <20170429184845.58057-1-trond.myklebust@primarydata.com>
 <20170429184845.58057-2-trond.myklebust@primarydata.com>
 <20170429184845.58057-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the layout is being invalidated on the server, then we must
invoke nfs_commit_inode() to ensure any commits to the DS get
cleared out.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs42proc.c | 1 +
 fs/nfs/nfs4proc.c  | 1 +
 fs/nfs/pnfs.c      | 3 +++
 3 files changed, 5 insertions(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index c81c61971625..87f5b7b971ca 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -379,6 +379,7 @@ nfs42_layoutstat_done(struct rpc_task *task, void *calldata)
 			pnfs_mark_layout_stateid_invalid(lo, &head);
 			spin_unlock(&inode->i_lock);
 			pnfs_free_lseg_list(&head);
+			nfs_commit_inode(inode, 0);
 		} else
 			spin_unlock(&inode->i_lock);
 		break;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c2b82caa9068..158c3d52146f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8330,6 +8330,7 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 		 */
 		pnfs_mark_layout_stateid_invalid(lo, &head);
 		spin_unlock(&inode->i_lock);
+		nfs_commit_inode(inode, 0);
 		pnfs_free_lseg_list(&head);
 		status = -EAGAIN;
 		goto out;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6c2e4c73684c..140ecd7d350f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -727,6 +727,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RW_FAILED);
 		spin_unlock(&nfsi->vfs_inode.i_lock);
 		pnfs_free_lseg_list(&tmp_list);
+		nfs_commit_inode(&nfsi->vfs_inode, 0);
 		pnfs_put_layout_hdr(lo);
 	} else
 		spin_unlock(&nfsi->vfs_inode.i_lock);
@@ -1989,6 +1990,8 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	spin_unlock(&ino->i_lock);
 	lseg->pls_layout = lo;
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
+	if (!pnfs_layout_is_valid(lo))
+		nfs_commit_inode(ino, 0);
 	return ERR_PTR(-EAGAIN);
 }
 
-- 
2.9.3

