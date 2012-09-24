Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47302 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932122Ab2IXT6N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:58:13 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 10/28] NFSv4.1: Don't drop the pnfs_layout_hdr after a layoutget failure
Date: Mon, 24 Sep 2012 15:56:28 -0400
Message-Id: <1348516606-22721-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1348516606-22721-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to cache the pnfs_layout_hdr after a layoutget or i/o
failure so that pnfs_update_layout() can find it and know when
it is time to retry.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 40 ++++++++++++++++++++++++++++++++--------
 1 file changed, 32 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a9c9291..23c5d18 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -247,10 +247,28 @@ pnfs_iomode_to_fail_bit(u32 iomode)
 }
 
 static void
-pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
+pnfs_layout_set_fail_bit(struct pnfs_layout_hdr *lo, int fail_bit)
 {
 	lo->plh_retry_timestamp = jiffies;
-	set_bit(pnfs_iomode_to_fail_bit(iomode), &lo->plh_flags);
+	if (test_and_set_bit(fail_bit, &lo->plh_flags))
+		atomic_inc(&lo->plh_refcount);
+}
+
+static void
+pnfs_layout_clear_fail_bit(struct pnfs_layout_hdr *lo, int fail_bit)
+{
+	if (test_and_clear_bit(fail_bit, &lo->plh_flags))
+		atomic_dec(&lo->plh_refcount);
+}
+
+static void
+pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
+{
+	struct inode *inode = lo->plh_inode;
+
+	spin_lock(&inode->i_lock);
+	pnfs_layout_set_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
+	spin_unlock(&inode->i_lock);
 	dprintk("%s Setting layout IOMODE_%s fail bit\n", __func__,
 			iomode == IOMODE_RW ?  "RW" : "READ");
 }
@@ -259,14 +277,15 @@ static bool
 pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 {
 	unsigned long start, end;
-	if (test_bit(pnfs_iomode_to_fail_bit(iomode), &lo->plh_flags) == 0)
+	int fail_bit = pnfs_iomode_to_fail_bit(iomode);
+
+	if (test_bit(fail_bit, &lo->plh_flags) == 0)
 		return false;
 	end = jiffies;
 	start = end - PNFS_LAYOUTGET_RETRY_TIMEOUT;
 	if (!time_in_range(lo->plh_retry_timestamp, start, end)) {
 		/* It is time to retry the failed layoutgets */
-		clear_bit(NFS_LAYOUT_RW_FAILED, &lo->plh_flags);
-		clear_bit(NFS_LAYOUT_RO_FAILED, &lo->plh_flags);
+		pnfs_layout_clear_fail_bit(lo, fail_bit);
 		return false;
 	}
 	return true;
@@ -493,9 +512,14 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	if (lo) {
 		lo->plh_block_lgets++; /* permanently block new LAYOUTGETs */
 		pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
-	}
-	spin_unlock(&nfsi->vfs_inode.i_lock);
-	pnfs_free_lseg_list(&tmp_list);
+		pnfs_get_layout_hdr(lo);
+		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RO_FAILED);
+		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RW_FAILED);
+		spin_unlock(&nfsi->vfs_inode.i_lock);
+		pnfs_free_lseg_list(&tmp_list);
+		pnfs_put_layout_hdr(lo);
+	} else
+		spin_unlock(&nfsi->vfs_inode.i_lock);
 }
 EXPORT_SYMBOL_GPL(pnfs_destroy_layout);
 
-- 
1.7.11.4

