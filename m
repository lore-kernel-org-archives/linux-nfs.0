From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/10] SUNRPC: Eliminate PROC macro from rpcb_clnt
Date: Wed, 15 Jul 2009 17:42:31 -0400
Message-ID: <20090715214231.7883.9989.stgit@matisse.1015granger.net>
References: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:60990
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754614AbZGOVme (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:42:34 -0400
In-Reply-To: <20090715213842.7883.48947.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Replace PROC macro with open coded C99 structure
initializers to improve readability.

The rpcbind v4 GETVERSADDR procedure is never sent by the current
implementation, so it is not copied to the new structures.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |  113 +++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 91 insertions(+), 22 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 627d281..4cc2c58 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -924,39 +924,108 @@ out_fail:
 	return -EIO;
 }
 
-#define PROC(proc, argtype, restype)					\
-	[RPCBPROC_##proc] = {						\
-		.p_proc		= RPCBPROC_##proc,			\
-		.p_encode	= (kxdrproc_t) rpcb_enc_##argtype,	\
-		.p_decode	= (kxdrproc_t) rpcb_dec_##restype,	\
-		.p_arglen	= RPCB_##argtype##args_sz,		\
-		.p_replen	= RPCB_##restype##res_sz,		\
-		.p_statidx	= RPCBPROC_##proc,			\
-		.p_timer	= 0,					\
-		.p_name		= #proc,				\
-	}
-
 /*
  * Not all rpcbind procedures described in RFC 1833 are implemented
  * since the Linux kernel RPC code requires only these.
  */
+
 static struct rpc_procinfo rpcb_procedures2[] = {
-	PROC(SET,		mapping,	set),
-	PROC(UNSET,		mapping,	set),
-	PROC(GETPORT,		mapping,	getport),
+	[RPCBPROC_SET] = {
+		.p_proc		= RPCBPROC_SET,
+		.p_encode	= (kxdrproc_t)rpcb_enc_mapping,
+		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_arglen	= RPCB_mappingargs_sz,
+		.p_replen	= RPCB_setres_sz,
+		.p_statidx	= RPCBPROC_SET,
+		.p_timer	= 0,
+		.p_name		= "SET",
+	},
+	[RPCBPROC_UNSET] = {
+		.p_proc		= RPCBPROC_UNSET,
+		.p_encode	= (kxdrproc_t)rpcb_enc_mapping,
+		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_arglen	= RPCB_mappingargs_sz,
+		.p_replen	= RPCB_setres_sz,
+		.p_statidx	= RPCBPROC_UNSET,
+		.p_timer	= 0,
+		.p_name		= "UNSET",
+	},
+	[RPCBPROC_GETPORT] = {
+		.p_proc		= RPCBPROC_GETPORT,
+		.p_encode	= (kxdrproc_t)rpcb_enc_mapping,
+		.p_decode	= (kxdrproc_t)rpcb_dec_getport,
+		.p_arglen	= RPCB_mappingargs_sz,
+		.p_replen	= RPCB_getportres_sz,
+		.p_statidx	= RPCBPROC_GETPORT,
+		.p_timer	= 0,
+		.p_name		= "GETPORT",
+	},
 };
 
 static struct rpc_procinfo rpcb_procedures3[] = {
-	PROC(SET,		getaddr,	set),
-	PROC(UNSET,		getaddr,	set),
-	PROC(GETADDR,		getaddr,	getaddr),
+	[RPCBPROC_SET] = {
+		.p_proc		= RPCBPROC_SET,
+		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_arglen	= RPCB_getaddrargs_sz,
+		.p_replen	= RPCB_setres_sz,
+		.p_statidx	= RPCBPROC_SET,
+		.p_timer	= 0,
+		.p_name		= "SET",
+	},
+	[RPCBPROC_UNSET] = {
+		.p_proc		= RPCBPROC_UNSET,
+		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_arglen	= RPCB_getaddrargs_sz,
+		.p_replen	= RPCB_setres_sz,
+		.p_statidx	= RPCBPROC_UNSET,
+		.p_timer	= 0,
+		.p_name		= "UNSET",
+	},
+	[RPCBPROC_GETADDR] = {
+		.p_proc		= RPCBPROC_GETADDR,
+		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_decode	= (kxdrproc_t)rpcb_dec_getaddr,
+		.p_arglen	= RPCB_getaddrargs_sz,
+		.p_replen	= RPCB_getaddrres_sz,
+		.p_statidx	= RPCBPROC_GETADDR,
+		.p_timer	= 0,
+		.p_name		= "GETADDR",
+	},
 };
 
 static struct rpc_procinfo rpcb_procedures4[] = {
-	PROC(SET,		getaddr,	set),
-	PROC(UNSET,		getaddr,	set),
-	PROC(GETADDR,		getaddr,	getaddr),
-	PROC(GETVERSADDR,	getaddr,	getaddr),
+	[RPCBPROC_SET] = {
+		.p_proc		= RPCBPROC_SET,
+		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_arglen	= RPCB_getaddrargs_sz,
+		.p_replen	= RPCB_setres_sz,
+		.p_statidx	= RPCBPROC_SET,
+		.p_timer	= 0,
+		.p_name		= "SET",
+	},
+	[RPCBPROC_UNSET] = {
+		.p_proc		= RPCBPROC_UNSET,
+		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_decode	= (kxdrproc_t)rpcb_dec_set,
+		.p_arglen	= RPCB_getaddrargs_sz,
+		.p_replen	= RPCB_setres_sz,
+		.p_statidx	= RPCBPROC_UNSET,
+		.p_timer	= 0,
+		.p_name		= "UNSET",
+	},
+	[RPCBPROC_GETADDR] = {
+		.p_proc		= RPCBPROC_GETADDR,
+		.p_encode	= (kxdrproc_t)rpcb_enc_getaddr,
+		.p_decode	= (kxdrproc_t)rpcb_dec_getaddr,
+		.p_arglen	= RPCB_getaddrargs_sz,
+		.p_replen	= RPCB_getaddrres_sz,
+		.p_statidx	= RPCBPROC_GETADDR,
+		.p_timer	= 0,
+		.p_name		= "GETADDR",
+	},
 };
 
 static struct rpcb_info rpcb_next_version[] = {

