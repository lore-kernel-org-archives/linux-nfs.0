Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34148 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933186AbdGKVyk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jul 2017 17:54:40 -0400
Received: by mail-io0-f196.google.com with SMTP id f66so487003iof.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 Jul 2017 14:54:40 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] NFSv3: Convert nfs3_proc_access() to use nfs_access_set_mask()
Date: Tue, 11 Jul 2017 17:54:33 -0400
Message-Id: <20170711215435.18736-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170711215435.18736-1-trond.myklebust@primarydata.com>
References: <20170711215435.18736-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs3proc.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 0c07b567118d..dd43f1cf0485 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -220,15 +220,8 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
 	nfs_refresh_inode(inode, res.fattr);
-	if (status == 0) {
-		entry->mask = 0;
-		if (res.access & NFS3_ACCESS_READ)
-			entry->mask |= MAY_READ;
-		if (res.access & (NFS3_ACCESS_MODIFY | NFS3_ACCESS_EXTEND | NFS3_ACCESS_DELETE))
-			entry->mask |= MAY_WRITE;
-		if (res.access & (NFS3_ACCESS_LOOKUP|NFS3_ACCESS_EXECUTE))
-			entry->mask |= MAY_EXEC;
-	}
+	if (status == 0)
+		nfs_access_set_mask(entry, res.access);
 	nfs_free_fattr(res.fattr);
 out:
 	dprintk("NFS reply access: %d\n", status);
-- 
2.13.0

