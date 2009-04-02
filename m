From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 50/67] nfs41: enable nfs_client only nfs4_async_handle_error
Date: Thu,  2 Apr 2009 16:57:49 +0300
Message-ID: <1238680669-14965-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:3423 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756742AbZDBN6e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:58:34 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The session is per struct nfs_client, not per nfs_server. Allow the handler
to be called with no nfs_server which simplifies the nfs4_proc_async_sequence session renewal call and will let it be used by pnfs file layout data servers.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 27b00c0..c03d775 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3224,10 +3224,8 @@ static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen
 }
 
 static int
-nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
+_nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs_client *clp, struct nfs4_state *state)
 {
-	struct nfs_client *clp = server->nfs_client;
-
 	if (!clp || task->tk_status >= 0)
 		return 0;
 	switch(task->tk_status) {
@@ -3247,7 +3245,8 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			task->tk_status = 0;
 			return -EAGAIN;
 		case -NFS4ERR_DELAY:
-			nfs_inc_server_stats(server, NFSIOS_DELAY);
+			if (server)
+				nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
 			task->tk_status = 0;
@@ -3260,6 +3259,12 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 	return 0;
 }
 
+static int
+nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
+{
+	return _nfs4_async_handle_error(task, server, server->nfs_client, state);
+}
+
 int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short port, struct rpc_cred *cred)
 {
 	nfs4_verifier sc_verifier;
-- 
1.6.2.1

