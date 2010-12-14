Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11394 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758144Ab0LNWDF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 17:03:05 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBEM32of010255
	for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 14:03:05 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] pnfs-submit: wave2: make put_layout_hdr have args consistent with related functions
Date: Tue, 14 Dec 2010 17:03:00 -0500
Message-Id: <1292364180-28512-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292364180-28512-1-git-send-email-iisaman@netapp.com>
References: <1292364180-28512-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

put_layout_hdr_locked() and get_layout_hdr() take lo, not inode,
as argument.  So make put_layout_hdr do likewise.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |    4 ++--
 fs/nfs/nfs4proc.c      |    2 +-
 fs/nfs/pnfs.c          |   12 ++++++------
 fs/nfs/pnfs.h          |    2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index cbde28e..38d8a23 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -198,7 +198,7 @@ static int initiate_layout_draining(struct nfs_client *clp,
 			list_del_init(&lo->plh_bulk_recall);
 			spin_unlock(&lo->inode->i_lock);
 			trigger_flush(lo->inode);
-			put_layout_hdr(lo->inode);
+			put_layout_hdr(lo);
 			rv = NFS4_OK;
 		}
 		pnfs_free_lseg_list(&free_me_list);
@@ -229,7 +229,7 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 		spin_lock(&lo->inode->i_lock);
 		lo->plh_block_lgets--;
 		spin_unlock(&lo->inode->i_lock);
-		put_layout_hdr(args->cbl_inode);
+		put_layout_hdr(lo);
 	}
 	clear_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state);
 out:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 224bdfe..ad9c018 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5498,7 +5498,7 @@ static void nfs4_layoutcommit_release(void *lcdata)
 		(struct nfs4_layoutcommit_data *)lcdata;
 
 	/* Matched by get_layout in pnfs_layoutcommit_inode */
-	put_layout_hdr(data->args.inode);
+	put_layout_hdr(NFS_I(data->args.inode)->layout);
 	put_rpccred(data->cred);
 	kfree(lcdata);
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b815e3e..5c6b4fb 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -258,9 +258,9 @@ put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
 }
 
 void
-put_layout_hdr(struct inode *inode)
+put_layout_hdr(struct pnfs_layout_hdr *lo)
 {
-	struct pnfs_layout_hdr *lo = NFS_I(inode)->layout;
+	struct inode *inode = lo->inode;
 
 	BUG_ON(atomic_read(&lo->plh_refcount) == 0);
 	if (atomic_dec_and_lock(&lo->plh_refcount, &inode->i_lock)) {
@@ -336,7 +336,7 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
 		notify_drained(NFS_SERVER(ino)->nfs_client, count);
 		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
-		put_layout_hdr(ino);
+		put_layout_hdr(NFS_I(ino)->layout);
 	}
 }
 EXPORT_SYMBOL_GPL(put_lseg);
@@ -412,7 +412,7 @@ pnfs_free_lseg_list(struct list_head *free_me)
 		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
 		notify_drained(NFS_SERVER(ino)->nfs_client, count);
 		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
-		put_layout_hdr(ino);
+		put_layout_hdr(NFS_I(ino)->layout);
 	}
 	INIT_LIST_HEAD(free_me);
 }
@@ -924,7 +924,7 @@ pnfs_update_layout(struct inode *ino,
 		spin_unlock(&ino->i_lock);
 	}
 	atomic_dec(&lo->plh_outstanding);
-	put_layout_hdr(ino);
+	put_layout_hdr(lo);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout->plh_flags, lseg);
@@ -1259,7 +1259,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	if (status) {
 		/* The layout driver failed to setup the layoutcommit */
 		put_rpccred(data->cred);
-		put_layout_hdr(inode);
+		put_layout_hdr(NFS_I(inode)->layout);
 		goto out_free;
 	}
 	status = nfs4_proc_layoutcommit(data, sync);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 0ddab0d..c413954 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -212,7 +212,7 @@ int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
-void put_layout_hdr(struct inode *inode);
+void put_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     const nfs4_stateid *new,
 			     bool update_barrier);
-- 
1.7.2.1

