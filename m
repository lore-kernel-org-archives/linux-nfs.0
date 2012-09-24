Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39032 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932119Ab2IXT6S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:58:18 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 11/28] NFSv4.1: pnfs_layout_io_set_failed must clear invalid lsegs
Date: Mon, 24 Sep 2012 15:56:29 -0400
Message-Id: <1348516606-22721-11-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-10-git-send-email-Trond.Myklebust@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If pnfs_layout_io_test_failed() authorises a retry of the failed layoutgets,
we should clear the existing layout segments so that we start afresh. Do
this in pnfs_layout_io_set_failed().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 23c5d18..d0f865f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -265,10 +265,18 @@ static void
 pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 {
 	struct inode *inode = lo->plh_inode;
+	struct pnfs_layout_range range = {
+		.iomode = iomode,
+		.offset = 0,
+		.length = NFS4_MAX_UINT64,
+	};
+	LIST_HEAD(head);
 
 	spin_lock(&inode->i_lock);
 	pnfs_layout_set_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
+	pnfs_mark_matching_lsegs_invalid(lo, &head, &range);
 	spin_unlock(&inode->i_lock);
+	pnfs_free_lseg_list(&head);
 	dprintk("%s Setting layout IOMODE_%s fail bit\n", __func__,
 			iomode == IOMODE_RW ?  "RW" : "READ");
 }
-- 
1.7.11.4

