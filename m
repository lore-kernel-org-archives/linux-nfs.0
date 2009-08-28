From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: SUNRPC: Fix rpc_task_force_reencode
Date: Fri, 28 Aug 2009 11:12:12 -0400
Message-ID: <1251472332.4844.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	stable <stable@kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2909 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751513AbZH1PNX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Aug 2009 11:13:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch fixes the bug that was reported in
  http://bugzilla.kernel.org/show_bug.cgi?id=14053

If we're in the case where we need to force a reencode and then resend of
the RPC request, due to xprt_transmit failing with a networking error, then
we _must_ retransmit the entire request.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
Please apply to mainline and stable

 net/sunrpc/clnt.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c1e467e..fac0ca9 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -955,6 +955,7 @@ static inline void
 rpc_task_force_reencode(struct rpc_task *task)
 {
 	task->tk_rqstp->rq_snd_buf.len = 0;
+	task->tk_rqstp->rq_bytes_sent = 0;
 }
 
 static inline void

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
