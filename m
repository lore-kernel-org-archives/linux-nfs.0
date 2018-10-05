Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:58050 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1728341AbeJEUkF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Oct 2018 16:40:05 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH RFC] nfs: make DELEGRETURN try harder to determine if a delegation has been revoked
Date: Fri,  5 Oct 2018 09:34:29 -0400
Message-Id: <20181005133429.79332-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible for DELEGRETURN to run into corner cases where a
delegation has been revoked by the server, but that fact is being
hidden by an error on the PUTFH/DELEGRETURN. So, in all error
cases where revoked status isn't immediately obvious, do a
TEST_STATEID to see if it is indeed revoked.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfs/nfs4proc.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8220a168282e..3f38d281a814 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -386,6 +386,16 @@ static void nfs4_free_revoked_stateid(struct nfs_server *server,
 	__nfs4_free_revoked_stateid(server, &tmp, cred);
 }
 
+static void nfs4_free_possibly_revoked_stateid(struct nfs_server *server,
+					const nfs4_stateid *stateid,
+					struct rpc_cred *cred)
+{
+	nfs4_stateid tmp;
+
+	nfs4_stateid_copy(&tmp, stateid);
+	nfs4_test_and_free_stateid(server, &tmp, cred);
+}
+
 static long nfs4_update_delay(long *timeout)
 {
 	long ret;
@@ -6035,9 +6045,13 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		nfs4_free_revoked_stateid(data->res.server,
 				data->args.stateid,
 				task->tk_msg.rpc_cred);
-		/* Fallthrough */
+		task->tk_status = 0;
+		break;
 	case -NFS4ERR_BAD_STATEID:
 	case -NFS4ERR_STALE_STATEID:
+		nfs4_free_possibly_revoked_stateid(data->res.server,
+						data->args.stateid,
+						task->tk_msg.rpc_cred);
 		task->tk_status = 0;
 		break;
 	case -NFS4ERR_OLD_STATEID:
@@ -6058,6 +6072,10 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 				&exception);
 		if (exception.retry)
 			goto out_restart;
+
+		nfs4_free_possibly_revoked_stateid(data->res.server,
+						data->args.stateid,
+						task->tk_msg.rpc_cred);
 	}
 	data->rpc_status = task->tk_status;
 	return;
-- 
1.8.3.1
