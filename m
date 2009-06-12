From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 06/14] SQUASHME: Remove unnecessary BUG_ON()
Date: Thu, 11 Jun 2009 22:54:12 -0700
Message-ID: <1244786060-2200-7-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-6-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2056 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753108AbZFLF6K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:10 -0400
In-Reply-To: <1244786060-2200-6-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It was useful during early development, no longer necessary.

[squash with: nfs41: Add backchannel processing support to RPC state machine]

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 net/sunrpc/xprt.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 2b189af..a8c6e8c 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1004,7 +1004,6 @@ void xprt_release(struct rpc_task *task)
 	struct rpc_rqst	*req;
 	int prealloc;
 
-	BUG_ON(atomic_read(&task->tk_count) < 0);
 	if (!(req = task->tk_rqstp))
 		return;
 	prealloc = bc_prealloc(req);	/* Preallocated backchannel request? */
-- 
1.5.4.3

