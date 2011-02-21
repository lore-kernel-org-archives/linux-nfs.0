Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47174 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921Ab1BUWaK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 17:30:10 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/9] pnfsd: do not clear rpc_resp in nfsd4_cb_done_sequence
Date: Mon, 21 Feb 2011 14:30:06 -0800
Message-Id: <1298327406-7544-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D62E6F3.8000304@panasas.com>
References: <4D62E6F3.8000304@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is not needed anymore and is causes bug on the retry path
after getting NFS4ERR_DELAY when nfs4_xdr_dec_cb_layout sees cb == NULL

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 8351f67..3fb989a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -876,9 +876,6 @@ static void nfsd4_cb_done_sequence(struct rpc_task *task,
 		rpc_wake_up_next(&clp->cl_cb_waitq);
 		dprintk("%s: freed slot, new seqid=%d\n", __func__,
 			clp->cl_cb_session->se_cb_seq_nr);
-
-		/* We're done looking into the sequence information */
-		task->tk_msg.rpc_resp = NULL;
 	}
 }
 
-- 
1.7.3.4

