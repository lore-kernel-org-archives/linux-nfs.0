Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57229 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754053Ab2KHAo0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 19:44:26 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] nfsd4: clean up callback security parsing
Date: Wed,  7 Nov 2012 19:44:19 -0500
Message-Id: <1352335463-29084-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1352335463-29084-1-git-send-email-bfields@redhat.com>
References: <1352335463-29084-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Move the callback parsing into a separate function.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |  118 ++++++++++++++++++++++++++++-------------------------
 fs/nfsd/state.h   |    9 +++-
 2 files changed, 70 insertions(+), 57 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index af65fda..511f980 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -422,6 +422,67 @@ nfsd4_decode_access(struct nfsd4_compoundargs *argp, struct nfsd4_access *access
 	DECODE_TAIL;
 }
 
+static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_cb_sec *cbs)
+{
+	DECODE_HEAD;
+	u32 dummy;
+	char *machine_name;
+	int i;
+	int nr_secflavs;
+
+	/* callback_sec_params4 */
+	READ_BUF(4);
+	READ32(nr_secflavs);
+	for (i = 0; i < nr_secflavs; ++i) {
+		READ_BUF(4);
+		READ32(dummy);
+		switch (dummy) {
+		case RPC_AUTH_NULL:
+			/* Nothing to read */
+			break;
+		case RPC_AUTH_UNIX:
+			READ_BUF(8);
+			/* stamp */
+			READ32(dummy);
+
+			/* machine name */
+			READ32(dummy);
+			READ_BUF(dummy);
+			SAVEMEM(machine_name, dummy);
+
+			/* uid, gid */
+			READ_BUF(8);
+			READ32(cbs->uid);
+			READ32(cbs->gid);
+
+			/* more gids */
+			READ_BUF(4);
+			READ32(dummy);
+			READ_BUF(dummy * 4);
+			break;
+		case RPC_AUTH_GSS:
+			dprintk("RPC_AUTH_GSS callback secflavor "
+				"not supported!\n");
+			READ_BUF(8);
+			/* gcbp_service */
+			READ32(dummy);
+			/* gcbp_handle_from_server */
+			READ32(dummy);
+			READ_BUF(dummy);
+			p += XDR_QUADLEN(dummy);
+			/* gcbp_handle_from_client */
+			READ_BUF(4);
+			READ32(dummy);
+			READ_BUF(dummy);
+			break;
+		default:
+			dprintk("Illegal callback secflavor\n");
+			return nfserr_inval;
+		}
+	}
+	DECODE_TAIL;
+}
+
 static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp, struct nfsd4_bind_conn_to_session *bcts)
 {
 	DECODE_HEAD;
@@ -1237,11 +1298,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
 			    struct nfsd4_create_session *sess)
 {
 	DECODE_HEAD;
-
 	u32 dummy;
-	char *machine_name;
-	int i;
-	int nr_secflavs;
 
 	READ_BUF(16);
 	COPYMEM(&sess->clientid, 8);
@@ -1282,58 +1339,9 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
 		goto xdr_error;
 	}
 
-	READ_BUF(8);
+	READ_BUF(4);
 	READ32(sess->callback_prog);
-
-	/* callback_sec_params4 */
-	READ32(nr_secflavs);
-	for (i = 0; i < nr_secflavs; ++i) {
-		READ_BUF(4);
-		READ32(dummy);
-		switch (dummy) {
-		case RPC_AUTH_NULL:
-			/* Nothing to read */
-			break;
-		case RPC_AUTH_UNIX:
-			READ_BUF(8);
-			/* stamp */
-			READ32(dummy);
-
-			/* machine name */
-			READ32(dummy);
-			READ_BUF(dummy);
-			SAVEMEM(machine_name, dummy);
-
-			/* uid, gid */
-			READ_BUF(8);
-			READ32(sess->uid);
-			READ32(sess->gid);
-
-			/* more gids */
-			READ_BUF(4);
-			READ32(dummy);
-			READ_BUF(dummy * 4);
-			break;
-		case RPC_AUTH_GSS:
-			dprintk("RPC_AUTH_GSS callback secflavor "
-				"not supported!\n");
-			READ_BUF(8);
-			/* gcbp_service */
-			READ32(dummy);
-			/* gcbp_handle_from_server */
-			READ32(dummy);
-			READ_BUF(dummy);
-			p += XDR_QUADLEN(dummy);
-			/* gcbp_handle_from_client */
-			READ_BUF(4);
-			READ32(dummy);
-			READ_BUF(dummy);
-			break;
-		default:
-			dprintk("Illegal callback secflavor\n");
-			return nfserr_inval;
-		}
-	}
+	nfsd4_decode_cb_sec(argp, &sess->cb_sec);
 	DECODE_TAIL;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e036894..df33e78 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -150,6 +150,11 @@ struct nfsd4_channel_attrs {
 	u32		rdma_attrs;
 };
 
+struct nfsd4_cb_sec {
+	u32	uid;
+	u32	gid;
+};
+
 struct nfsd4_create_session {
 	clientid_t			clientid;
 	struct nfs4_sessionid		sessionid;
@@ -158,8 +163,7 @@ struct nfsd4_create_session {
 	struct nfsd4_channel_attrs	fore_channel;
 	struct nfsd4_channel_attrs	back_channel;
 	u32				callback_prog;
-	u32				uid;
-	u32				gid;
+	struct nfsd4_cb_sec		cb_sec;
 };
 
 struct nfsd4_bind_conn_to_session {
@@ -192,6 +196,7 @@ struct nfsd4_session {
 	struct nfs4_sessionid	se_sessionid;
 	struct nfsd4_channel_attrs se_fchannel;
 	struct nfsd4_channel_attrs se_bchannel;
+	struct nfsd4_cb_sec	se_cb_sec;
 	struct list_head	se_conns;
 	u32			se_cb_prog;
 	u32			se_cb_seq_nr;
-- 
1.7.9.5

