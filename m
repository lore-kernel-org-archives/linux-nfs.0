Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:23040 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758908Ab3JQSNJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:13:09 -0400
Received: from ucsinet22.oracle.com (ucsinet22.oracle.com [156.151.31.94])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HID86Q013372
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:08 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HID7bV027125
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:08 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/21] NFS: Re-use exit code in nfs4_async_handle_error()
Date: Thu, 17 Oct 2013 14:13:07 -0400
Message-Id: <20131017181307.1073.97554.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f507e54..297bdd0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4757,19 +4757,15 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			dprintk("%s ERROR %d, Reset session\n", __func__,
 				task->tk_status);
 			nfs4_schedule_session_recovery(clp->cl_session, task->tk_status);
-			task->tk_status = 0;
-			return -EAGAIN;
+			goto restart_call;
 #endif /* CONFIG_NFS_V4_1 */
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
-			task->tk_status = 0;
-			return -EAGAIN;
 		case -NFS4ERR_RETRY_UNCACHED_REP:
 		case -NFS4ERR_OLD_STATEID:
-			task->tk_status = 0;
-			return -EAGAIN;
+			goto restart_call;
 	}
 	task->tk_status = nfs4_map_errors(task->tk_status);
 	return 0;
@@ -4780,6 +4776,7 @@ wait_on_recovery:
 	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
 		rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
+restart_call:
 	task->tk_status = 0;
 	return -EAGAIN;
 }

