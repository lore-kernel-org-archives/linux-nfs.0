Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:48058 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246Ab1FNCcI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:32:08 -0400
Message-Id: <13cf4de0b8f5a5652bc983789801e45830dea015.1308017749.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 01/33] pnfs: GETDEVICELIST
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:32:00 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

The block driver uses GETDEVICELIST

Signed-off-by: Andy Adamson <andros@netapp.com>
[pass struct nfs_server * to getdevicelist]
[get machince creds for getdevicelist]
[fix getdevicelist decode sizing]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 fs/nfs/nfs4proc.c       |   48 ++++++++++++++++++
 fs/nfs/nfs4xdr.c        |  128 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h           |   12 ++++
 include/linux/nfs4.h    |    1 +
 include/linux/nfs_xdr.h |   11 ++++
 5 files changed, 200 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3ca4497..ec580a8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5759,6 +5759,54 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
 	return status;
 }
 
+/*
+ * Retrieve the list of Data Server devices from the MDS.
+ */
+static int _nfs4_getdevicelist(struct nfs_server *server,
+				    const struct nfs_fh *fh,
+				    struct pnfs_devicelist *devlist)
+{
+	struct nfs4_getdevicelist_args args = {
+		.fh = fh,
+		.layoutclass = server->pnfs_curr_ld->id,
+	};
+	struct nfs4_getdevicelist_res res = {
+		.devlist = devlist,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETDEVICELIST],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	int status;
+
+	dprintk("--> %s\n", __func__);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args,
+				&res.seq_res, 0);
+	dprintk("<-- %s status=%d\n", __func__, status);
+	return status;
+}
+
+int nfs4_proc_getdevicelist(struct nfs_server *server,
+			    const struct nfs_fh *fh,
+			    struct pnfs_devicelist *devlist)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
+	do {
+		err = nfs4_handle_exception(server,
+				_nfs4_getdevicelist(server, fh, devlist),
+				&exception);
+	} while (exception.retry);
+
+	dprintk("%s: err=%d, num_devs=%u\n", __func__,
+		err, devlist->num_devs);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(nfs4_proc_getdevicelist);
+
 static int
 _nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c4b7d6c..60e9d44 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -314,6 +314,17 @@ static int nfs4_stat_to_errno(int);
 				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
 #define encode_reclaim_complete_maxsz	(op_encode_hdr_maxsz + 4)
 #define decode_reclaim_complete_maxsz	(op_decode_hdr_maxsz + 4)
+#define encode_getdevicelist_maxsz (op_encode_hdr_maxsz + 4 + \
+				encode_verifier_maxsz)
+#define decode_getdevicelist_maxsz (op_decode_hdr_maxsz + \
+				2 /* nfs_cookie4 gdlr_cookie */ + \
+				decode_verifier_maxsz \
+				  /* verifier4 gdlr_verifier */ + \
+				1 /* gdlr_deviceid_list count */ + \
+				XDR_QUADLEN(NFS4_PNFS_GETDEVLIST_MAXNUM * \
+					    NFS4_DEVICEID4_SIZE) \
+				  /* gdlr_deviceid_list */ + \
+				1 /* bool gdlr_eof */)
 #define encode_getdeviceinfo_maxsz (op_encode_hdr_maxsz + 4 + \
 				XDR_QUADLEN(NFS4_DEVICEID4_SIZE))
 #define decode_getdeviceinfo_maxsz (op_decode_hdr_maxsz + \
@@ -740,6 +751,14 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_reclaim_complete_sz	(compound_decode_hdr_maxsz + \
 					 decode_sequence_maxsz + \
 					 decode_reclaim_complete_maxsz)
+#define NFS4_enc_getdevicelist_sz (compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
+				encode_putfh_maxsz + \
+				encode_getdevicelist_maxsz)
+#define NFS4_dec_getdevicelist_sz (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
+				decode_putfh_maxsz + \
+				decode_getdevicelist_maxsz)
 #define NFS4_enc_getdeviceinfo_sz (compound_encode_hdr_maxsz +    \
 				encode_sequence_maxsz +\
 				encode_getdeviceinfo_maxsz)
@@ -1827,6 +1846,26 @@ static void encode_sequence(struct xdr_stream *xdr,
 
 #ifdef CONFIG_NFS_V4_1
 static void
+encode_getdevicelist(struct xdr_stream *xdr,
+		     const struct nfs4_getdevicelist_args *args,
+		     struct compound_hdr *hdr)
+{
+	__be32 *p;
+	nfs4_verifier dummy = {
+		.data = "dummmmmy",
+	};
+
+	p = reserve_space(xdr, 20);
+	*p++ = cpu_to_be32(OP_GETDEVICELIST);
+	*p++ = cpu_to_be32(args->layoutclass);
+	*p++ = cpu_to_be32(NFS4_PNFS_GETDEVLIST_MAXNUM);
+	xdr_encode_hyper(p, 0ULL);                          /* cookie */
+	encode_nfs4_verifier(xdr, &dummy);
+	hdr->nops++;
+	hdr->replen += decode_getdevicelist_maxsz;
+}
+
+static void
 encode_getdeviceinfo(struct xdr_stream *xdr,
 		     const struct nfs4_getdeviceinfo_args *args,
 		     struct compound_hdr *hdr)
@@ -2707,6 +2746,24 @@ static void nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req,
 }
 
 /*
+ * Encode GETDEVICELIST request
+ */
+static void nfs4_xdr_enc_getdevicelist(struct rpc_rqst *req,
+				       struct xdr_stream *xdr,
+				       struct nfs4_getdevicelist_args *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_getdevicelist(xdr, args, &hdr);
+	encode_nops(&hdr);
+}
+
+/*
  * Encode GETDEVICEINFO request
  */
 static void nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
