Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:55553 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbAYASu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 19:18:50 -0500
Received: by mail-ig0-f181.google.com with SMTP id hn18so3209380igb.2
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 16:18:49 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Adjust rpciod workqueue parameters
Date: Sat, 24 Jan 2015 19:18:46 -0500
Message-Id: <1422145127-81838-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Increase the concurrency level for rpciod threads to allow for allocations
etc that happen in the RPCSEC_GSS layer. Also note that the NFSv4 byte range
locks may now need to allocate memory from inside rpciod.

Add the WQ_HIGHPRI flag to improve latency guarantees while we're at it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/sched.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index d20f2329eea3..4f65ec28d2b4 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1069,7 +1069,8 @@ static int rpciod_start(void)
 	 * Create the rpciod thread and wait for it to start.
 	 */
 	dprintk("RPC:       creating workqueue rpciod\n");
-	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 1);
+	/* Note: highpri because network receive is latency sensitive */
+	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_HIGHPRI, 0);
 	rpciod_workqueue = wq;
 	return rpciod_workqueue != NULL;
 }
-- 
2.1.0

