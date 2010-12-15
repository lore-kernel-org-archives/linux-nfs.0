Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2771 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102Ab0LOQDY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 11:03:24 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBFG3Lot001580
	for <linux-nfs@vger.kernel.org>; Wed, 15 Dec 2010 08:03:23 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/11] wave 2: share code between put_lseg and pnfs_free_lseg_list
Date: Wed, 15 Dec 2010 11:03:04 -0500
Message-Id: <1292428991-30788-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
References: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Create a free_lseg() function from the duplicated code.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   34 ++++++++++++++++------------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5c6b4fb..df6561a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -280,6 +280,18 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	lseg->pls_notify_count = 0;
 }
 
+static void free_lseg(struct pnfs_layout_segment *lseg)
+{
+	struct inode *ino = lseg->layout->inode;
+	int count = lseg->pls_notify_count;
+
+	BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
+	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
+	notify_drained(NFS_SERVER(ino)->nfs_client, count);
+	/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
+	put_layout_hdr(NFS_I(ino)->layout);
+}
+
 static void
 _put_lseg_common(struct pnfs_layout_segment *lseg)
 {
@@ -329,14 +341,9 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	ino = lseg->layout->inode;
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
-		int count = lseg->pls_notify_count;
-
 		_put_lseg_common(lseg);
 		spin_unlock(&ino->i_lock);
-		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-		notify_drained(NFS_SERVER(ino)->nfs_client, count);
-		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
-		put_layout_hdr(NFS_I(ino)->layout);
+		free_lseg(lseg);
 	}
 }
 EXPORT_SYMBOL_GPL(put_lseg);
@@ -402,18 +409,9 @@ void
 pnfs_free_lseg_list(struct list_head *free_me)
 {
 	struct pnfs_layout_segment *lseg, *tmp;
-	struct inode *ino;
-	int count;
-
-	list_for_each_entry_safe(lseg, tmp, free_me, fi_list) {
-		BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
-		ino = lseg->layout->inode;
-		count = lseg->pls_notify_count;
-		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-		notify_drained(NFS_SERVER(ino)->nfs_client, count);
-		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
-		put_layout_hdr(NFS_I(ino)->layout);
-	}
+
+	list_for_each_entry_safe(lseg, tmp, free_me, fi_list)
+		free_lseg(lseg);
 	INIT_LIST_HEAD(free_me);
 }
 
-- 
1.7.2.1

