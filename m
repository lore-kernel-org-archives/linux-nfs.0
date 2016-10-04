Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35722 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751150AbcJDEHr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2016 00:07:47 -0400
Received: by mail-it0-f67.google.com with SMTP id l13so8110086itl.2
        for <linux-nfs@vger.kernel.org>; Mon, 03 Oct 2016 21:07:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.2: Fix a reference leak in nfs42_proc_layoutstats_generic
Date: Tue,  4 Oct 2016 00:07:43 -0400
Message-Id: <1475554063-8219-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@poochiereds.net>

The caller of rpc_run_task also gets a reference that must be put.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
Cc: stable@vger.kernel.org # 4.2+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs42proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 64b43b4ad9dd..608501971fe0 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -443,6 +443,7 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *server,
 	task = rpc_run_task(&task_setup);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
+	rpc_put_task(task);
 	return 0;
 }
 
-- 
2.7.4

