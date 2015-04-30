Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:51996 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbbD3Jur (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2015 05:50:47 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] nfsd: skip CB_NULL probes for 4.1 or later
Date: Thu, 30 Apr 2015 11:49:25 +0200
Message-Id: <1430387365-24348-4-git-send-email-hch@lst.de>
In-Reply-To: <1430387365-24348-1-git-send-email-hch@lst.de>
References: <1430387365-24348-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With sessions in v4.1 or later we don't need to manually probe the backchannel
connection, so we can declare it up instantly after setting up the RPC client.

Note that we really should split nfsd4_run_cb_work in the long run, this is
just the least intrusive fix for now.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 4c993aa..5694cfb 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1066,6 +1066,15 @@ nfsd4_run_cb_work(struct work_struct *work)
 			cb->cb_ops->release(cb);
 		return;
 	}
+
+	/*
+	 * Don't send probe messages for 4.1 or later.
+	 */
+	if (!cb->cb_ops && clp->cl_minorversion) {
+		clp->cl_cb_state = NFSD4_CB_UP;
+		return;
+	}
+
 	cb->cb_msg.rpc_cred = clp->cl_cb_cred;
 	rpc_call_async(clnt, &cb->cb_msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
 			cb->cb_ops ? &nfsd4_cb_ops : &nfsd4_cb_probe_ops, cb);
-- 
1.9.1

