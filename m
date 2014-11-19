Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:44120 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658AbaKSRr5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 12:47:57 -0500
Received: by mail-pd0-f170.google.com with SMTP id fp1so1289131pdb.29
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 09:47:57 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: Fix slot wake up race in the nfsv4.1 callback code
Date: Wed, 19 Nov 2014 12:47:50 -0500
Message-Id: <1416419270-8964-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The currect code for nfsd41_cb_get_slot() and nfsd4_cb_done() has no
locking in order to guarantee atomicity, and so allows for races of
the form.

Task 1                                  Task 2
======                                  ======
if (test_and_set_bit(0) != 0) {
                                        clear_bit(0)
                                        rpc_wake_up_next(queue)
        rpc_sleep_on(queue)
        return false;
}

This patch breaks the race condition by adding a retest of the bit
after the call to rpc_sleep_on().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org
---
 fs/nfsd/nfs4callback.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index ed2b1151b171..7cbdf1b2e4ab 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -774,8 +774,12 @@ static bool nfsd41_cb_get_slot(struct nfs4_client *clp, struct rpc_task *task)
 {
 	if (test_and_set_bit(0, &clp->cl_cb_slot_busy) != 0) {
 		rpc_sleep_on(&clp->cl_cb_waitq, task, NULL);
-		dprintk("%s slot is busy\n", __func__);
-		return false;
+		/* Race breaker */
+		if (test_and_set_bit(0, &clp->cl_cb_slot_busy) != 0) {
+			dprintk("%s slot is busy\n", __func__);
+			return false;
+		}
+		rpc_wake_up_queued_task(&clp->cl_cb_waitq, task);
 	}
 	return true;
 }
-- 
1.9.3

