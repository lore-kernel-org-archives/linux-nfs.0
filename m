Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:33937 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757797Ab3DXU4J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2013 16:56:09 -0400
From: Dave Chiluk <chiluk@canonical.com>
To: Trond.Myklebust@netapp.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFSv4: Use exponential backoff delay for NFS4_ERRDELAY
Date: Wed, 24 Apr 2013 15:55:49 -0500
Message-Id: <1366836949-18465-1-git-send-email-chiluk@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changing the retry to start at NFS4_POLL_RETRY_MIN and exponentially grow
to NFS4_POLL_RETRY_MAX allow for faster handling of these error conditions.

Additionally this alleviates an interoperability problem with the AIX NFSv4
Server.  The AIX server frequently (2 out of 3) returns NFS4ERR_DELAY, on a
close when it happens in close proximity to a RELEASE_LOCKOWNER.  This would
cause a linux client to hang for 15 seconds.

Signed-off-by: Dave Chiluk <chiluk@canonical.com>
---
 fs/nfs/nfs4proc.c            |   12 ++++++++++++
 include/linux/sunrpc/sched.h |    1 +
 2 files changed, 13 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0ad025e..37dad27 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4006,6 +4006,18 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 #endif /* CONFIG_NFS_V4_1 */
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
+			/* Do an exponential backoff of retries from
+			 * NFS4_POLL_RETRY_MIN to NFS4_POLL_RETRY_MAX. */
+			task->tk_timeout = NFS4_POLL_RETRY_MIN <<
+					(task->tk_delays*2);
+			if (task->tk_timeout > NFS4_POLL_RETRY_MAX)
+				rpc_delay(task, NFS4_POLL_RETRY_MAX);
+			else {
+				task->tk_delays++;
+				rpc_delay(task, task->tk_timeout);
+			}
+			task->tk_status = 0;
+			return -EAGAIN;
 		case -NFS4ERR_GRACE:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
 			task->tk_status = 0;
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 84ca436..60f82bf 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -62,6 +62,7 @@ struct rpc_task {
 	void *			tk_calldata;
 
 	unsigned long		tk_timeout;	/* timeout for rpc_sleep() */
+	unsigned short		tk_delays;	/* number of times task delayed */
 	unsigned long		tk_runstate;	/* Task run status */
 	struct workqueue_struct	*tk_workqueue;	/* Normally rpciod, but could
 						 * be any workqueue
-- 
1.7.9.5

