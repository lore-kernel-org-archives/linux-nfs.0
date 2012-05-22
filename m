Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:41181 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755626Ab2EVCpB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 22:45:01 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so4992272ggl.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 19:45:01 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/14] NFS: Clean up return code checking in
 nfs4_proc_exchange_id()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 21 May 2012 22:44:58 -0400
Message-ID: <20120522024458.1787.92404.stgit@degas.1015granger.net>
In-Reply-To: <20120522022702.1787.45940.stgit@degas.1015granger.net>
References: <20120522022702.1787.45940.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: update to use matching types in "if" expressions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e182134..0b9b55c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5102,30 +5102,30 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 
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
+	if (status == 0)
 		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
 
-	if (!status) {
+	if (status == 0) {
 		/* use the most recent implementation id */
 		kfree(clp->cl_implid);
 		clp->cl_implid = res.impl_id;
 	} else
 		kfree(res.impl_id);
 
-	if (!status) {
-		if (clp->cl_serverscope &&
+	if (status == 0) {
+		if (clp->cl_serverscope != NULL &&
 		    !nfs41_same_server_scope(clp->cl_serverscope,
 					     res.server_scope)) {
 			dprintk("%s: server_scope mismatch detected\n",
@@ -5135,7 +5135,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 			clp->cl_serverscope = NULL;
 		}
 
-		if (!clp->cl_serverscope) {
+		if (clp->cl_serverscope == NULL) {
 			clp->cl_serverscope = res.server_scope;
 			goto out;
 		}
@@ -5144,7 +5144,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 out_server_scope:
 	kfree(res.server_scope);
 out:
-	if (clp->cl_implid)
+	if (clp->cl_implid != NULL)
 		dprintk("%s: Server Implementation ID: "
 			"domain: %s, name: %s, date: %llu,%u\n",
 			__func__, clp->cl_implid->domain, clp->cl_implid->name,

