Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51959 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753359Ab2IUUxN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Sep 2012 16:53:13 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 25/26] NFSv4.1: Clear NFS_LAYOUT_BULK_RECALL when the layout segments are freed
Date: Fri, 21 Sep 2012 16:50:20 -0400
Message-Id: <1348260621-10294-25-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348260621-10294-24-git-send-email-Trond.Myklebust@netapp.com>
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
 <1348260621-10294-21-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-22-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-23-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-24-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once all the affected layout segments have been freed up, clear the
NFS_LAYOUT_BULK_RECALL flag so that we can reuse the pnfs_layout_hdr

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8ba7c35..a5edf27 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -306,6 +306,8 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	list_del_init(&lseg->pls_list);
 	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
 	atomic_dec(&lo->plh_refcount);
+	if (list_empty(&lo->plh_segs))
+		clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
-- 
1.7.11.4

