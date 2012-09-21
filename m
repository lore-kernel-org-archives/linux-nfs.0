Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26053 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754713Ab2IUBgJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Sep 2012 21:36:09 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/14] NFSv4.1: Clean up pnfs_put_lseg()
Date: Thu, 20 Sep 2012 21:35:54 -0400
Message-Id: <1348191357-44503-11-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348191357-44503-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1348191357-44503-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-10-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no longer a need to use pnfs_free_lseg_list(). Just call
pnfs_free_lseg() directly.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 557faaf..ed8d674 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -290,7 +290,7 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	lseg->pls_layout = lo;
 }
 
-static void free_lseg(struct pnfs_layout_segment *lseg)
+static void pnfs_free_lseg(struct pnfs_layout_segment *lseg)
 {
 	struct inode *ino = lseg->pls_layout->plh_inode;
 
@@ -327,12 +327,9 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 	lo = lseg->pls_layout;
 	inode = lo->plh_inode;
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
-		LIST_HEAD(free_me);
-
 		pnfs_layout_remove_lseg(lo, lseg);
 		spin_unlock(&inode->i_lock);
-		list_add(&lseg->pls_list, &free_me);
-		pnfs_free_lseg_list(&free_me);
+		pnfs_free_lseg(lseg);
 	}
 }
 EXPORT_SYMBOL_GPL(pnfs_put_lseg);
@@ -469,7 +466,7 @@ pnfs_free_lseg_list(struct list_head *free_me)
 
 	list_for_each_entry_safe(lseg, tmp, free_me, pls_list) {
 		list_del(&lseg->pls_list);
-		free_lseg(lseg);
+		pnfs_free_lseg(lseg);
 	}
 }
 
-- 
1.7.11.4

