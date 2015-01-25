Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:55551 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbAYASv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 19:18:51 -0500
Received: by mail-ie0-f169.google.com with SMTP id rl12so3372119iec.0
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 16:18:50 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Allow waiting on memory allocation
Date: Sat, 24 Jan 2015 19:18:47 -0500
Message-Id: <1422145127-81838-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1422145127-81838-1-git-send-email-trond.myklebust@primarydata.com>
References: <1422145127-81838-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should be safe now, as long as we don't do GFP_IO or higher allocations

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/sched.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 4f65ec28d2b4..b91fd9c597b4 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -844,10 +844,10 @@ static void rpc_async_schedule(struct work_struct *work)
 void *rpc_malloc(struct rpc_task *task, size_t size)
 {
 	struct rpc_buffer *buf;
-	gfp_t gfp = GFP_NOWAIT | __GFP_NOWARN;
+	gfp_t gfp = GFP_NOIO | __GFP_NOWARN;
 
 	if (RPC_IS_SWAPPER(task))
-		gfp |= __GFP_MEMALLOC;
+		gfp = __GFP_MEMALLOC | GFP_NOWAIT | __GFP_NOWARN;
 
 	size += sizeof(struct rpc_buffer);
 	if (size <= RPC_BUFFER_MAXSIZE)
-- 
2.1.0

