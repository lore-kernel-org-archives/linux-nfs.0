Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35071 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757683AbdAKWHd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jan 2017 17:07:33 -0500
Received: by mail-io0-f196.google.com with SMTP id m98so565702iod.2
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jan 2017 14:07:15 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4: Don't call update_changeattr() unless the unlink is successful
Date: Wed, 11 Jan 2017 17:07:09 -0500
Message-Id: <20170111220709.19405-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170111220709.19405-2-trond.myklebust@primarydata.com>
References: <20170111220709.19405-1-trond.myklebust@primarydata.com>
 <20170111220709.19405-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the unlink wasn't successful, then the directory has presumably not
changed.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 77e5263838d9..2c3291581c8e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4126,7 +4126,8 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
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

