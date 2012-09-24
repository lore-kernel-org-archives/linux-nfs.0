Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40062 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932161Ab2IXT7r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:59:47 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 25/28] NFSv4.1: Clear NFS_LAYOUT_BULK_RECALL when the layout segments are freed
Date: Mon, 24 Sep 2012 15:56:43 -0400
Message-Id: <1348516606-22721-25-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-24-git-send-email-Trond.Myklebust@netapp.com>
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
 <1348516606-22721-22-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-23-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-24-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once all the affected layout segments have been freed up, clear the
NFS_LAYOUT_BULK_RECALL flag so that we can reuse the pnfs_layout_hdr

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 791eda9..86d95bf 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -331,6 +331,8 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	list_del_init(&lseg->pls_list);
 	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
 	atomic_dec(&lo->plh_refcount);
+	if (list_empty(&lo->plh_segs))
+		clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
-- 
1.7.11.4

