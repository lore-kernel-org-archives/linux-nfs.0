Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:32804 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750843AbdALXCs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 18:02:48 -0500
Received: by mail-it0-f67.google.com with SMTP id v14so3410553itb.0
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2017 15:02:48 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/4] NFSv4: Don't call update_changeattr() unless the unlink is successful
Date: Thu, 12 Jan 2017 18:02:39 -0500
Message-Id: <20170112230240.7730-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170112230240.7730-3-trond.myklebust@primarydata.com>
References: <20170112230240.7730-1-trond.myklebust@primarydata.com>
 <20170112230240.7730-2-trond.myklebust@primarydata.com>
 <20170112230240.7730-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the unlink wasn't successful, then the directory has presumably not
changed.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1e797bf74aaf..6a35204affa4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4125,7 +4125,8 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	if (nfs4_async_handle_error(task, res->server, NULL,
 				    &data->timeout) == -EAGAIN)
 		return 0;
-	update_changeattr(dir, &res->cinfo);
+	if (task->tk_status == 0)
+		update_changeattr(dir, &res->cinfo);
 	return 1;
 }
 
-- 
2.9.3

