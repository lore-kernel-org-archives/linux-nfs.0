From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/10] SUNRPC: Move XDR data type size macros
Date: Wed, 15 Jul 2009 17:37:02 -0400
Message-ID: <20090715213701.7582.46145.stgit@matisse.1015granger.net>
References: <20090715212628.7582.98251.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:38855
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752159AbZGOVhE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:37:04 -0400
In-Reply-To: <20090715212628.7582.98251.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: To make subsequent patches cleaner, move the XDR data type
size macros to the top of the file (similar to nfs4xdr.c) first.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   56 +++++++++++++++++++++++++++---------------------
 1 files changed, 31 insertions(+), 25 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index beee6da..ad1d731 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -75,6 +75,37 @@ enum {
 #define RPCB_OWNER_STRING	"0"
 #define RPCB_MAXOWNERLEN	sizeof(RPCB_OWNER_STRING)
 
+/*
+ * XDR data type sizes
+ */
+#define RPCB_program_sz		(1)
+#define RPCB_version_sz		(1)
+#define RPCB_protocol_sz	(1)
+#define RPCB_port_sz		(1)
+#define RPCB_boolean_sz		(1)
+
+#define RPCB_netid_sz		(1 + XDR_QUADLEN(RPCBIND_MAXNETIDLEN))
+#define RPCB_addr_sz		(1 + XDR_QUADLEN(RPCBIND_MAXUADDRLEN))
+#define RPCB_ownerstring_sz	(1 + XDR_QUADLEN(RPCB_MAXOWNERLEN))
+
+/*
+ * XDR argument and result sizes
+ */
+#define RPCB_mappingargs_sz	(RPCB_program_sz + RPCB_version_sz + \
+				RPCB_protocol_sz + RPCB_port_sz)
+#define RPCB_getaddrargs_sz	(RPCB_program_sz + RPCB_version_sz + \
+				RPCB_netid_sz + RPCB_addr_sz + \
+				RPCB_ownerstring_sz)
+
+#define RPCB_getportres_sz	RPCB_port_sz
+#define RPCB_setres_sz		RPCB_boolean_sz
+
+/*
+ * Note that RFC 1833 does not put any size restrictions on the
+ * address string returned by the remote rpcbind database.
+ */
+#define RPCB_getaddrres_sz	RPCB_addr_sz
+
 static void			rpcb_getport_done(struct rpc_task *, void *);
 static void			rpcb_map_release(void *data);
 static struct rpc_program	rpcb_program;
@@ -768,31 +799,6 @@ out_err:
 	return -EIO;
 }
 
-#define RPCB_program_sz		(1u)
-#define RPCB_version_sz		(1u)
-#define RPCB_protocol_sz	(1u)
-#define RPCB_port_sz		(1u)
-#define RPCB_boolean_sz		(1u)
-
-#define RPCB_netid_sz		(1+XDR_QUADLEN(RPCBIND_MAXNETIDLEN))
-#define RPCB_addr_sz		(1+XDR_QUADLEN(RPCBIND_MAXUADDRLEN))
-#define RPCB_ownerstring_sz	(1+XDR_QUADLEN(RPCB_MAXOWNERLEN))
-
-#define RPCB_mappingargs_sz	RPCB_program_sz+RPCB_version_sz+	\
-				RPCB_protocol_sz+RPCB_port_sz
-#define RPCB_getaddrargs_sz	RPCB_program_sz+RPCB_version_sz+	\
-				RPCB_netid_sz+RPCB_addr_sz+		\
-				RPCB_ownerstring_sz
-
-#define RPCB_setres_sz		RPCB_boolean_sz
-#define RPCB_getportres_sz	RPCB_port_sz
-
-/*
- * Note that RFC 1833 does not put any size restrictions on the
- * address string returned by the remote rpcbind database.
- */
-#define RPCB_getaddrres_sz	RPCB_addr_sz
-
 #define PROC(proc, argtype, restype)					\
 	[RPCBPROC_##proc] = {						\
 		.p_proc		= RPCBPROC_##proc,			\

