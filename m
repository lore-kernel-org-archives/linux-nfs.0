Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6485 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab1DVIEq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 04:04:46 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] SQUASHME: remove assert_spin_locked from pnfs_clear_lseg_list
Date: Fri, 22 Apr 2011 11:04:30 +0300
Message-Id: <1303459470-16321-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DB125BD.3040703@panasas.com>
References: <4DB125BD.3040703@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

currently it's called only from the evict_inode path
no lock is needed there...

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0237b2c..bacde63 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -410,7 +410,11 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 	return invalid - removed;
 }
 
-/* Returns false if there was nothing to do, true otherwise */
+/*
+ * Returns false if there was nothing to do, true otherwise.
+ *
+ * Must be called under the i_lock (unless from the nfs4_evict_inode path)
+ */
 static bool
 pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 		     struct pnfs_layout_range *range)
@@ -420,7 +424,6 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 
 	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
 		__func__, lo, range->offset, range->length, range->iomode);
-	assert_spin_locked(&lo->plh_inode->i_lock);
 	if (list_empty(&lo->plh_segs)) {
 		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
 			put_layout_hdr_locked(lo);
-- 
1.7.3.4

