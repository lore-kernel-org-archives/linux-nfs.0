From: andros@netapp.com
Subject: [PATCH 01/13] SQUASHME pnfs_submit: remove GETDEVICELIST
Date: Wed, 28 Apr 2010 18:24:13 -0400
Message-ID: <1272493465-3398-2-git-send-email-andros@netapp.com>
References: <1272493465-3398-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24626 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932231Ab0D1VYc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 17:24:32 -0400
In-Reply-To: <1272493465-3398-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The file layout driver does not use GETDEVICELIST

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c         |   47 -----------------
 fs/nfs/nfs4xdr.c          |  126 ---------------------------------------------
 fs/nfs/pnfs.c             |    1 -
 fs/nfs/pnfs.h             |    3 -
 include/linux/nfs4.h      |    1 -
 include/linux/nfs4_pnfs.h |    2 -
 include/linux/pnfs_xdr.h  |   11 ----
 7 files changed, 0 insertions(+), 191 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e5faf09..0d7b6d7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5764,53 +5764,6 @@ out:
 	return status;
 }
 
-/*
- * Retrieve the list of Data Server devices from the MDS.
- */
-static int _nfs4_pnfs_getdevicelist(struct nfs_fh *fh,
-				    struct nfs_server *server,
-				    struct pnfs_devicelist *devlist)
-{
-	struct nfs4_pnfs_getdevicelist_arg arg = {
-		.fh = fh,
-		.layoutclass = server->pnfs_curr_ld->id,
-	};
-	struct nfs4_pnfs_getdevicelist_res res = {
-		.devlist = devlist,
-	};
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_GETDEVICELIST],
-		.rpc_argp = &arg,
-		.rpc_resp = &res,
-	};
-	int status;
-
-	dprintk("--> %s\n", __func__);
-	status = nfs4_call_sync(server, &msg, &arg, &res, 0);
-	dprintk("<-- %s status=%d\n", __func__, status);
-	return status;
-}
-
-int nfs4_pnfs_getdevicelist(struct super_block *sb,
-			    struct nfs_fh *fh,
-			    struct pnfs_devicelist *devlist)
-{
-	struct nfs4_exception exception = { };
-	struct nfs_server *server = NFS_SB(sb);
-	int err;
-
-	do {
-		err = nfs4_handle_exception(server,
-				_nfs4_pnfs_getdevicelist(fh, server, devlist),
-				&exception);
-	} while (exception.retry);
-
-	dprintk("nfs4_pnfs_getdevlist: err=%d, num_devs=%u\n",
-		err, devlist->num_devs);
-
-	return err;
-}
-
 int nfs4_pnfs_getdeviceinfo(struct super_block *sb, struct pnfs_device *pdev)
 {
 	struct nfs_server *server = NFS_SB(sb);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1a9e5e7..7089284 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -305,12 +305,6 @@ static int nfs4_stat_to_errno(int);
 				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
 #define encode_reclaim_complete_maxsz	(op_encode_hdr_maxsz + 4)
 #define decode_reclaim_complete_maxsz	(op_decode_hdr_maxsz + 4)
-#define encode_getdevicelist_maxsz (op_encode_hdr_maxsz + 4 + \
-				encode_verifier_maxsz)
-#define decode_getdevicelist_maxsz (op_decode_hdr_maxsz + 2 + 1 + 1 +  \
-				decode_verifier_maxsz +             \
-				XDR_QUADLEN(NFS4_PNFS_GETDEVLIST_MAXNUM *  \
-				NFS4_PNFS_DEVICEID4_SIZE))
 #define encode_getdeviceinfo_maxsz (op_encode_hdr_maxsz + 4 + \
 				XDR_QUADLEN(NFS4_PNFS_DEVICEID4_SIZE))
 #define decode_getdeviceinfo_maxsz (op_decode_hdr_maxsz + \
@@ -717,14 +711,6 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_reclaim_complete_sz	(compound_decode_hdr_maxsz + \
 					 decode_sequence_maxsz + \
 					 decode_reclaim_complete_maxsz)
