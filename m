Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36212 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932069AbeE3SGY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:24 -0400
Received: by mail-io0-f194.google.com with SMTP id d73-v6so22696986iog.3
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:24 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.22
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:22 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/19] pnfs: Add conditional encode/decode of LAYOUTGET within OPEN compound
Date: Wed, 30 May 2018 14:05:41 -0400
Message-Id: <20180530180553.38769-8-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-7-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
 <20180530180553.38769-5-trond.myklebust@hammerspace.com>
 <20180530180553.38769-6-trond.myklebust@hammerspace.com>
 <20180530180553.38769-7-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c       |  1 +
 fs/nfs/nfs4xdr.c        | 50 +++++++++++++++++++++++++++++++++++++----
 include/linux/nfs_xdr.h |  2 ++
 3 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0eaab13dff04..54f2987483fa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1081,6 +1081,7 @@ struct nfs4_opendata {
 	struct nfs4_state_owner *owner;
 	struct nfs4_state *state;
 	struct iattr attrs;
+	struct nfs4_layoutget *lgp;
 	unsigned long timestamp;
 	bool rpc_done;
 	bool file_created;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6024980dfc9e..738a7be019d2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -65,7 +65,13 @@
 /* Mapping from NFS error code to "errno" error code. */
 #define errno_NFSERR_IO		EIO
 
+struct compound_hdr;
 static int nfs4_stat_to_errno(int);
+static void encode_layoutget(struct xdr_stream *xdr,
+			     const struct nfs4_layoutget_args *args,
+			     struct compound_hdr *hdr);
+static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
+			     struct nfs4_layoutget_res *res);
 
 /* NFSv4 COMPOUND tags are only wanted for debugging purposes */
 #ifdef DEBUG
@@ -424,6 +430,8 @@ static int nfs4_stat_to_errno(int);
 #define decode_sequence_maxsz	0
 #define encode_layoutreturn_maxsz 0
 #define decode_layoutreturn_maxsz 0
+#define encode_layoutget_maxsz	0
+#define decode_layoutget_maxsz	0
 #endif /* CONFIG_NFS_V4_1 */
 
 #define NFS4_enc_compound_sz	(1024)  /* XXX: large enough? */
@@ -476,14 +484,16 @@ static int nfs4_stat_to_errno(int);
 				encode_open_maxsz + \
 				encode_access_maxsz + \
 				encode_getfh_maxsz + \
-				encode_getattr_maxsz)
+				encode_getattr_maxsz + \
+				encode_layoutget_maxsz)
 #define NFS4_dec_open_sz        (compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_open_maxsz + \
 				decode_access_maxsz + \
 				decode_getfh_maxsz + \
-				decode_getattr_maxsz)
+				decode_getattr_maxsz + \
+				decode_layoutget_maxsz)
 #define NFS4_enc_open_confirm_sz \
 				(compound_encode_hdr_maxsz + \
 				 encode_putfh_maxsz + \
@@ -497,13 +507,15 @@ static int nfs4_stat_to_errno(int);
 					encode_putfh_maxsz + \
 					encode_open_maxsz + \
 					encode_access_maxsz + \
-					encode_getattr_maxsz)
+					encode_getattr_maxsz + \
+					encode_layoutget_maxsz)
 #define NFS4_dec_open_noattr_sz	(compound_decode_hdr_maxsz + \
 					decode_sequence_maxsz + \
 					decode_putfh_maxsz + \
 					decode_open_maxsz + \
 					decode_access_maxsz + \
-					decode_getattr_maxsz)
+					decode_getattr_maxsz + \
+					decode_layoutget_maxsz)
 #define NFS4_enc_open_downgrade_sz \
 				(compound_encode_hdr_maxsz + \
 				 encode_sequence_maxsz + \
@@ -2070,6 +2082,13 @@ encode_layoutreturn(struct xdr_stream *xdr,
 		    struct compound_hdr *hdr)
 {
 }
+
+static void
+encode_layoutget(struct xdr_stream *xdr,
+		      const struct nfs4_layoutget_args *args,
+		      struct compound_hdr *hdr)
+{
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -2316,6 +2335,12 @@ static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
 	if (args->access)
 		encode_access(xdr, args->access, &hdr);
 	encode_getfattr_open(xdr, args->bitmask, args->open_bitmap, &hdr);
+	if (args->lg_args) {
+		encode_layoutget(xdr, args->lg_args, &hdr);
+		xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
+				 args->lg_args->layout.pages,
+				 0, args->lg_args->layout.pglen);
+	}
 	encode_nops(&hdr);
 }
 
@@ -2356,6 +2381,12 @@ static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
 	if (args->access)
 		encode_access(xdr, args->access, &hdr);
 	encode_getfattr_open(xdr, args->bitmask, args->open_bitmap, &hdr);
+	if (args->lg_args) {
+		encode_layoutget(xdr, args->lg_args, &hdr);
+		xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
+				 args->lg_args->layout.pages,
+				 0, args->lg_args->layout.pglen);
+	}
 	encode_nops(&hdr);
 }
 
@@ -6182,6 +6213,13 @@ int decode_layoutreturn(struct xdr_stream *xdr,
 {
 	return 0;
 }
+
+static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
+			    struct nfs4_layoutget_res *res)
+{
+	return 0;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -6628,6 +6666,8 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	if (res->access_request)
 		decode_access(xdr, &res->access_supported, &res->access_result);
 	decode_getfattr_label(xdr, res->f_attr, res->f_label, res->server);
+	if (res->lg_res)
+		decode_layoutget(xdr, rqstp, res->lg_res);
 out:
 	return status;
 }
@@ -6680,6 +6720,8 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp,
 	if (res->access_request)
 		decode_access(xdr, &res->access_supported, &res->access_result);
 	decode_getfattr(xdr, res->f_attr, res->server);
+	if (res->lg_res)
+		decode_layoutget(xdr, rqstp, res->lg_res);
 out:
 	return status;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index dee11a9e91e8..b36be7a703ea 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -436,6 +436,7 @@ struct nfs_openargs {
 	enum createmode4	createmode;
 	const struct nfs4_label *label;
 	umode_t			umask;
+	struct nfs4_layoutget_args *lg_args;
 };
 
 struct nfs_openres {
@@ -458,6 +459,7 @@ struct nfs_openres {
 	__u32			access_request;
 	__u32			access_supported;
 	__u32			access_result;
+	struct nfs4_layoutget_res *lg_res;
 };
 
 /*
-- 
2.17.0

