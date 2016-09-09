Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36208 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754302AbcIISE4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2016 14:04:56 -0400
Received: by mail-oi0-f66.google.com with SMTP id s71so8338670oih.3
        for <linux-nfs@vger.kernel.org>; Fri, 09 Sep 2016 11:04:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v3 12/12] NFSv4.1: Ensure we call FREE_STATEID if needed on close/delegreturn/locku
Date: Fri,  9 Sep 2016 14:04:13 -0400
Message-Id: <1473444253-12433-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473444253-12433-12-git-send-email-trond.myklebust@primarydata.com>
References: <1473444253-12433-1-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-2-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-3-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-4-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-5-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-6-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-7-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-8-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-9-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-10-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-11-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a server returns NFS4ERR_ADMIN_REVOKED, NFS4ERR_DELEG_REVOKED
or NFS4ERR_EXPIRED on a call to close, open_downgrade, delegreturn, or
locku, we should call FREE_STATEID before attempting to recover.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 28 +++++++++++++++++++++++++---
 1 file changed, 25 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5442e0e1de14..ffb3218a4a00 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -328,6 +328,18 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 	kunmap_atomic(start);
 }
 
+static void nfs4_free_revoked_stateid(struct nfs_server *server,
+		const nfs4_stateid *stateid,
+		struct rpc_cred *cred)
+{
+	const struct nfs4_minor_version_ops *ops = server->nfs_client->cl_mvops;
+	nfs4_stateid tmp;
+
+	nfs4_stateid_copy(&tmp, stateid);
+	tmp.type = NFS4_REVOKED_STATEID_TYPE;
+	ops->test_and_free_expired(server, &tmp, cred);
+}
+
 static long nfs4_update_delay(long *timeout)
 {
 	long ret;
@@ -2983,9 +2995,12 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
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
@@ -5477,10 +5492,13 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
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
@@ -5745,10 +5763,14 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
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

