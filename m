Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:33655 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126AbbGIQUQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 12:20:16 -0400
Received: by ykeo3 with SMTP id o3so119939440yke.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jul 2015 09:20:15 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, meir.leopold@primarydata.com
Subject: [PATCH] nfs: plug rpc_task leak in layoutstats code
Date: Thu,  9 Jul 2015 12:20:07 -0400
Message-Id: <1436458807-27351-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The caller of rpc_run_task also gets a reference that must be put.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs42proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index f486b80f927a..dd33a249f97e 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -250,5 +250,6 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *server,
 	task = rpc_run_task(&task_setup);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
+	rpc_put_task(task);
 	return 0;
 }
-- 
2.4.3

