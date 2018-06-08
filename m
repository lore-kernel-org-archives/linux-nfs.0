Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34304 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbeFHTb5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2018 15:31:57 -0400
Received: by mail-io0-f196.google.com with SMTP id e15-v6so17170315iog.1
        for <linux-nfs@vger.kernel.org>; Fri, 08 Jun 2018 12:31:57 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (50-36-175-81.alma.mi.frontiernet.net. [50.36.175.81])
        by smtp.gmail.com with ESMTPSA id k8-v6sm9082821ioj.55.2018.06.08.12.31.56
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Jun 2018 12:31:56 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Return NFS4ERR_DELAY when a delegation recall fails due to igrab()
Date: Fri,  8 Jun 2018 15:31:33 -0400
Message-Id: <20180608193134.27090-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the attempt to recall the delegation fails because the inode is
in the process of being evicted from cache, then use NFS4ERR_DELAY
to ask the server to retry later.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/callback_proc.c |  8 ++++++--
 fs/nfs/delegation.c    | 16 +++++++++-------
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index d561161b7c3e..407b2d05579f 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -40,7 +40,9 @@ __be32 nfs4_callback_getattr(void *argp, void *resp,
 		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
 	inode = nfs_delegation_find_inode(cps->clp, &args->fh);
-	if (inode == NULL) {
+	if (IS_ERR(inode)) {
+		if (inode == PTR_ERR(-EAGAIN))
+			res->status = htonl(NFS4ERR_DELAY);
 		trace_nfs4_cb_getattr(cps->clp, &args->fh, NULL,
 				-ntohl(res->status));
 		goto out;
@@ -86,7 +88,9 @@ __be32 nfs4_callback_recall(void *argp, void *resp,
 
 	res = htonl(NFS4ERR_BADHANDLE);
 	inode = nfs_delegation_find_inode(cps->clp, &args->fh);
-	if (inode == NULL) {
+	if (IS_ERR(inode)) {
+		if (inode == PTR_ERR(-EAGAIN))
+			res = htonl(NFS4ERR_DELAY);
 		trace_nfs4_cb_recall(cps->clp, &args->fh, NULL,
 				&args->stateid, -ntohl(res));
 		goto out;
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 91c3737d69df..4b845d2fdb81 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -849,19 +849,21 @@ nfs_delegation_find_inode_server(struct nfs_server *server,
 				 const struct nfs_fh *fhandle)
 {
 	struct nfs_delegation *delegation;
-	struct inode *res = NULL;
+	struct inode *res;
 
 	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
 		spin_lock(&delegation->lock);
 		if (delegation->inode != NULL &&
 		    nfs_compare_fh(fhandle, &NFS_I(delegation->inode)->fh) == 0) {
 			res = igrab(delegation->inode);
+			if (res == NULL)
+				res = ERR_PTR(-EAGAIN);
 		}
 		spin_unlock(&delegation->lock);
 		if (res != NULL)
-			break;
+			return res;
 	}
-	return res;
+	return ERR_PTR(-ENOENT);
 }
 
 /**
@@ -876,16 +878,16 @@ struct inode *nfs_delegation_find_inode(struct nfs_client *clp,
 					const struct nfs_fh *fhandle)
 {
 	struct nfs_server *server;
-	struct inode *res = NULL;
+	struct inode *res;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		res = nfs_delegation_find_inode_server(server, fhandle);
-		if (res != NULL)
-			break;
+		if (res != ERR_PTR(-ENOENT))
+			return res;
 	}
 	rcu_read_unlock();
-	return res;
+	return ERR_PTR(-ENOENT);
 }
 
 static void nfs_delegation_mark_reclaim_server(struct nfs_server *server)
-- 
2.17.1

