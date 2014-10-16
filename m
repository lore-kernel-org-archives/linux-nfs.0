Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:55774 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbaJPTkK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:40:10 -0400
Received: by mail-ie0-f181.google.com with SMTP id at20so4129311iec.40
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:40:09 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id d5sm3482955ioj.30.2014.10.16.12.40.08
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:40:09 -0700 (PDT)
Subject: [PATCH v1 14/16] NFS: Set BIND_CONN_TO_SESSION arguments in the
 proc layer
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:40:08 -0400
Message-ID: <20141016194008.13414.6476.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When NFS_CS_SIDECAR_BACKCHANNEL is set, the client needs to bind
both the forward and the back channel during recovery. Two separate
BC2S operations are needed, with different arguments.

Prepare nfs4_proc_bind_conn_to_session() by creating a complete arg
struct for the BIND_CONN_TO_SESSION XDR encoder.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c       |    6 +++++-
 fs/nfs/nfs4xdr.c        |   16 +++++++++-------
 include/linux/nfs_xdr.h |    6 ++++++
 3 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a1243e7..9a8ffb7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6578,11 +6578,15 @@ nfs41_same_server_scope(struct nfs41_server_scope *a,
 int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	int status;
+	struct nfs41_bind_conn_to_session_args args = {
+		.client = clp,
+		.dir = NFS4_CDFC4_BACK_OR_BOTH,
+	};
 	struct nfs41_bind_conn_to_session_res res;
 	struct rpc_message msg = {
 		.rpc_proc =
 			&nfs4_procedures[NFSPROC4_CLNT_BIND_CONN_TO_SESSION],
-		.rpc_argp = clp,
+		.rpc_argp = &args,
 		.rpc_resp = &res,
 		.rpc_cred = cred,
 	};
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e13b59d..6dfdd14 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1733,17 +1733,19 @@ static void encode_secinfo(struct xdr_stream *xdr, const struct qstr *name, stru
 #if defined(CONFIG_NFS_V4_1)
 /* NFSv4.1 operations */
 static void encode_bind_conn_to_session(struct xdr_stream *xdr,
-				   struct nfs4_session *session,
-				   struct compound_hdr *hdr)
+				  struct nfs41_bind_conn_to_session_args *args,
+				  struct compound_hdr *hdr)
 {
+	struct nfs4_session *session = args->client->cl_session;
 	__be32 *p;
 
 	encode_op_hdr(xdr, OP_BIND_CONN_TO_SESSION,
 		decode_bind_conn_to_session_maxsz, hdr);
 	encode_opaque_fixed(xdr, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
+
 	p = xdr_reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(NFS4_CDFC4_BACK_OR_BOTH);
-	*p = 0;	/* use_conn_in_rdma_mode = False */
+	*p++ = cpu_to_be32(args->dir);
+	*p = args->use_conn_in_rdma_mode ? xdr_one : xdr_zero;
 }
 
 static void encode_op_map(struct xdr_stream *xdr, struct nfs4_op_map *op_map)
@@ -2766,14 +2768,14 @@ static void nfs4_xdr_enc_fsid_present(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_bind_conn_to_session(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				struct nfs_client *clp)
+				struct nfs41_bind_conn_to_session_args *args)
 {
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_mvops->minor_version,
+		.minorversion = args->client->cl_mvops->minor_version,
 	};
 
 	encode_compound_hdr(xdr, req, &hdr);
-	encode_bind_conn_to_session(xdr, clp->cl_session, &hdr);
+	encode_bind_conn_to_session(xdr, args, &hdr);
 	encode_nops(&hdr);
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0040629..af17763 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1140,6 +1140,12 @@ struct nfs41_state_protection {
 	struct nfs4_op_map allow;
 };
 
+struct nfs41_bind_conn_to_session_args {
+	struct nfs_client		*client;
+	u32				dir;
+	bool				use_conn_in_rdma_mode;
+};
+
 #define NFS4_EXCHANGE_ID_LEN	(48)
 struct nfs41_exchange_id_args {
 	struct nfs_client		*client;

