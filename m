Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41558 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938545AbdD0OpS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 27 Apr 2017 10:45:18 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8E40979347
        for <linux-nfs@vger.kernel.org>; Thu, 27 Apr 2017 14:45:16 +0000 (UTC)
Received: from dwysocha.rdu.csb (unknown [10.12.214.15])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 69C3899455
        for <linux-nfs@vger.kernel.org>; Thu, 27 Apr 2017 14:45:16 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] Fix nfs_client refcounting if kmalloc fails in nfs4_proc_exchange_id and nfs4_proc_async_renew
Date: Thu, 27 Apr 2017 10:45:15 -0400
Message-Id: <1493304315-11271-1-git-send-email-dwysocha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If memory allocation fails for the callback data, we need to put the nfs_client
or we end up with an elevated refcount.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 fs/nfs/nfs4proc.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d8338c6..0fbc16a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4804,8 +4804,10 @@ static int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred,
 	if (!atomic_inc_not_zero(&clp->cl_count))
 		return -EIO;
 	data = kmalloc(sizeof(*data), GFP_NOFS);
-	if (data == NULL)
+	if (data == NULL) {
+		nfs_put_client(clp);
 		return -ENOMEM;
+	}
 	data->client = clp;
 	data->timestamp = jiffies;
 	return rpc_call_async(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT,
@@ -7466,8 +7468,10 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 
 	status = -ENOMEM;
 	calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
-	if (!calldata)
+	if (!calldata) {
+		nfs_put_client(clp);
 		goto out;
+	}
 
 	if (!xprt)
 		nfs4_init_boot_verifier(clp, &verifier);
-- 
1.8.3.1

