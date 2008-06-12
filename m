From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/37] SUNRPC: An ENOMEM error from call_encode is always
	fatal
Date: Thu, 12 Jun 2008 15:22:00 -0400
Message-ID: <20080612192200.24528.71693.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754796AbYFLTd7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:33:59 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJXv7a001506
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:33:59 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The special 'ENOMEM' case that was previously flagged as non-fatal is
bogus: auth_gss always returns EAGAIN for non-fatal errors, and may in fact
return ENOMEM in the special case where xdr_buf_read_netobj runs out of
preallocated buffer space (invariably a _fatal_ error, since there is no
provision for preallocating larger buffers).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9503b4c..1af4f16 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -888,10 +888,6 @@ call_encode(struct rpc_task *task)
 
 	task->tk_status = rpcauth_wrap_req(task, encode, req, p,
 			task->tk_msg.rpc_argp);
-	if (task->tk_status == -ENOMEM) {
-		/* XXX: Is this sane? */
-		task->tk_status = -EAGAIN;
-	}
 }
 
 /*

