Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30009 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753812Ab1HVVNB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Aug 2011 17:13:01 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/4] NFSv4: nfs4_proc_async_renew should use a GFP_NOFS allocation
Date: Mon, 22 Aug 2011 17:12:37 -0400
Message-Id: <1314047560-24534-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We shouldn't allow the renew daemon to do direct reclaim on the NFS
partition.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8c77039..776b41a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3397,7 +3397,7 @@ int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
 
 	if (!atomic_inc_not_zero(&clp->cl_count))
 		return -EIO;
-	data = kmalloc(sizeof(*data), GFP_KERNEL);
+	data = kmalloc(sizeof(*data), GFP_NOFS);
 	if (data == NULL)
 		return -ENOMEM;
 	data->client = clp;
-- 
1.7.6

