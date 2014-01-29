Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:34025 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbaA2Rg2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jan 2014 12:36:28 -0500
Received: by mail-ie0-f180.google.com with SMTP id at1so2288524iec.25
        for <linux-nfs@vger.kernel.org>; Wed, 29 Jan 2014 09:36:27 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 3/3] NFSv4.1: Cleanup
Date: Wed, 29 Jan 2014 12:36:22 -0500
Message-Id: <1391016982-10562-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1391016982-10562-2-git-send-email-trond.myklebust@primarydata.com>
References: <1391016982-10562-1-git-send-email-trond.myklebust@primarydata.com>
 <1391016982-10562-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is now completely safe to call nfs41_sequence_free_slot with a NULL
slot.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4filelayout.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 20a56fa271bd..12c8132ad408 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -336,8 +336,7 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 
 	if (test_bit(NFS_IOHDR_REDO, &rdata->header->flags) &&
 	    task->tk_status == 0) {
-		if (rdata->res.seq_res.sr_slot != NULL)
-			nfs41_sequence_done(task, &rdata->res.seq_res);
+		nfs41_sequence_done(task, &rdata->res.seq_res);
 		return;
 	}
 
@@ -446,8 +445,7 @@ static void filelayout_write_call_done(struct rpc_task *task, void *data)
 
 	if (test_bit(NFS_IOHDR_REDO, &wdata->header->flags) &&
 	    task->tk_status == 0) {
-		if (wdata->res.seq_res.sr_slot != NULL)
-			nfs41_sequence_done(task, &wdata->res.seq_res);
+		nfs41_sequence_done(task, &wdata->res.seq_res);
 		return;
 	}
 
-- 
1.8.5.3

