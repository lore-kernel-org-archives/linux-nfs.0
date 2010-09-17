Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:44634 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755450Ab0IQQ0X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 12:26:23 -0400
Received: by gwj17 with SMTP id 17so783842gwj.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 09:26:23 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/22] NFS: Fix NFSv3 debugging messages in fs/nfs/nfs3proc.c
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 17 Sep 2010 12:26:20 -0400
Message-ID: <20100917162620.19761.87102.stgit@seurat.1015granger.net>
In-Reply-To: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
References: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs3proc.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index fabb4f2..2792895 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -652,7 +652,8 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 
 	nfs_free_fattr(res.dir_attr);
 out:
-	dprintk("NFS reply readdir: %d\n", status);
+	dprintk("NFS reply readdir%s: %d\n",
+			plus? "plus" : "", status);
 	return status;
 }
 
@@ -722,7 +723,7 @@ nfs3_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 	dprintk("NFS call  fsstat\n");
 	nfs_fattr_init(stat->fattr);
 	status = rpc_call_sync(server->client, &msg, 0);
-	dprintk("NFS reply statfs: %d\n", status);
+	dprintk("NFS reply fsstat: %d\n", status);
 	return status;
 }
 

