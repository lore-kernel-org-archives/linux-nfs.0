Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52474 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932599Ab2IUUvq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Sep 2012 16:51:46 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 10/26] NFSv4.1: pnfs_layout_io_test_failed must clear invalid lsegs before a retry
Date: Fri, 21 Sep 2012 16:50:05 -0400
Message-Id: <1348260621-10294-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348260621-10294-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1348260621-10294-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If pnfs_layout_io_test_failed() authorises a retry of the failed layoutgets,
it should first clear the existing layout segments so that we start afresh.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cbbb0fc..80aaaba 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -256,7 +256,8 @@ pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 }
 
 static bool
-pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode)
+pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode,
+		struct list_head *head)
 {
 	unsigned long start, end;
 	if (test_bit(pnfs_iomode_to_fail_bit(iomode), &lo->plh_flags) == 0)
@@ -267,6 +268,7 @@ pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 		/* It is time to retry the failed layoutgets */
 		clear_bit(NFS_LAYOUT_RW_FAILED, &lo->plh_flags);
 		clear_bit(NFS_LAYOUT_RO_FAILED, &lo->plh_flags);
+		pnfs_mark_matching_lsegs_invalid(lo, head, NULL);
 		return false;
 	}
 	return true;
@@ -1058,6 +1060,7 @@ pnfs_update_layout(struct inode *ino,
 	struct nfs_client *clp = server->nfs_client;
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg = NULL;
+	LIST_HEAD(tmp_list);
 	bool first = false;
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
@@ -1081,7 +1084,7 @@ pnfs_update_layout(struct inode *ino,
 	}
 
 	/* if LAYOUTGET already failed once we don't try again */
-	if (pnfs_layout_io_test_failed(nfsi->layout, iomode))
+	if (pnfs_layout_io_test_failed(nfsi->layout, iomode, &tmp_list))
 		goto out_unlock;
 
 	/* Check to see if the layout for the given range already exists */
@@ -1127,6 +1130,7 @@ pnfs_update_layout(struct inode *ino,
 	}
 	atomic_dec(&lo->plh_outstanding);
 out:
+	pnfs_free_lseg_list(&tmp_list);
 	pnfs_put_layout_hdr(lo);
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout ? nfsi->layout->plh_flags : -1, lseg);
-- 
1.7.11.4

