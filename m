Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:40017 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755032Ab0IJUIt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 16:08:49 -0400
Received: by gyd8 with SMTP id 8so1365571gyd.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 13:08:49 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/11] NFS: Fix NFSv3 debugging messages in fs/nfs/nfs3proc.c
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 10 Sep 2010 16:08:46 -0400
Message-ID: <20100910200845.13321.19056.stgit@seurat.1015granger.net>
In-Reply-To: <20100910200512.13321.55605.stgit@seurat.1015granger.net>
References: <20100910200512.13321.55605.stgit@seurat.1015granger.net>
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
 

