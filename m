Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:32862 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754150AbcEPSrx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2016 14:47:53 -0400
Received: by mail-qg0-f67.google.com with SMTP id 90so14505373qgz.0
        for <linux-nfs@vger.kernel.org>; Mon, 16 May 2016 11:47:52 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] NFSv4: Label stateids with the type
Date: Mon, 16 May 2016 14:47:25 -0400
Message-Id: <1463424447-57302-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1463424447-57302-1-git-send-email-trond.myklebust@primarydata.com>
References: <1463424447-57302-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to more easily distinguish what kind of stateid we are dealing
with, introduce a type that can be used to label the stateid structure.

The label will be useful both for debugging, but also when dealing with
operations like SETATTR, READ and WRITE that can take several different
types of stateid as arguments.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_xdr.c                     | 18 ++++++++++---
 fs/nfs/flexfilelayout/flexfilelayout.c    |  7 +++---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  3 ++-
 fs/nfs/nfs4_fs.h                          |  7 ++++--
 fs/nfs/nfs4proc.c                         |  3 +++
 fs/nfs/nfs4state.c                        |  5 +++-
 fs/nfs/nfs4xdr.c                          | 42 ++++++++++++++++++++++++-------
 include/linux/nfs4.h                      | 25 ++++++++++++++----
 8 files changed, 86 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 976c90608e56..3a1dcee29861 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -146,10 +146,22 @@ static __be32 decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
 	p = read_buf(xdr, NFS4_STATEID_SIZE);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
-	memcpy(stateid, p, NFS4_STATEID_SIZE);
+	memcpy(stateid->data, p, NFS4_STATEID_SIZE);
 	return 0;
 }
 
+static __be32 decode_delegation_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
+{
+	stateid->type = NFS4_DELEGATION_STATEID_TYPE;
+	return decode_stateid(xdr, stateid);
+}
+
+static __be32 decode_layout_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
+{
+	stateid->type = NFS4_LAYOUT_STATEID_TYPE;
+	return decode_stateid(xdr, stateid);
+}
+
 static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound_hdr_arg *hdr)
 {
 	__be32 *p;
@@ -211,7 +223,7 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	__be32 *p;
 	__be32 status;
 
-	status = decode_stateid(xdr, &args->stateid);
+	status = decode_delegation_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
 		goto out;
 	p = read_buf(xdr, 4);
@@ -263,7 +275,7 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 		}
 		p = xdr_decode_hyper(p, &args->cbl_range.offset);
 		p = xdr_decode_hyper(p, &args->cbl_range.length);
-		status = decode_stateid(xdr, &args->cbl_stateid);
+		status = decode_layout_stateid(xdr, &args->cbl_stateid);
 		if (unlikely(status != 0))
 			goto out;
 	} else if (args->cbl_recall_type == RETURN_FSID) {
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0cb1abd535e3..210314ee4912 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -53,14 +53,15 @@ ff_layout_free_layout_hdr(struct pnfs_layout_hdr *lo)
 	kfree(FF_LAYOUT_FROM_HDR(lo));
 }
 
-static int decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
+static int decode_pnfs_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
 {
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, NFS4_STATEID_SIZE);
 	if (unlikely(p == NULL))
 		return -ENOBUFS;
-	memcpy(stateid, p, NFS4_STATEID_SIZE);
+	stateid->type = NFS4_PNFS_DS_STATEID_TYPE;
+	memcpy(stateid->data, p, NFS4_STATEID_SIZE);
 	dprintk("%s: stateid id= [%x%x%x%x]\n", __func__,
 		p[0], p[1], p[2], p[3]);
 	return 0;
@@ -456,7 +457,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		fls->mirror_array[i]->efficiency = be32_to_cpup(p);
 
 		/* stateid */
