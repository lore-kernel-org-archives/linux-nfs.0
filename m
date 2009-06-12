From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 04/14] SQUASHME: rpc_count_iostats incorrectly exits early
Date: Thu, 11 Jun 2009 22:54:10 -0700
Message-ID: <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39089 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752835AbZFLF6K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:10 -0400
In-Reply-To: <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's incorrectly taking an early exit if the tk_client has metrics.

[squash with: nfs41: Add backchannel processing support to RPC state machine]

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 net/sunrpc/stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index c1517e2..1b4e679 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -145,7 +145,7 @@ void rpc_count_iostats(struct rpc_task *task)
 	struct rpc_iostats *op_metrics;
 	long rtt, execute, queue;
 
-	if (!task->tk_client || task->tk_client->cl_metrics || !req)
+	if (!task->tk_client || !task->tk_client->cl_metrics || !req)
 		return;
 
 	stats = task->tk_client->cl_metrics;
-- 
1.5.4.3

