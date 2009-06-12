From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 10/14] SQUASHME: nfs41: sunrpc: Don't skip past the RPC call direction
Date: Thu, 11 Jun 2009 22:54:16 -0700
Message-ID: <1244786060-2200-11-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-6-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-7-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-8-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-9-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-10-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39089 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753559AbZFLF6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:11 -0400
In-Reply-To: <1244786060-2200-10-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[squash with: nfs41: Skippast the RPC call direction]

xs_tcp_read_data() has been modified to include the RPC call direction in the
XDR buffer.  We need to read the direction during the header verification.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 net/sunrpc/clnt.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e7fffd2..d5a85a9 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1507,12 +1507,12 @@ rpc_verify_header(struct rpc_task *task)
 	if ((len -= 3) < 0)
 		goto out_overflow;
 
-	/*
-	 * Skip the XID and call direction.
-	 * The underlying transport has read the XID and RPC call direction
-	 * to determine this is an RPC reply.
-	 */
-	p += 2;
+	p += 1; /* skip XID */
+	if ((n = ntohl(*p++)) != RPC_REPLY) {
+		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
+			task->tk_pid, __func__, n);
+		goto out_garbage;
+	}
 
 	if ((n = ntohl(*p++)) != RPC_MSG_ACCEPTED) {
 		if (--len < 0)
-- 
1.5.4.3

