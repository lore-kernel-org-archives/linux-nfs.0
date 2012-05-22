Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15731 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759518Ab2EVQKV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 12:10:21 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/4] NFSv4.1 skip rpc_call_done only on disconnected DS slot_table_waitq tasks
Date: Tue, 22 May 2012 08:09:27 -0400
Message-Id: <1337688569-1515-3-git-send-email-andros@netapp.com>
In-Reply-To: <1337688569-1515-1-git-send-email-andros@netapp.com>
References: <1337688569-1515-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We reset all I/O on a disconnected data server through the pgio layer indicated
by the NFS_IOHDR_REDO flag.

Differentiate between on-the-wire tasks returning with an error which must
call rpc_call_done and tasks woken from the data server slot_table_waitq
waiting for a session slot with a status of zero which call rpc_exit in
rpc_prepare and need to skip rpc_call_done.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 8df91be..db6f2a6 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -302,7 +302,8 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 
 	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
 
-	if (test_bit(NFS_IOHDR_REDO, &rdata->header->flags))
+	if (test_bit(NFS_IOHDR_REDO, &rdata->header->flags) &&
+	    task->tk_status == 0)
 		return;
 
 	/* Note this may cause RPC to be resent */
@@ -399,7 +400,8 @@ static void filelayout_write_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_write_data *wdata = data;
 
-	if (test_bit(NFS_IOHDR_REDO, &wdata->header->flags))
+	if (test_bit(NFS_IOHDR_REDO, &wdata->header->flags) &&
+	    task->tk_status == 0)
 		return;
 
 	/* Note this may cause RPC to be resent */
-- 
1.7.7.6

