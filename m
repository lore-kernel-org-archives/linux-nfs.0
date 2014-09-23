Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:58825 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352AbaIWG4a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 02:56:30 -0400
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@primarydata.com>, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] nfsd: do not clear rpc_resp in nfsd4_cb_done_sequence
Date: Tue, 23 Sep 2014 08:58:49 +0200
Message-Id: <1411455529-11556-3-git-send-email-hch@lst.de>
In-Reply-To: <1411455529-11556-1-git-send-email-hch@lst.de>
References: <1411455529-11556-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

This is incorrect when a callback is has to be restarted, in which case
the XDR decoding of the second iteration will see a NULL cb argument.

[hch: updated description]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 795e218..fc07084 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -847,9 +847,6 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 		rpc_wake_up_next(&clp->cl_cb_waitq);
 		dprintk("%s: freed slot, new seqid=%d\n", __func__,
 			clp->cl_cb_session->se_cb_seq_nr);
-
-		/* We're done looking into the sequence information */
-		task->tk_msg.rpc_resp = NULL;
 	}
 }
 
-- 
1.9.1

