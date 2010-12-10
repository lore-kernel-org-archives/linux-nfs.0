Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42664 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab0LJGIx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:53 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLs023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:52 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 17/22] pnfs-submit: wave2: change plh_outstanding to atomic_t
Date: Thu,  9 Dec 2010 20:22:52 -0500
Message-Id: <1291944177-7819-18-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |    4 ++--
 fs/nfs/pnfs.c     |   11 ++++++-----
 fs/nfs/pnfs.h     |    2 +-
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index adcab30..c4dc5b1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5607,7 +5607,7 @@ static void nfs4_layoutreturn_release(void *calldata)
 
 		spin_lock(&ino->i_lock);
 		lo->plh_block_lgets--;
-		lo->plh_outstanding--;
+		atomic_dec(&lo->plh_outstanding);
 		spin_unlock(&ino->i_lock);
 		put_layout_hdr(ino);
 	}
@@ -5644,7 +5644,7 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
 		/* FIXME we should test for BULK here */
 		spin_lock(&lo->inode->i_lock);
 		BUG_ON(lo->plh_block_lgets == 0);
-		lo->plh_outstanding++;
+		atomic_inc(&lo->plh_outstanding);
 		spin_unlock(&lo->inode->i_lock);
 	}
 	task = rpc_run_task(&task_setup_data);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f9757ff..27a1973 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -505,7 +505,8 @@ pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
 		return true;
 	return lo->plh_block_lgets ||
 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
-		(list_empty(&lo->segs) && (lo->plh_outstanding > lget));
+		(list_empty(&lo->segs) &&
+		 (atomic_read(&lo->plh_outstanding) > lget));
 }
 
 int
@@ -868,7 +869,7 @@ pnfs_update_layout(struct inode *ino,
 
 	if (pnfs_layoutgets_blocked(lo, NULL, 0))
 		goto out_unlock;
-	lo->plh_outstanding++;
+	atomic_inc(&lo->plh_outstanding);
 
 	get_layout_hdr(lo); /* Matched in pnfs_layoutget_release */
 	if (list_empty(&lo->segs)) {
@@ -883,18 +884,18 @@ pnfs_update_layout(struct inode *ino,
 	spin_unlock(&ino->i_lock);
 
 	lseg = send_layoutget(lo, ctx, &arg);
-	spin_lock(&ino->i_lock);
 	if (!lseg) {
+		spin_lock(&ino->i_lock);
 		if (list_empty(&lo->segs)) {
 			spin_lock(&clp->cl_lock);
 			list_del_init(&lo->layouts);
 			spin_unlock(&clp->cl_lock);
 			clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 		}
+		spin_unlock(&ino->i_lock);
 	}
-	lo->plh_outstanding--;
+	atomic_dec(&lo->plh_outstanding);
 	put_layout_hdr(ino);
-	spin_unlock(&ino->i_lock);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout->plh_flags, lseg);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1ccc35d..b5a30b8 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -100,7 +100,7 @@ struct pnfs_layout_hdr {
 	struct list_head	segs;      /* layout segments list */
 	int			roc_iomode;/* return on close iomode, 0=none */
 	nfs4_stateid		stateid;
-	unsigned long		plh_outstanding; /* number of RPCs out */
+	atomic_t		plh_outstanding; /* number of RPCs out */
 	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
 	u32			plh_barrier; /* ignore lower seqids */
 	unsigned long		plh_flags;
-- 
1.7.2.1

