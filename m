Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33475 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752234AbdAKWHd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jan 2017 17:07:33 -0500
Received: by mail-io0-f193.google.com with SMTP id 101so577273iom.0
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jan 2017 14:07:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFSv4: Don't apply change_info4 twice on rename within a directory
Date: Wed, 11 Jan 2017 17:07:08 -0500
Message-Id: <20170111220709.19405-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170111220709.19405-1-trond.myklebust@primarydata.com>
References: <20170111220709.19405-1-trond.myklebust@primarydata.com>
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
index 176561a0fe0d..77e5263838d9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4160,8 +4160,11 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
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