-		rc = decode_stateid(&stream, &fls->mirror_array[i]->stateid);
+		rc = decode_pnfs_stateid(&stream, &fls->mirror_array[i]->stateid);
 		if (rc)
 			goto out_err_free;
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index add0e5a70bd6..00fa83b06b74 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -228,7 +228,8 @@ ff_ds_error_match(const struct nfs4_ff_layout_ds_err *e1,
 		return e1->opnum < e2->opnum ? -1 : 1;
 	if (e1->status != e2->status)
 		return e1->status < e2->status ? -1 : 1;
-	ret = memcmp(&e1->stateid, &e2->stateid, sizeof(e1->stateid));
+	ret = memcmp(e1->stateid.data, e2->stateid.data,
+			sizeof(e1->stateid.data));
 	if (ret != 0)
 		return ret;
 	ret = memcmp(&e1->deviceid, &e2->deviceid, sizeof(e1->deviceid));
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4afdee420d25..b5d9f345c9f2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -496,12 +496,15 @@ extern struct svc_version nfs4_callback_version4;
 
 static inline void nfs4_stateid_copy(nfs4_stateid *dst, const nfs4_stateid *src)
 {
-	memcpy(dst, src, sizeof(*dst));
+	memcpy(dst->data, src->data, sizeof(dst->data));
+	dst->type = src->type;
 }
 
 static inline bool nfs4_stateid_match(const nfs4_stateid *dst, const nfs4_stateid *src)
 {
-	return memcmp(dst, src, sizeof(*dst)) == 0;
+	if (dst->type != src->type)
+		return false;
+	return memcmp(dst->data, src->data, sizeof(dst->data)) == 0;
 }
 
 static inline bool nfs4_stateid_match_other(const nfs4_stateid *dst, const nfs4_stateid *src)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 327b8c34d360..9cc6d28101ac 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8653,6 +8653,9 @@ nfs41_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp)
 static bool nfs41_match_stateid(const nfs4_stateid *s1,
 		const nfs4_stateid *s2)
 {
+	if (s1->type != s2->type)
+		return false;
+
 	if (memcmp(s1->other, s2->other, sizeof(s1->other)) != 0)
 		return false;
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d854693a15b0..d630f9cca0f1 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -65,7 +65,10 @@
 
 #define OPENOWNER_POOL_SIZE	8
 
-const nfs4_stateid zero_stateid;
+const nfs4_stateid zero_stateid = {
+	.data = { 0 },
+	.type = NFS4_SPECIAL_STATEID_TYPE,
+};
 static DEFINE_MUTEX(nfs_clid_init_mutex);
 
 int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 88474a4fc669..7a24c92d1672 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4270,6 +4270,30 @@ static int decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
 	return decode_opaque_fixed(xdr, stateid, NFS4_STATEID_SIZE);
 }
 
+static int decode_open_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
+{
+	stateid->type = NFS4_OPEN_STATEID_TYPE;
+	return decode_stateid(xdr, stateid);
+}
+
+static int decode_lock_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
+{
+	stateid->type = NFS4_LOCK_STATEID_TYPE;
+	return decode_stateid(xdr, stateid);
+}
+
+static int decode_delegation_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
+{
+	stateid->type = NFS4_DELEGATION_STATEID_TYPE;
+	return decode_stateid(xdr, stateid);
+}
+
+static int decode_layout_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
+{
+	stateid->type = NFS4_LAYOUT_STATEID_TYPE;
+	return decode_stateid(xdr, stateid);
+}
+
 static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
 {
 	int status;
@@ -4278,7 +4302,7 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
 	if (status != -EIO)
 		nfs_increment_open_seqid(status, res->seqid);
 	if (!status)
-		status = decode_stateid(xdr, &res->stateid);
+		status = decode_open_stateid(xdr, &res->stateid);
 	return status;
 }
 
@@ -4937,7 +4961,7 @@ static int decode_lock(struct xdr_stream *xdr, struct nfs_lock_res *res)
 	if (status == -EIO)
 		goto out;
 	if (status == 0) {
-		status = decode_stateid(xdr, &res->stateid);
+		status = decode_lock_stateid(xdr, &res->stateid);
 		if (unlikely(status))
 			goto out;
 	} else if (status == -NFS4ERR_DENIED)
