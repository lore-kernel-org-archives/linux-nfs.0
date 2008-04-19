From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/33] SUNRPC: Don't attempt to destroy expired RPCSEC_GSS
	credentials..
Date: Sat, 19 Apr 2008 16:40:48 -0400
Message-ID: <20080419204047.14124.64969.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35010 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756077AbYDSUuX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:23 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoN9f002605
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:23 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

..and always destroy using a 'soft' RPC call. Destroying GSS credentials
isn't mandatory; the server can always cope with a few credentials not
getting destroyed in a timely fashion.

This actually fixes a hang situation. Basically, some servers will decide
that the client is crazy if it tries to destroy an RPC context for which
they have sent an RPCSEC_GSS_CREDPROBLEM, and so will refuse to talk to it
for a while.
The regression therefor probably was introduced by commit
0df7fb74fbb709591301871a38aac7735a1d6583.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index d34f6df..55948cd 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -710,7 +710,7 @@ gss_destroying_context(struct rpc_cred *cred)
 	struct rpc_task *task;
 
 	if (gss_cred->gc_ctx == NULL ||
-			gss_cred->gc_ctx->gc_proc == RPC_GSS_PROC_DESTROY)
+	    test_and_clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) == 0)
 		return 0;
 
 	gss_cred->gc_ctx->gc_proc = RPC_GSS_PROC_DESTROY;
@@ -720,7 +720,7 @@ gss_destroying_context(struct rpc_cred *cred)
 	 * by the RPC call or by the put_rpccred() below */
 	get_rpccred(cred);
 
-	task = rpc_call_null(gss_auth->client, cred, RPC_TASK_ASYNC);
+	task = rpc_call_null(gss_auth->client, cred, RPC_TASK_ASYNC|RPC_TASK_SOFT);
 	if (!IS_ERR(task))
 		rpc_put_task(task);
 

