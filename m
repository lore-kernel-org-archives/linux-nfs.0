From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/11] SUNRPC: soft connect semantics for UDP
Date: Thu, 05 Nov 2009 13:23:49 -0500
Message-ID: <20091105182349.2796.65732.stgit@matisse.1015granger.net>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:43344
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758211AbZKESXv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2009 13:23:51 -0500
In-Reply-To: <20091105181924.2796.9313.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce soft connect behavior for UDP transports.  In this case, a
major timeout returns ETIMEDOUT instead of EIO.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 97931d9..154034b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1380,6 +1380,10 @@ call_timeout(struct rpc_task *task)
 	dprintk("RPC: %5u call_timeout (major)\n", task->tk_pid);
 	task->tk_timeouts++;
 
+	if (RPC_IS_SOFTCONN(task)) {
+		rpc_exit(task, -ETIMEDOUT);
+		return;
+	}
 	if (RPC_IS_SOFT(task)) {
 		if (clnt->cl_chatty)
 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",

