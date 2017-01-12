Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33879 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750843AbdALXCr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 18:02:47 -0500
Received: by mail-it0-f65.google.com with SMTP id o185so3408362itb.1
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2017 15:02:47 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/4] NFSv4: Don't apply change_info4 twice on rename within a directory
Date: Thu, 12 Jan 2017 18:02:38 -0500
Message-Id: <20170112230240.7730-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170112230240.7730-2-trond.myklebust@primarydata.com>
References: <20170112230240.7730-1-trond.myklebust@primarydata.com>
 <20170112230240.7730-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a file is renamed, but stays in the same directory, we will still receive
2 change_info4 structures describing the change to that directory, but we
only want to apply it once.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4010c33151ad..1e797bf74aaf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4159,8 +4159,11 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 	if (nfs4_async_handle_error(task, res->server, NULL, &data->timeout) == -EAGAIN)
 		return 0;
 
-	update_changeattr(old_dir, &res->old_cinfo);
-	update_changeattr(new_dir, &res->new_cinfo);
+	if (task->tk_status == 0) {
+		update_changeattr(old_dir, &res->old_cinfo);
+		if (new_dir != old_dir)
+			update_changeattr(new_dir, &res->new_cinfo);
+	}
 	return 1;
 }
 
-- 
2.9.3

