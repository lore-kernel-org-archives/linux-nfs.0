Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35011 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753999AbcITQ4h (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 12:56:37 -0400
Received: by mail-qk0-f195.google.com with SMTP id w204so1432365qka.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 09:56:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v6 15/29] NFSv4.1: Ensure we call FREE_STATEID if needed on close/delegreturn/locku
Date: Tue, 20 Sep 2016 12:55:57 -0400
Message-Id: <1474390571-17106-16-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474390571-17106-15-git-send-email-trond.myklebust@primarydata.com>
References: <1474390571-17106-1-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-2-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-3-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-4-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-5-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-6-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-7-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-8-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-9-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-10-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-11-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-12-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-13-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-14-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-15-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a server returns NFS4ERR_ADMIN_REVOKED, NFS4ERR_DELEG_REVOKED
or NFS4ERR_EXPIRED on a call to close, open_downgrade, delegreturn, or
locku, we should call FREE_STATEID before attempting to recover.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 43 ++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 40 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a53caeb73f75..f79d4f55d83f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -328,6 +328,33 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 	kunmap_atomic(start);
 }
 
+static void nfs4_test_and_free_stateid(struct nfs_server *server,
+		nfs4_stateid *stateid,
+		struct rpc_cred *cred)
+{
+	const struct nfs4_minor_version_ops *ops = server->nfs_client->cl_mvops;
+
+	ops->test_and_free_expired(server, stateid, cred);
+}
+
+static void __nfs4_free_revoked_stateid(struct nfs_server *server,
+		nfs4_stateid *stateid,
+		struct rpc_cred *cred)
+{
+	stateid->type = NFS4_REVOKED_STATEID_TYPE;
+	nfs4_test_and_free_stateid(server, stateid, cred);
+}
+
+static void nfs4_free_revoked_stateid(struct nfs_server *server,
+		const nfs4_stateid *stateid,
+		struct rpc_cred *cred)
+{
+	nfs4_stateid tmp;
+
+	nfs4_stateid_copy(&tmp, stateid);
+	__nfs4_free_revoked_stateid(server, &tmp, cred);
+}
+
 static long nfs4_update_delay(long *timeout)
 {
 	long ret;
@@ -2983,9 +3010,12 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			break;
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_STALE_STATEID:
+		case -NFS4ERR_EXPIRED:
+			nfs4_free_revoked_stateid(server,
+					&calldata->arg.stateid,
+					task->tk_msg.rpc_cred);
 		case -NFS4ERR_OLD_STATEID:
 		case -NFS4ERR_BAD_STATEID:
-		case -NFS4ERR_EXPIRED:
 			if (!nfs4_stateid_match(&calldata->arg.stateid,
 						&state->open_stateid)) {
 				rpc_restart_call_prepare(task);
@@ -5477,10 +5507,13 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		renew_lease(data->res.server, data->timestamp);
 	case -NFS4ERR_ADMIN_REVOKED:
 	case -NFS4ERR_DELEG_REVOKED:
+	case -NFS4ERR_EXPIRED:
+		nfs4_free_revoked_stateid(data->res.server,
+				data->args.stateid,
+				task->tk_msg.rpc_cred);
 	case -NFS4ERR_BAD_STATEID:
 	case -NFS4ERR_OLD_STATEID:
 	case -NFS4ERR_STALE_STATEID:
-	case -NFS4ERR_EXPIRED:
 		task->tk_status = 0;
 		if (data->roc)
 			pnfs_roc_set_barrier(data->inode, data->roc_barrier);
@@ -5745,10 +5778,14 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 			if (nfs4_update_lock_stateid(calldata->lsp,
 					&calldata->res.stateid))
 				break;
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_EXPIRED:
+			nfs4_free_revoked_stateid(calldata->server,
+					&calldata->arg.stateid,
+					task->tk_msg.rpc_cred);
 		case -NFS4ERR_BAD_STATEID:
 		case -NFS4ERR_OLD_STATEID:
 		case -NFS4ERR_STALE_STATEID:
-		case -NFS4ERR_EXPIRED:
 			if (!nfs4_stateid_match(&calldata->arg.stateid,
 						&calldata->lsp->ls_stateid))
 				rpc_restart_call_prepare(task);
-- 
2.7.4

