Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57235 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754186Ab2KHAo2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 19:44:28 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] nfsd4: backchannel should use client-provided security flavor
Date: Wed,  7 Nov 2012 19:44:23 -0500
Message-Id: <1352335463-29084-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1352335463-29084-1-git-send-email-bfields@redhat.com>
References: <1352335463-29084-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

For now this only adds support for AUTH_NULL.  (Previously we assumed
AUTH_UNIX.)  We'll also need AUTH_GSS, which is trickier.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |    3 +--
 fs/nfsd/nfs4xdr.c      |   14 +++++++++++---
 fs/nfsd/state.h        |    1 +
 3 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a1aa18d..7bb187a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -692,7 +692,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		args.bc_xprt = conn->cb_xprt;
 		args.prognumber = clp->cl_cb_session->se_cb_prog;
 		args.protocol = XPRT_TRANSPORT_BC_TCP;
-		args.authflavor = RPC_AUTH_UNIX;
+		args.authflavor = ses->se_cb_sec.flavor;
 	}
 	/* Create RPC client */
 	client = rpc_create(&args);
@@ -709,7 +709,6 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 	clp->cl_cb_client = client;
 	clp->cl_cb_cred = cred;
 	return 0;
-
 }
 
 static void warn_no_callback_path(struct nfs4_client *clp, int reason)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d7e7c11..406d0c4 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -425,7 +425,7 @@ nfsd4_decode_access(struct nfsd4_compoundargs *argp, struct nfsd4_access *access
 static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_cb_sec *cbs)
 {
 	DECODE_HEAD;
-	u32 dummy;
+	u32 dummy, uid, gid;
 	char *machine_name;
 	int i;
 	int nr_secflavs;
@@ -433,12 +433,15 @@ static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_
 	/* callback_sec_params4 */
 	READ_BUF(4);
 	READ32(nr_secflavs);
+	cbs->flavor = (u32)(-1);
 	for (i = 0; i < nr_secflavs; ++i) {
 		READ_BUF(4);
 		READ32(dummy);
 		switch (dummy) {
 		case RPC_AUTH_NULL:
 			/* Nothing to read */
+			if (cbs->flavor == (u32)(-1))
+				cbs->flavor = RPC_AUTH_NULL;
 			break;
 		case RPC_AUTH_UNIX:
 			READ_BUF(8);
@@ -452,13 +455,18 @@ static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_
 
 			/* uid, gid */
 			READ_BUF(8);
-			READ32(cbs->uid);
-			READ32(cbs->gid);
+			READ32(uid);
+			READ32(gid);
 
 			/* more gids */
 			READ_BUF(4);
 			READ32(dummy);
 			READ_BUF(dummy * 4);
+			if (cbs->flavor == (u32)(-1)) {
+				cbs->uid = uid;
+				cbs->gid = gid;
+				cbs->flavor = RPC_AUTH_UNIX;
+			}
 			break;
 		case RPC_AUTH_GSS:
 			dprintk("RPC_AUTH_GSS callback secflavor "
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 0fd342a..0498053 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -151,6 +151,7 @@ struct nfsd4_channel_attrs {
 };
 
 struct nfsd4_cb_sec {
+	u32	flavor; /* (u32)(-1) used to mean "no valid flavor" */
 	u32	uid;
 	u32	gid;
 };
-- 
1.7.9.5

