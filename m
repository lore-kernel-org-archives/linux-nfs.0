Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:50801 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbaJAMF3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Oct 2014 08:05:29 -0400
Received: by mail-qg0-f45.google.com with SMTP id e89so123298qgf.4
        for <linux-nfs@vger.kernel.org>; Wed, 01 Oct 2014 05:05:28 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH] nfsd: eliminate "to_delegation" define
Date: Wed,  1 Oct 2014 08:05:22 -0400
Message-Id: <1412165122-17557-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We now have cb_to_delegation and to_delegation, which do the same thing
and are defined separately in different .c files. Move the
cb_to_delegation definition into a header file and eliminate the
redundant to_delegation definition.

Cc: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4callback.c | 5 +----
 fs/nfsd/nfs4state.c    | 3 ---
 fs/nfsd/state.h        | 3 +++
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 4fe4be1ee82e..ed2b1151b171 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -49,9 +49,6 @@ static void nfsd4_mark_cb_fault(struct nfs4_client *, int reason);
 
 /* Index of predefined Linux callback client operations */
 
-#define to_delegation(cb) \
-	container_of(cb, struct nfs4_delegation, dl_recall)
-
 struct nfs4_cb_compound_hdr {
 	/* args */
 	u32		ident;	/* minorversion 0 only */
@@ -491,7 +488,7 @@ static void nfs4_xdr_enc_cb_null(struct rpc_rqst *req, struct xdr_stream *xdr,
 static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
 				   const struct nfsd4_callback *cb)
 {
-	const struct nfs4_delegation *dp = to_delegation(cb);
+	const struct nfs4_delegation *dp = cb_to_delegation(cb);
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = cb->cb_clp->cl_cb_ident,
 		.minorversion = cb->cb_minorversion,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 551f32d7f5c7..5c0cac173068 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3360,9 +3360,6 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 	return ret;
 }
 
-#define cb_to_delegation(cb) \
-	container_of(cb, struct nfs4_delegation, dl_recall)
-
 static void nfsd4_cb_recall_prepare(struct nfsd4_callback *cb)
 {
 	struct nfs4_delegation *dp = cb_to_delegation(cb);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index bf52dc7b15e7..0a47c6a6b301 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -132,6 +132,9 @@ struct nfs4_delegation {
 	struct nfsd4_callback	dl_recall;
 };
 
+#define cb_to_delegation(cb) \
+	container_of(cb, struct nfs4_delegation, dl_recall)
+
 /* client delegation callback info */
 struct nfs4_cb_conn {
 	/* SETCLIENTID info */
-- 
1.9.3

