From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/7] SUNRPC: Use correct XDR encoding procedure for rpcbind
	SET/UNSET
Date: Mon, 30 Jun 2008 18:38:43 -0400
Message-ID: <20080630223842.24534.6852.stgit@ellison.1015granger.net>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:11464 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932666AbYF3WkB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:40:01 -0400
In-Reply-To: <20080630223646.24534.74654.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpcbind versions 3 and 4 SET and UNSET procedures use the same
arguments as the GETADDR procedure.

While definitely a bug, this hasn't been a problem so far since the
kernel hasn't used version 3 or 4 SET and UNSET.  But this will change
in just a moment.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)


diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 2b3a013..756e4f0 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -425,6 +425,10 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
 	rpcb_wake_rpcbind_waiters(xprt, status);
 }
 
+/*
+ * XDR functions for rpcbind
+ */
+
 static int rpcb_encode_mapping(struct rpc_rqst *req, __be32 *p,
 			       struct rpcbind_args *rpcb)
 {
@@ -580,14 +584,14 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 };
 
 static struct rpc_procinfo rpcb_procedures3[] = {
-	PROC(SET,		mapping,	set),
-	PROC(UNSET,		mapping,	set),
+	PROC(SET,		getaddr,	set),
+	PROC(UNSET,		getaddr,	set),
 	PROC(GETADDR,		getaddr,	getaddr),
 };
 
 static struct rpc_procinfo rpcb_procedures4[] = {
-	PROC(SET,		mapping,	set),
-	PROC(UNSET,		mapping,	set),
+	PROC(SET,		getaddr,	set),
+	PROC(UNSET,		getaddr,	set),
 	PROC(GETADDR,		getaddr,	getaddr),
 	PROC(GETVERSADDR,	getaddr,	getaddr),
 };

