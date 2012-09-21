Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35100 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152Ab2IUUwu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Sep 2012 16:52:50 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 21/26] NFSv4.1: Get rid of pNFS spin lock debugging asserts...
Date: Fri, 21 Sep 2012 16:50:16 -0400
Message-Id: <1348260621-10294-21-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348260621-10294-20-git-send-email-Trond.Myklebust@netapp.com>
References: <1348260621-10294-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-10-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-11-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-12-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-13-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-14-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-15-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-16-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-17-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-18-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-19-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-20-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These are all in static declared functions that are called only once.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9c5320c..bbdce87 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -829,7 +829,6 @@ pnfs_layout_insert_lseg(struct pnfs_layout_hdr *lo,
 
 	dprintk("%s:Begin\n", __func__);
 
-	assert_spin_locked(&lo->plh_inode->i_lock);
 	list_for_each_entry(lp, &lo->plh_segs, pls_list) {
 		if (cmp_layout(&lseg->pls_range, &lp->pls_range) > 0)
 			continue;
@@ -883,7 +882,6 @@ pnfs_find_alloc_layout(struct inode *ino,
 
 	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
 
-	assert_spin_locked(&ino->i_lock);
 	if (nfsi->layout) {
 		if (test_bit(NFS_LAYOUT_DESTROYED, &nfsi->layout->plh_flags))
 			return NULL;
@@ -940,7 +938,6 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 
 	dprintk("%s:Begin\n", __func__);
 
-	assert_spin_locked(&lo->plh_inode->i_lock);
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
 		    is_matching_lseg(&lseg->pls_range, range)) {
-- 
1.7.11.4