@@ -5141,6 +5198,50 @@ out_overflow:
 }
 
 #if defined(CONFIG_NFS_V4_1)
+/*
+ * TODO: Need to handle case when EOF != true;
+ */
+static int decode_getdevicelist(struct xdr_stream *xdr,
+				struct pnfs_devicelist *res)
+{
+	__be32 *p;
+	int status, i;
+	struct nfs_writeverf verftemp;
+
+	status = decode_op_hdr(xdr, OP_GETDEVICELIST);
+	if (status)
+		return status;
+
+	p = xdr_inline_decode(xdr, 8 + 8 + 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	/* TODO: Skip cookie for now */
+	p += 2;
+
+	/* Read verifier */
+	p = xdr_decode_opaque_fixed(p, verftemp.verifier, 8);
+
+	res->num_devs = be32_to_cpup(p);
+
+	dprintk("%s: num_dev %d\n", __func__, res->num_devs);
+
+	if (res->num_devs > NFS4_PNFS_GETDEVLIST_MAXNUM)
+		return -NFS4ERR_REP_TOO_BIG;
+
+	p = xdr_inline_decode(xdr,
+			      res->num_devs * NFS4_DEVICEID4_SIZE + 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	for (i = 0; i < res->num_devs; i++)
+		p = xdr_decode_opaque_fixed(p, res->dev_id[i].data,
+					    NFS4_DEVICEID4_SIZE);
+	res->eof = be32_to_cpup(p);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
 
 static int decode_getdeviceinfo(struct xdr_stream *xdr,
 				struct pnfs_device *pdev)
@@ -6366,6 +6467,32 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp,
 }
 
 /*
+ * Decode GETDEVICELIST response
+ */
+static int nfs4_xdr_dec_getdevicelist(struct rpc_rqst *rqstp,
+				      struct xdr_stream *xdr,
+				      struct nfs4_getdevicelist_res *res)
+{
+	struct compound_hdr hdr;
+	int status;
+
+	dprintk("encoding getdevicelist!\n");
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (status != 0)
+		goto out;
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
+	if (status != 0)
+		goto out;
+	status = decode_putfh(xdr);
+	if (status != 0)
+		goto out;
+	status = decode_getdevicelist(xdr, res->devlist);
+out:
+	return status;
+}
+
+/*
  * Decode GETDEVINFO response
  */
 static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp,
@@ -6663,6 +6790,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(LAYOUTGET,		enc_layoutget,		dec_layoutget),
 	PROC(LAYOUTCOMMIT,	enc_layoutcommit,	dec_layoutcommit),
 	PROC(LAYOUTRETURN,	enc_layoutreturn,	dec_layoutreturn),
+	PROC(GETDEVICELIST,	enc_getdevicelist,	dec_getdevicelist),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f2b183b..9dc950c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -133,14 +133,26 @@ struct pnfs_device {
 	unsigned int  layout_type;
 	unsigned int  mincount;
 	struct page **pages;
+	void          *area;
 	unsigned int  pgbase;
 	unsigned int  pglen;
 };
 
+#define NFS4_PNFS_GETDEVLIST_MAXNUM 16
+
+struct pnfs_devicelist {
+	unsigned int		eof;
+	unsigned int		num_devs;
+	struct nfs4_deviceid	dev_id[NFS4_PNFS_GETDEVLIST_MAXNUM];
+};
+
 extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
 extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
 
 /* nfs4proc.c */
+extern int nfs4_proc_getdevicelist(struct nfs_server *server,
+				   const struct nfs_fh *fh,
+				   struct pnfs_devicelist *devlist);
 extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
 extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 504b289..7915d41 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -560,6 +560,7 @@ enum {
 	NFSPROC4_CLNT_GET_LEASE_TIME,
 	NFSPROC4_CLNT_RECLAIM_COMPLETE,
 	NFSPROC4_CLNT_LAYOUTGET,
+	NFSPROC4_CLNT_GETDEVICELIST,
 	NFSPROC4_CLNT_GETDEVICEINFO,
 	NFSPROC4_CLNT_LAYOUTCOMMIT,
 	NFSPROC4_CLNT_LAYOUTRETURN,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 00848d8..0863228 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -235,6 +235,17 @@ struct nfs4_layoutget {
 	gfp_t gfp_flags;
 };
 
+struct nfs4_getdevicelist_args {
+	const struct nfs_fh *fh;
+	u32 layoutclass;
+	struct nfs4_sequence_args seq_args;
+};
+
+struct nfs4_getdevicelist_res {
+	struct pnfs_devicelist *devlist;
+	struct nfs4_sequence_res seq_res;
+};
+
 struct nfs4_getdeviceinfo_args {
 	struct pnfs_device *pdev;
 	struct nfs4_sequence_args seq_args;
-- 
1.7.4.1

