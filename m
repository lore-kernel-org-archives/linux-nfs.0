Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34485 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAXDzh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2017 22:55:37 -0500
Received: by mail-it0-f67.google.com with SMTP id o185so12571361itb.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2017 19:55:37 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Fix a deadlock in layoutget
Date: Mon, 23 Jan 2017 22:55:33 -0500
Message-Id: <20170124035533.11212-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We cannot call nfs4_handle_exception() without first ensuring that the
slot has been freed. If not, we end up deadlocking with the process
waiting for recovery to complete, and recovery waiting for the slot
table to drain.

Fixes: 2e80dbe7ac51 ("NFSv4.1: Close callback races for OPEN, LAYOUTGET...")
Cc: stable@vger.kernel.org # v4.8+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ecc151697fd4..59bb574d7d7c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8490,6 +8490,7 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 		goto out;
 	}
 
+	nfs4_sequence_free_slot(&lgp->res.seq_res);
 	err = nfs4_handle_exception(server, nfs4err, exception);
 	if (!status) {
 		if (exception->retry)
-- 
2.9.3