-#define NFS4_enc_getdevicelist_sz (compound_encode_hdr_maxsz + \
-				encode_sequence_maxsz + \
-				encode_putfh_maxsz + \
-				encode_getdevicelist_maxsz)
-#define NFS4_dec_getdevicelist_sz (compound_decode_hdr_maxsz + \
-				decode_sequence_maxsz + \
-				decode_putfh_maxsz + \
-				decode_getdevicelist_maxsz)
 #define NFS4_enc_getdeviceinfo_sz (compound_encode_hdr_maxsz +    \
 				encode_sequence_maxsz +\
 				encode_getdeviceinfo_maxsz)
@@ -1813,25 +1799,6 @@ static void encode_sequence(struct xdr_stream *xdr,
 
 #ifdef CONFIG_NFS_V4_1
 static void
-encode_getdevicelist(struct xdr_stream *xdr,
-		     const struct nfs4_pnfs_getdevicelist_arg *args,
-		     struct compound_hdr *hdr)
-{
-	__be32 *p;
-	nfs4_verifier dummy = {
-		.data = "dummmmmy",
-	};
-
-	p = reserve_space(xdr, 20);
-	*p++ = cpu_to_be32(OP_GETDEVICELIST);
-	*p++ = cpu_to_be32(args->layoutclass);
-	*p++ = cpu_to_be32(NFS4_PNFS_GETDEVLIST_MAXNUM);
-	xdr_encode_hyper(p, 0ULL);                          /* cookie */
-	encode_nfs4_verifier(xdr, &dummy);
-	hdr->nops++;
-}
-
-static void
 encode_getdeviceinfo(struct xdr_stream *xdr,
 		     const struct nfs4_pnfs_getdeviceinfo_arg *args,
 		     struct compound_hdr *hdr)
@@ -2768,27 +2735,6 @@ static int nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req, uint32_t *p,
 }
 
 /*
- * Encode GETDEVICELIST request
- */
-static int
-nfs4_xdr_enc_getdevicelist(struct rpc_rqst *req, uint32_t *p,
-			   struct nfs4_pnfs_getdevicelist_arg *args)
-{
-	struct xdr_stream xdr;
-	struct compound_hdr hdr = {
-		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
-	};
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, args->fh, &hdr);
-	encode_getdevicelist(&xdr, args, &hdr);
-	encode_nops(&hdr);
-	return 0;
-}
-
-/*
  * Encode GETDEVICEINFO request
  */
 static int nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req, uint32_t *p,
@@ -5168,50 +5114,6 @@ out_overflow:
 }
 
 #if defined(CONFIG_NFS_V4_1)
-/*
- * TODO: Need to handle case when EOF != true;
- */
-static int decode_getdevicelist(struct xdr_stream *xdr,
-				struct pnfs_devicelist *res)
-{
-	__be32 *p;
-	int status, i;
-	struct nfs_writeverf verftemp;
-
-	status = decode_op_hdr(xdr, OP_GETDEVICELIST);
-	if (status)
-		return status;
-
-	p = xdr_inline_decode(xdr, 8 + 8 + 4);
-	if (unlikely(!p))
-		goto out_overflow;
-
-	/* TODO: Skip cookie for now */
-	p += 2;
-
-	/* Read verifier */
-	p = xdr_decode_opaque_fixed(p, verftemp.verifier, 8);
-
-	res->num_devs = be32_to_cpup(p);
-
-	dprintk("%s: num_dev %d \n", __func__, res->num_devs);
-
-	if (res->num_devs > NFS4_PNFS_GETDEVLIST_MAXNUM)
-		return -NFS4ERR_REP_TOO_BIG;
-
-	p = xdr_inline_decode(xdr,
-			      res->num_devs * NFS4_PNFS_DEVICEID4_SIZE + 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	for (i = 0; i < res->num_devs; i++)
-		p = xdr_decode_opaque_fixed(p, res->dev_id[i].data,
-					    NFS4_PNFS_DEVICEID4_SIZE);
-	res->eof = be32_to_cpup(p);
-	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
-}
 
 static int decode_getdeviceinfo(struct xdr_stream *xdr,
 				struct pnfs_device *pdev)
@@ -6403,33 +6305,6 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp, uint32_t *p,
 }
 
 /*
- * Decode GETDEVICELIST response
- */
-static int nfs4_xdr_dec_getdevicelist(struct rpc_rqst *rqstp, uint32_t *p,
-				      struct nfs4_pnfs_getdevicelist_res *res)
-{
-	struct xdr_stream xdr;
-	struct compound_hdr hdr;
-	int status;
-
-	dprintk("encoding getdevicelist!\n");
-
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
-	if (status != 0)
-		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
-		if (status != 0)
-goto out;
-	status = decode_putfh(&xdr);
-	if (status != 0)
-		goto out;
-	status = decode_getdevicelist(&xdr, res->devlist);
-out:
-	return status;
-}
-
-/*
  * Decode GETDEVINFO response
  */
 static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp, uint32_t *p,
