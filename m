Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:49803 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757508Ab2FZSNH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jun 2012 14:13:07 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: [PATCH] NFS: Check if rpcauth_create() returns an error code
Date: Tue, 26 Jun 2012 14:12:53 -0400
Message-Id: <1340734373-5596-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I was treating a NULL return value as an error, but this function will
instead return an ERR_PTR().  Now that I'm checking if the function
returns an error, I should also pass the error up the call stack.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4namespace.c |  4 ++--
 fs/nfs/nfs4proc.c      | 15 ++++-----------
 2 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 017b4b0..a8aafc6 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -205,9 +205,9 @@ struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *clnt, struct inode *ino
 		return clone;
 
 	auth = rpcauth_create(flavor, clone);
-	if (!auth) {
+	if (IS_ERR(auth)) {
 		rpc_shutdown_client(clone);
-		clone = ERR_PTR(-EIO);
+		clone = ERR_CAST(auth);
 	}
 
 	return clone;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5a7b372..f817587 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2356,17 +2356,10 @@ out:
 static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 				struct nfs_fsinfo *info, rpc_authflavor_t flavor)
 {
-	struct rpc_auth *auth;
-	int ret;
-
-	auth = rpcauth_create(flavor, server->client);
-	if (!auth) {
-		ret = -EIO;
-		goto out;
-	}
-	ret = nfs4_lookup_root(server, fhandle, info);
-out:
-	return ret;
+	struct rpc_auth *auth = rpcauth_create(flavor, server->client);
+	if (IS_ERR(auth))
+		return PTR_ERR(auth);
+	return nfs4_lookup_root(server, fhandle, info);
 }
 
 static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
-- 
1.7.11.1

