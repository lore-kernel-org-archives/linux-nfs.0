Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39998 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932090Ab2IXT71 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:59:27 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 22/28] NFSv4.1: Get rid of pNFS spin lock debugging asserts...
Date: Mon, 24 Sep 2012 15:56:40 -0400
Message-Id: <1348516606-22721-22-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-21-git-send-email-Trond.Myklebust@netapp.com>
References: <1348516606-22721-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-10-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-11-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-12-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-13-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-14-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-15-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-16-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-17-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-18-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-19-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-20-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-21-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These are all in static declared functions that are called only once.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bfe5170..bf99ace 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -859,7 +859,6 @@ pnfs_layout_insert_lseg(struct pnfs_layout_hdr *lo,
 
 	dprintk("%s:Begin\n", __func__);
 
-	assert_spin_locked(&lo->plh_inode->i_lock);
 	list_for_each_entry(lp, &lo->plh_segs, pls_list) {
 		if (cmp_layout(&lseg->pls_range, &lp->pls_range) > 0)
 			continue;
@@ -913,7 +912,6 @@ pnfs_find_alloc_layout(struct inode *ino,
 
 	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
 
-	assert_spin_locked(&ino->i_lock);
 	if (nfsi->layout) {
 		if (test_bit(NFS_LAYOUT_DESTROYED, &nfsi->layout->plh_flags))
 			return NULL;
@@ -970,7 +968,6 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 
 	dprintk("%s:Begin\n", __func__);
 
-	assert_spin_locked(&lo->plh_inode->i_lock);
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
 		    is_matching_lseg(&lseg->pls_range, range)) {
-- 
1.7.11.4

