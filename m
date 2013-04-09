Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50135 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935503Ab3DIX6U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 19:58:20 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/10] nfsd4: check backchannel attributes on create_session
Date: Tue,  9 Apr 2013 19:58:13 -0400
Message-Id: <1365551896-6936-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1365551896-6936-1-git-send-email-bfields@redhat.com>
References: <1365551896-6936-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Make sure the client gives us an adequate backchannel.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c          |   25 +------------------------
 fs/nfsd/nfs4state.c             |   25 +++++++++++++++++++++++++
 fs/nfsd/xdr4cb.h                |   23 +++++++++++++++++++++++
 include/linux/sunrpc/msg_prot.h |    3 +++
 4 files changed, 52 insertions(+), 24 deletions(-)
 create mode 100644 fs/nfsd/xdr4cb.h

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index be3ff0f..7f05cd1 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -37,6 +37,7 @@
 #include "nfsd.h"
 #include "state.h"
 #include "netns.h"
+#include "xdr4cb.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -53,30 +54,6 @@ enum {
 	NFSPROC4_CLNT_CB_SEQUENCE,
 };
 
-#define NFS4_MAXTAGLEN		20
-
-#define NFS4_enc_cb_null_sz		0
-#define NFS4_dec_cb_null_sz		0
-#define cb_compound_enc_hdr_sz		4
-#define cb_compound_dec_hdr_sz		(3 + (NFS4_MAXTAGLEN >> 2))
-#define sessionid_sz			(NFS4_MAX_SESSIONID_LEN >> 2)
-#define cb_sequence_enc_sz		(sessionid_sz + 4 +             \
-					1 /* no referring calls list yet */)
-#define cb_sequence_dec_sz		(op_dec_sz + sessionid_sz + 4)
-
-#define op_enc_sz			1
-#define op_dec_sz			2
-#define enc_nfs4_fh_sz			(1 + (NFS4_FHSIZE >> 2))
-#define enc_stateid_sz			(NFS4_STATEID_SIZE >> 2)
-#define NFS4_enc_cb_recall_sz		(cb_compound_enc_hdr_sz +       \
-					cb_sequence_enc_sz +            \
-					1 + enc_stateid_sz +            \
-					enc_nfs4_fh_sz)
-
-#define NFS4_dec_cb_recall_sz		(cb_compound_dec_hdr_sz  +      \
-					cb_sequence_dec_sz +            \
-					op_dec_sz)
-
 struct nfs4_cb_compound_hdr {
 	/* args */
 	u32		ident;	/* minorversion 0 only */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 036d5f1..67017fc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -42,6 +42,7 @@
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/addr.h>
 #include "xdr4.h"
+#include "xdr4cb.h"
 #include "vfs.h"
 #include "current_stateid.h"
 
@@ -1794,6 +1795,27 @@ static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs *ca, struct nfs
 	return nfs_ok;
 }
 
+static __be32 check_backchannel_attrs(struct nfsd4_channel_attrs *ca)
+{
+	ca->headerpadsz = 0;
+
+	/*
+	 * These RPC_MAX_HEADER macros are overkill, especially since we
+	 * don't even do gss on the backchannel yet.  But this is still
+	 * less than 1k.  Tighten up this estimate in the unlikely event
+	 * it turns out to be a problem for some client:
+	 */
+	if (ca->maxreq_sz < NFS4_enc_cb_recall_sz + RPC_MAX_HEADER_WITH_AUTH)
+		return nfserr_toosmall;
+	if (ca->maxresp_sz < NFS4_dec_cb_recall_sz + RPC_MAX_REPHEADER_WITH_AUTH)
+		return nfserr_toosmall;
+	ca->maxresp_cached = 0;
+	if (ca->maxops < 2)
+		return nfserr_toosmall;
+
+	return nfs_ok;
+}
+
 __be32
 nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
@@ -1812,6 +1834,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	status = check_forechannel_attrs(&cr_ses->fore_channel, nn);
 	if (status)
 		return status;
+	status = check_backchannel_attrs(&cr_ses->back_channel);
+	if (status)
+		return status;
 	status = nfserr_jukebox;
 	new = alloc_session(&cr_ses->fore_channel);
 	if (!new)
diff --git a/fs/nfsd/xdr4cb.h b/fs/nfsd/xdr4cb.h
new file mode 100644
index 0000000..c5c55df
--- /dev/null
+++ b/fs/nfsd/xdr4cb.h
@@ -0,0 +1,23 @@
+#define NFS4_MAXTAGLEN		20
+
+#define NFS4_enc_cb_null_sz		0
+#define NFS4_dec_cb_null_sz		0
+#define cb_compound_enc_hdr_sz		4
+#define cb_compound_dec_hdr_sz		(3 + (NFS4_MAXTAGLEN >> 2))
+#define sessionid_sz			(NFS4_MAX_SESSIONID_LEN >> 2)
+#define cb_sequence_enc_sz		(sessionid_sz + 4 +             \
+					1 /* no referring calls list yet */)
+#define cb_sequence_dec_sz		(op_dec_sz + sessionid_sz + 4)
+
+#define op_enc_sz			1
+#define op_dec_sz			2
+#define enc_nfs4_fh_sz			(1 + (NFS4_FHSIZE >> 2))
+#define enc_stateid_sz			(NFS4_STATEID_SIZE >> 2)
+#define NFS4_enc_cb_recall_sz		(cb_compound_enc_hdr_sz +       \
+					cb_sequence_enc_sz +            \
+					1 + enc_stateid_sz +            \
+					enc_nfs4_fh_sz)
+
+#define NFS4_dec_cb_recall_sz		(cb_compound_dec_hdr_sz  +      \
+					cb_sequence_dec_sz +            \
+					op_dec_sz)
diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index c68a147..aadc6a0 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -138,6 +138,9 @@ typedef __be32	rpc_fraghdr;
 #define RPC_MAX_HEADER_WITH_AUTH \
 	(RPC_CALLHDRSIZE + 2*(2+RPC_MAX_AUTH_SIZE/4))
 
+#define RPC_MAX_REPHEADER_WITH_AUTH \
+	(RPC_REPHDRSIZE + (2 + RPC_MAX_AUTH_SIZE/4))
+
 /*
  * RFC1833/RFC3530 rpcbind (v3+) well-known netid's.
  */
-- 
1.7.9.5

