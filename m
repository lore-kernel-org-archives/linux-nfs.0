Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f53.google.com ([209.85.213.53]:51638 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968232Ab3HIQv2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:51:28 -0400
Received: by mail-yh0-f53.google.com with SMTP id v1so1515015yhn.26
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:51:27 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id s29sm20698018yhf.6.2013.08.09.09.51.26
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:51:27 -0700 (PDT)
Subject: [PATCH v2 25/33] NFS: Re-use exit code in nfs4_async_handle_error()
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:51:26 -0400
Message-ID: <20130809165126.5362.83522.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
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
index 3e9b8a3..4cc5181 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4675,19 +4675,15 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
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
@@ -4698,6 +4694,7 @@ wait_on_recovery:
 	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
 		rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
+restart_call:
 	task->tk_status = 0;
 	return -EAGAIN;
 }

