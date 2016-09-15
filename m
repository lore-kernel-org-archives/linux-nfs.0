Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35998 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753998AbcIOQqT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 12:46:19 -0400
Received: by mail-it0-f66.google.com with SMTP id n143so5023489ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2016 09:46:19 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v4 12/20] NFSv4.1: Ensure we call FREE_STATEID if needed on close/delegreturn/locku
Date: Thu, 15 Sep 2016 12:45:52 -0400
Message-Id: <1473957960-10001-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473957960-10001-12-git-send-email-trond.myklebust@primarydata.com>
References: <1473957960-10001-1-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-2-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-3-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-4-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-5-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-6-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-7-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-8-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-9-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-10-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-11-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-12-git-send-email-trond.myklebust@primarydata.com>
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

