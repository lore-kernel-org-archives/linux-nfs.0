Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51228 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755120Ab1ECUGr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2011 16:06:47 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv41: Resend on NFS4ERR_RETRY_UNCACHED_REP
Date: Mon,  2 May 2011 21:54:29 -0400
Message-Id: <1304387669-2969-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Free the slot and resend the RPC with new session <slot#,seq#>.

For nfs4_async_handle_error, return -EAGAIN and set the task->tk_status to 0
to restart the async rpc in the rpc_restart_call_prepare state which resets
the slot.

For nfs4_handle_exception, retrying a call that uses nfs4_call_sync will
reset the slot via nfs41_call_sync_prepare.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b8e1ac6..01d70dd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -300,6 +300,7 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			ret = nfs4_delay(server->client, &exception->timeout);
 			if (ret != 0)
 				break;
+		case -NFS4ERR_RETRY_UNCACHED_REP:
 		case -NFS4ERR_OLD_STATEID:
 			exception->retry = 1;
 			break;
@@ -3677,6 +3678,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
 			task->tk_status = 0;
 			return -EAGAIN;
+		case -NFS4ERR_RETRY_UNCACHED_REP:
 		case -NFS4ERR_OLD_STATEID:
 			task->tk_status = 0;
 			return -EAGAIN;
-- 
1.7.3.1

