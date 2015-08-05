Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:32858 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbbHECaE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 22:30:04 -0400
Received: by igbpg9 with SMTP id pg9so105889131igb.0
        for <linux-nfs@vger.kernel.org>; Tue, 04 Aug 2015 19:30:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] NFSv4.1/pnfs: Remove redundant wakeup in pnfs_send_layoutreturn()
Date: Tue,  4 Aug 2015 22:29:56 -0400
Message-Id: <1438741796-22681-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1438741796-22681-5-git-send-email-trond.myklebust@primarydata.com>
References: <1438741796-22681-1-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-2-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-3-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-4-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_clear_layoutreturn_waitbit() should already be calling
rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq) for us.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b6540cc41f7c..9ca637821bb6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -943,7 +943,6 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 		status = -ENOMEM;
 		spin_lock(&ino->i_lock);
 		pnfs_clear_layoutreturn_waitbit(lo);
-		rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
 		spin_unlock(&ino->i_lock);
 		pnfs_put_layout_hdr(lo);
 		goto out;
-- 
2.4.3