@@ -6758,7 +6633,6 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(SEQUENCE,	enc_sequence,	dec_sequence),
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
   PROC(RECLAIM_COMPLETE, enc_reclaim_complete,  dec_reclaim_complete),
-  PROC(PNFS_GETDEVICELIST, enc_getdevicelist, dec_getdevicelist),
   PROC(PNFS_GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
   PROC(PNFS_LAYOUTGET,  enc_layoutget,     dec_layoutget),
   PROC(PNFS_LAYOUTCOMMIT, enc_layoutcommit,  dec_layoutcommit),
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a3e8231..fbc04c3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2293,7 +2293,6 @@ void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
 /* Callback operations for layout drivers.
  */
 struct pnfs_client_operations pnfs_ops = {
-	.nfs_getdevicelist = nfs4_pnfs_getdevicelist,
 	.nfs_getdeviceinfo = nfs4_pnfs_getdeviceinfo,
 	.nfs_readlist_complete = pnfs_read_done,
 	.nfs_writelist_complete = pnfs_writeback_done,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7dc3ecc..868c1ac 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -22,9 +22,6 @@
 #include "iostat.h"
 
 /* nfs4proc.c */
-extern int nfs4_pnfs_getdevicelist(struct super_block *sb,
-				   struct nfs_fh *fh,
-				   struct pnfs_devicelist *devlist);
 extern int nfs4_pnfs_getdeviceinfo(struct super_block *sb,
 				   struct pnfs_device *dev);
 extern int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 2bb8eeb..1730e86 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -543,7 +543,6 @@ enum {
 	NFSPROC4_CLNT_PNFS_LAYOUTGET,
 	NFSPROC4_CLNT_PNFS_LAYOUTCOMMIT,
 	NFSPROC4_CLNT_PNFS_LAYOUTRETURN,
-	NFSPROC4_CLNT_PNFS_GETDEVICELIST,
 	NFSPROC4_CLNT_PNFS_GETDEVICEINFO,
 	NFSPROC4_CLNT_PNFS_WRITE,
 	NFSPROC4_CLNT_PNFS_COMMIT,
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 3b7aeb7..ae2f7ed 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -331,8 +331,6 @@ extern void nfs4_unset_layout_deviceid(struct pnfs_layout_segment *,
  * E.g., getdeviceinfo, I/O callbacks, etc
  */
 struct pnfs_client_operations {
-	int (*nfs_getdevicelist) (struct super_block *sb, struct nfs_fh *fh,
-				  struct pnfs_devicelist *devlist);
 	int (*nfs_getdeviceinfo) (struct super_block *sb,
 				  struct pnfs_device *dev);
 
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index 4f34aa8..a0bf341 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -116,17 +116,6 @@ struct nfs4_pnfs_layoutreturn {
 	int rpc_status;
 };
 
-struct nfs4_pnfs_getdevicelist_arg {
-	const struct nfs_fh *fh;
-	u32 layoutclass;
-	struct nfs4_sequence_args seq_args;
-};
-
-struct nfs4_pnfs_getdevicelist_res {
-	struct pnfs_devicelist *devlist;
-	struct nfs4_sequence_res seq_res;
-};
-
 struct nfs4_pnfs_getdeviceinfo_arg {
 	struct pnfs_device *pdev;
 	struct nfs4_sequence_args seq_args;
-- 
1.6.6

