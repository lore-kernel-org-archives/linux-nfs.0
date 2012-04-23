Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:61069 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017Ab2DWUxy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:53:54 -0400
Received: by ghrr11 with SMTP id r11so6481602ghr.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:53:53 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/20] NFS: Clean up return code checking in
 nfs4_proc_exchange_id()
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:53:50 -0400
Message-ID: <20120423205350.11446.78215.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: prefer using the proper types in "if" expressions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3778e4f..0af657d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5038,30 +5038,30 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 
 	res.server_scope = kzalloc(sizeof(struct nfs41_server_scope),
 					GFP_KERNEL);
-	if (unlikely(!res.server_scope)) {
+	if (unlikely(res.server_scope == NULL)) {
 		status = -ENOMEM;
 		goto out;
 	}
 
 	res.impl_id = kzalloc(sizeof(struct nfs41_impl_id), GFP_KERNEL);
-	if (unlikely(!res.impl_id)) {
+	if (unlikely(res.impl_id == NULL)) {
 		status = -ENOMEM;
 		goto out_server_scope;
 	}
 
 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
-	if (!status)
+	if (status == NFS4_OK)
 		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
 
-	if (!status) {
+	if (status == NFS4_OK) {
 		/* use the most recent implementation id */
 		kfree(clp->cl_implid);
 		clp->cl_implid = res.impl_id;
 	} else
 		kfree(res.impl_id);
 
-	if (!status) {
-		if (clp->cl_serverscope &&
+	if (status == NFS4_OK) {
+		if (clp->cl_serverscope != NULL &&
 		    !nfs41_same_server_scope(clp->cl_serverscope,
 					     res.server_scope)) {
 			dprintk("%s: server_scope mismatch detected\n",
@@ -5071,7 +5071,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 			clp->cl_serverscope = NULL;
 		}
 
-		if (!clp->cl_serverscope) {
+		if (clp->cl_serverscope == NULL) {
 			clp->cl_serverscope = res.server_scope;
 			goto out;
 		}
@@ -5080,7 +5080,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 out_server_scope:
 	kfree(res.server_scope);
 out:
-	if (clp->cl_implid)
+	if (clp->cl_implid != NULL)
 		dprintk("%s: Server Implementation ID: "
 			"domain: %s, name: %s, date: %llu,%u\n",
 			__func__, clp->cl_implid->domain, clp->cl_implid->name,

