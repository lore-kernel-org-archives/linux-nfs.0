Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35071 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752472AbcLAWTg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:36 -0500
Received: by mail-io0-f194.google.com with SMTP id h133so4680855ioe.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:36 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/26] pNFS: Remove spurious wake up in pnfs_layout_remove_lseg()
Date: Thu,  1 Dec 2016 17:19:07 -0500
Message-Id: <20161201221922.15657-12-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-11-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
 <20161201221922.15657-10-trond.myklebust@primarydata.com>
 <20161201221922.15657-11-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no change to the value of NFS_LAYOUT_RETURN, so we should
not be waking up the RPC call.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 471018f27c8d..a64d1e40dba9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -420,8 +420,6 @@ static void
 pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 		struct pnfs_layout_segment *lseg)
 {
-	struct inode *inode = lo->plh_inode;
-
 	WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	list_del_init(&lseg->pls_list);
 	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
@@ -433,7 +431,6 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 		clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 	}
-	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
 static bool
-- 
2.9.3