@@ -4966,7 +4990,7 @@ static int decode_locku(struct xdr_stream *xdr, struct nfs_locku_res *res)
 	if (status != -EIO)
 		nfs_increment_lock_seqid(status, res->seqid);
 	if (status == 0)
-		status = decode_stateid(xdr, &res->stateid);
+		status = decode_lock_stateid(xdr, &res->stateid);
 	return status;
 }
 
@@ -5016,7 +5040,7 @@ static int decode_rw_delegation(struct xdr_stream *xdr,
 	__be32 *p;
 	int status;
 
-	status = decode_stateid(xdr, &res->delegation);
+	status = decode_delegation_stateid(xdr, &res->delegation);
 	if (unlikely(status))
 		return status;
 	p = xdr_inline_decode(xdr, 4);
@@ -5096,7 +5120,7 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 	nfs_increment_open_seqid(status, res->seqid);
 	if (status)
 		return status;
-	status = decode_stateid(xdr, &res->stateid);
+	status = decode_open_stateid(xdr, &res->stateid);
 	if (unlikely(status))
 		return status;
 
@@ -5136,7 +5160,7 @@ static int decode_open_confirm(struct xdr_stream *xdr, struct nfs_open_confirmre
 	if (status != -EIO)
 		nfs_increment_open_seqid(status, res->seqid);
 	if (!status)
-		status = decode_stateid(xdr, &res->stateid);
+		status = decode_open_stateid(xdr, &res->stateid);
 	return status;
 }
 
@@ -5148,7 +5172,7 @@ static int decode_open_downgrade(struct xdr_stream *xdr, struct nfs_closeres *re
 	if (status != -EIO)
 		nfs_increment_open_seqid(status, res->seqid);
 	if (!status)
-		status = decode_stateid(xdr, &res->stateid);
+		status = decode_open_stateid(xdr, &res->stateid);
 	return status;
 }
 
@@ -5919,7 +5943,7 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 	if (unlikely(!p))
 		goto out_overflow;
 	res->return_on_close = be32_to_cpup(p);
-	decode_stateid(xdr, &res->stateid);
+	decode_layout_stateid(xdr, &res->stateid);
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
@@ -5985,7 +6009,7 @@ static int decode_layoutreturn(struct xdr_stream *xdr,
 		goto out_overflow;
 	res->lrs_present = be32_to_cpup(p);
 	if (res->lrs_present)
-		status = decode_stateid(xdr, &res->stateid);
+		status = decode_layout_stateid(xdr, &res->stateid);
 	return status;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 011433478a14..f561e2029862 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -50,12 +50,27 @@ struct nfs4_label {
 
 typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
 
-struct nfs_stateid4 {
-	__be32 seqid;
-	char other[NFS4_STATEID_OTHER_SIZE];
-} __attribute__ ((packed));
+struct nfs4_stateid_struct {
+	union {
+		char data[NFS4_STATEID_SIZE];
+		struct {
+			__be32 seqid;
+			char other[NFS4_STATEID_OTHER_SIZE];
+		} __attribute__ ((packed));
+	};
+
+	enum {
+		NFS4_INVALID_STATEID_TYPE = 0,
+		NFS4_SPECIAL_STATEID_TYPE,
+		NFS4_OPEN_STATEID_TYPE,
+		NFS4_LOCK_STATEID_TYPE,
+		NFS4_DELEGATION_STATEID_TYPE,
+		NFS4_LAYOUT_STATEID_TYPE,
+		NFS4_PNFS_DS_STATEID_TYPE,
+	} type;
+};
 
-typedef struct nfs_stateid4 nfs4_stateid;
+typedef struct nfs4_stateid_struct nfs4_stateid;
 
 enum nfs_opnum4 {
 	OP_ACCESS = 3,
-- 
2.5.5

