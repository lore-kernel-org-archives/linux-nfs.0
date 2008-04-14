From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/24] SUNRPC: Use correct XDR encoding procedure for rpcbind
	SET/UNSET
Date: Mon, 14 Apr 2008 12:28:22 -0400
Message-ID: <20080414162821.12741.28036.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:40522 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760424AbYDNRBK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 13:01:10 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpcbind versions 3 and 4 SET and UNSET procedures use the same
arguments as the GETADDR procedure.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index d852b2e..18e677c 100644
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
 	PROC(GETVERSADDR,	getaddr,	getaddr),
 };
 

