Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:38869 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbcBRRoD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 12:44:03 -0500
Subject: [PATCH v3 02/10] nfsd: Lower NFSv4.1 callback message size limit
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 18 Feb 2016 12:44:01 -0500
Message-ID: <20160218174401.12825.46375.stgit@klimt.1015granger.net>
In-Reply-To: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
References: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The maximum size of a backchannel message on RPC-over-RDMA depends
on the connection's inline threshold. Today that threshold is
typically 1024 bytes, making the maximum message size 996 bytes.

The Linux server's CREATE_SESSION operation checks that the size
of callback Calls can be as large as 1044 bytes, to accommodate
RPCSEC_GSS. Thus CREATE_SESSION fails if a client advertises the
true message size maximum of 996 bytes.

But the server's backchannel currently does not support RPCSEC_GSS.
The actual maximum size it needs is much smaller. It is safe to
reduce the limit to enable NFSv4.1 on RDMA backchannel operation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4state.c         |   24 ++++++++++++++++--------
 include/linux/sunrpc/auth.h |    7 +++++++
 net/sunrpc/auth_null.c      |    4 ++--
 net/sunrpc/auth_unix.c      |    6 ++----
 4 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c484a2b..0f56e57 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2586,21 +2586,29 @@ static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs *ca, struct nfs
 	return nfs_ok;
 }
 
+/*
+ * Server's NFSv4.1 backchannel support is AUTH_SYS-only for now.
+ * These are based on similar macros in linux/sunrpc/msg_prot.h .
+ */
+#define RPC_MAX_HEADER_WITH_AUTH_SYS \
+	(RPC_CALLHDRSIZE + 2 * (2 + UNX_CALLSLACK))
+
+#define RPC_MAX_REPHEADER_WITH_AUTH_SYS \
+	(RPC_REPHDRSIZE + (2 + NUL_REPLYSLACK))
+
 #define NFSD_CB_MAX_REQ_SZ	((NFS4_enc_cb_recall_sz + \
-				 RPC_MAX_HEADER_WITH_AUTH) * sizeof(__be32))
+				 RPC_MAX_HEADER_WITH_AUTH_SYS) * sizeof(__be32))
 #define NFSD_CB_MAX_RESP_SZ	((NFS4_dec_cb_recall_sz + \
-				 RPC_MAX_REPHEADER_WITH_AUTH) * sizeof(__be32))
+				 RPC_MAX_REPHEADER_WITH_AUTH_SYS) * \
+				 sizeof(__be32))
 
 static __be32 check_backchannel_attrs(struct nfsd4_channel_attrs *ca)
 {
 	ca->headerpadsz = 0;
 
-	/*
-	 * These RPC_MAX_HEADER macros are overkill, especially since we
-	 * don't even do gss on the backchannel yet.  But this is still
-	 * less than 1k.  Tighten up this estimate in the unlikely event
-	 * it turns out to be a problem for some client:
-	 */
+	pr_err("%s: NFSD_CB_MAX_REQ_SZ=%lu, NFSD_CB_MAX_RESP_SZ=%lu\n",
+		__func__, NFSD_CB_MAX_REQ_SZ, NFSD_CB_MAX_RESP_SZ);
+
 	if (ca->maxreq_sz < NFSD_CB_MAX_REQ_SZ)
 		return nfserr_toosmall;
 	if (ca->maxresp_sz < NFSD_CB_MAX_RESP_SZ)
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 1ecf13e..6a241a2 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -21,10 +21,17 @@
 #include <linux/utsname.h>
 
 /*
+ * Maximum size of AUTH_NONE authentication information, in XDR words.
+ */
+#define NUL_CALLSLACK	(4)
+#define NUL_REPLYSLACK	(2)
+
+/*
  * Size of the nodename buffer. RFC1831 specifies a hard limit of 255 bytes,
  * but Linux hostnames are actually limited to __NEW_UTS_LEN bytes.
  */
 #define UNX_MAXNODENAME	__NEW_UTS_LEN
+#define UNX_CALLSLACK	(21 + XDR_QUADLEN(UNX_MAXNODENAME))
 
 struct rpcsec_gss_info;
 
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index c2a2b58..8d9eb4d 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -113,8 +113,8 @@ const struct rpc_authops authnull_ops = {
 
 static
 struct rpc_auth null_auth = {
-	.au_cslack	= 4,
-	.au_rslack	= 2,
+	.au_cslack	= NUL_CALLSLACK,
+	.au_rslack	= NUL_REPLYSLACK,
 	.au_ops		= &authnull_ops,
 	.au_flavor	= RPC_AUTH_NULL,
 	.au_count	= ATOMIC_INIT(0),
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 548240d..0d3dd36 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -23,8 +23,6 @@ struct unx_cred {
 };
 #define uc_uid			uc_base.cr_uid
 
-#define UNX_WRITESLACK		(21 + XDR_QUADLEN(UNX_MAXNODENAME))
-
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
@@ -228,8 +226,8 @@ const struct rpc_authops authunix_ops = {
 
 static
 struct rpc_auth		unix_auth = {
-	.au_cslack	= UNX_WRITESLACK,
-	.au_rslack	= 2,			/* assume AUTH_NULL verf */
+	.au_cslack	= UNX_CALLSLACK,
+	.au_rslack	= NUL_REPLYSLACK,
 	.au_ops		= &authunix_ops,
 	.au_flavor	= RPC_AUTH_UNIX,
 	.au_count	= ATOMIC_INIT(0),

