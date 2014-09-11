Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:53136 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbaIKAe0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 20:34:26 -0400
Received: from ip-64-134-224-54.public.wayport.net ([64.134.224.54] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRsLB-00083T-3R
	for linux-nfs@vger.kernel.org; Thu, 11 Sep 2014 00:34:25 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] pnfs: remove GETDEVICELIST implementation
Date: Wed, 10 Sep 2014 17:36:31 -0700
Message-Id: <1410395791-2385-5-git-send-email-hch@lst.de>
In-Reply-To: <1410395791-2385-1-git-send-email-hch@lst.de>
References: <1410395791-2385-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current GETDEVICELIST implementation is buggy in that it doesn't handle
cursors correctly, and in that it returns an error if the server returns
NFSERR_NOTSUPP.  Given that there is no actual need for GETDEVICELIST,
it has various issues and might get removed for NFSv4.2 stop using it in
the blocklayout driver, and thus the Linux NFS client as whole.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c |   2 +-
 fs/nfs/nfs4proc.c                |  48 ---------------
 fs/nfs/nfs4xdr.c                 | 130 ---------------------------------------
 fs/nfs/pnfs.h                    |   5 --
 fs/nfs/pnfs_dev.c                |  30 ---------
 include/linux/nfs_xdr.h          |  11 ----
 6 files changed, 1 insertion(+), 225 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 900eb09..cf10a6e 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -527,7 +527,7 @@ bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
 		return -EINVAL;
 	}
 
-	return nfs4_deviceid_getdevicelist(server, fh);
+	return 0;
 }
 
 static bool
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 47fa67a..0b71122 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7808,54 +7808,6 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
 	return status;
 }
 
-/*
- * Retrieve the list of Data Server devices from the MDS.
- */
-static int _nfs4_getdevicelist(struct nfs_server *server,
-				    const struct nfs_fh *fh,
-				    struct pnfs_devicelist *devlist)
-{
-	struct nfs4_getdevicelist_args args = {
-		.fh = fh,
-		.layoutclass = server->pnfs_curr_ld->id,
-	};
-	struct nfs4_getdevicelist_res res = {
-		.devlist = devlist,
-	};
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETDEVICELIST],
-		.rpc_argp = &args,
-		.rpc_resp = &res,
-	};
-	int status;
-
-	dprintk("--> %s\n", __func__);
-	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args,
-				&res.seq_res, 0);
-	dprintk("<-- %s status=%d\n", __func__, status);
-	return status;
-}
-
-int nfs4_proc_getdevicelist(struct nfs_server *server,
-			    const struct nfs_fh *fh,
-			    struct pnfs_devicelist *devlist)
-{
-	struct nfs4_exception exception = { };
-	int err;
-
-	do {
-		err = nfs4_handle_exception(server,
-				_nfs4_getdevicelist(server, fh, devlist),
-				&exception);
-	} while (exception.retry);
-
-	dprintk("%s: err=%d, num_devs=%u\n", __func__,
-		err, devlist->num_devs);
-
-	return err;
-}
-EXPORT_SYMBOL_GPL(nfs4_proc_getdevicelist);
-
 static int
 _nfs4_proc_getdeviceinfo(struct nfs_server *server,
 		struct pnfs_device *pdev,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f2cd957..b8165ea 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -362,17 +362,6 @@ static int nfs4_stat_to_errno(int);
 				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
 #define encode_reclaim_complete_maxsz	(op_encode_hdr_maxsz + 4)
 #define decode_reclaim_complete_maxsz	(op_decode_hdr_maxsz + 4)
-#define encode_getdevicelist_maxsz (op_encode_hdr_maxsz + 4 + \
-				encode_verifier_maxsz)
-#define decode_getdevicelist_maxsz (op_decode_hdr_maxsz + \
-				2 /* nfs_cookie4 gdlr_cookie */ + \
-				decode_verifier_maxsz \
-				  /* verifier4 gdlr_verifier */ + \
-				1 /* gdlr_deviceid_list count */ + \
-				XDR_QUADLEN(NFS4_PNFS_GETDEVLIST_MAXNUM * \
-					    NFS4_DEVICEID4_SIZE) \
-				  /* gdlr_deviceid_list */ + \
-				1 /* bool gdlr_eof */)
 #define encode_getdeviceinfo_maxsz (op_encode_hdr_maxsz + 4 + \
 				XDR_QUADLEN(NFS4_DEVICEID4_SIZE))
 #define decode_getdeviceinfo_maxsz (op_decode_hdr_maxsz + \
@@ -812,14 +801,6 @@ static int nfs4_stat_to_errno(int);
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
@@ -1930,24 +1911,6 @@ static void encode_sequence(struct xdr_stream *xdr,
 
 #ifdef CONFIG_NFS_V4_1
 static void
-encode_getdevicelist(struct xdr_stream *xdr,
-		     const struct nfs4_getdevicelist_args *args,
-		     struct compound_hdr *hdr)
-{
-	__be32 *p;
-	nfs4_verifier dummy = {
-		.data = "dummmmmy",
-	};
-
-	encode_op_hdr(xdr, OP_GETDEVICELIST, decode_getdevicelist_maxsz, hdr);
-	p = reserve_space(xdr, 16);
-	*p++ = cpu_to_be32(args->layoutclass);
-	*p++ = cpu_to_be32(NFS4_PNFS_GETDEVLIST_MAXNUM);
-	xdr_encode_hyper(p, 0ULL);                          /* cookie */
-	encode_nfs4_verifier(xdr, &dummy);
-}
-
-static void
 encode_getdeviceinfo(struct xdr_stream *xdr,
 		     const struct nfs4_getdeviceinfo_args *args,
 		     struct compound_hdr *hdr)
@@ -2901,24 +2864,6 @@ static void nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req,
 }
 
 /*
- * Encode GETDEVICELIST request
- */
-static void nfs4_xdr_enc_getdevicelist(struct rpc_rqst *req,
-				       struct xdr_stream *xdr,
-				       struct nfs4_getdevicelist_args *args)
-{
-	struct compound_hdr hdr = {
-		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
-	};
-
-	encode_compound_hdr(xdr, req, &hdr);
-	encode_sequence(xdr, &args->seq_args, &hdr);
-	encode_putfh(xdr, args->fh, &hdr);
-	encode_getdevicelist(xdr, args, &hdr);
-	encode_nops(&hdr);
-}
-
-/*
  * Encode GETDEVICEINFO request
  */
 static void nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
@@ -5773,54 +5718,6 @@ out_overflow:
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
-	nfs4_verifier verftemp;
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
-	p = xdr_decode_opaque_fixed(p, verftemp.data, NFS4_VERIFIER_SIZE);
-
-	res->num_devs = be32_to_cpup(p);
-
-	dprintk("%s: num_dev %d\n", __func__, res->num_devs);
-
-	if (res->num_devs > NFS4_PNFS_GETDEVLIST_MAXNUM) {
-		printk(KERN_ERR "NFS: %s too many result dev_num %u\n",
-				__func__, res->num_devs);
-		return -EIO;
-	}
-
-	p = xdr_inline_decode(xdr,
-			      res->num_devs * NFS4_DEVICEID4_SIZE + 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	for (i = 0; i < res->num_devs; i++)
-		p = xdr_decode_opaque_fixed(p, res->dev_id[i].data,
-					    NFS4_DEVICEID4_SIZE);
-	res->eof = be32_to_cpup(p);
-	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
-}
-
 static int decode_getdeviceinfo(struct xdr_stream *xdr,
 				struct pnfs_device *pdev)
 {
@@ -7105,32 +7002,6 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp,
 }
 
 /*
- * Decode GETDEVICELIST response
- */
-static int nfs4_xdr_dec_getdevicelist(struct rpc_rqst *rqstp,
-				      struct xdr_stream *xdr,
-				      struct nfs4_getdevicelist_res *res)
-{
-	struct compound_hdr hdr;
-	int status;
-
-	dprintk("encoding getdevicelist!\n");
-
-	status = decode_compound_hdr(xdr, &hdr);
-	if (status != 0)
-		goto out;
-	status = decode_sequence(xdr, &res->seq_res, rqstp);
-	if (status != 0)
-		goto out;
-	status = decode_putfh(xdr);
-	if (status != 0)
-		goto out;
-	status = decode_getdevicelist(xdr, res->devlist);
-out:
-	return status;
-}
-
-/*
  * Decode GETDEVINFO response
  */
 static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp,
@@ -7498,7 +7369,6 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(SECINFO_NO_NAME,	enc_secinfo_no_name,	dec_secinfo_no_name),
 	PROC(TEST_STATEID,	enc_test_stateid,	dec_test_stateid),
 	PROC(FREE_STATEID,	enc_free_stateid,	dec_free_stateid),
-	PROC(GETDEVICELIST,	enc_getdevicelist,	dec_getdevicelist),
 	PROC(BIND_CONN_TO_SESSION,
 			enc_bind_conn_to_session, dec_bind_conn_to_session),
 	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d84fe29..b10f12f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -180,9 +180,6 @@ extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
 extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
 
 /* nfs4proc.c */
-extern int nfs4_proc_getdevicelist(struct nfs_server *server,
-				   const struct nfs_fh *fh,
-				   struct pnfs_devicelist *devlist);
 extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev,
 				   struct rpc_cred *cred);
@@ -277,8 +274,6 @@ bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
 void nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node);
 bool nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node);
 void nfs4_deviceid_purge_client(const struct nfs_client *);
-int nfs4_deviceid_getdevicelist(struct nfs_server *server,
-		const struct nfs_fh *fh);
 
 static inline struct nfs4_deviceid_node *
 nfs4_get_deviceid(struct nfs4_deviceid_node *d)
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 82c2836..aa2ec00 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -358,33 +358,3 @@ nfs4_deviceid_mark_client_invalid(struct nfs_client *clp)
 	}
 	rcu_read_unlock();
 }
-
-int
-nfs4_deviceid_getdevicelist(struct nfs_server *server,
-		const struct nfs_fh *fh)
-{
-	struct pnfs_devicelist *dlist;
-	struct nfs4_deviceid_node *d;
-	int error = 0, i;
-
-	dlist = kzalloc(sizeof(struct pnfs_devicelist), GFP_NOFS);
-	if (!dlist)
-		return -ENOMEM;
-
-	while (!dlist->eof) {
-		error = nfs4_proc_getdevicelist(server, fh, dlist);
-		if (error)
-			break;
-
-		for (i = 0; i < dlist->num_devs; i++) {
-			d = nfs4_find_get_deviceid(server, &dlist->dev_id[i],
-					NULL, GFP_NOFS);
-			if (d)
-				nfs4_put_deviceid_node(d);
-		}
-	}
-
-	kfree(dlist);
-	return error;
-}
-EXPORT_SYMBOL_GPL(nfs4_deviceid_getdevicelist);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f4092c6..7ae249c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -252,17 +252,6 @@ struct nfs4_layoutget {
 	gfp_t gfp_flags;
 };
 
-struct nfs4_getdevicelist_args {
-	struct nfs4_sequence_args seq_args;
-	const struct nfs_fh *fh;
-	u32 layoutclass;
-};
-
-struct nfs4_getdevicelist_res {
-	struct nfs4_sequence_res seq_res;
-	struct pnfs_devicelist *devlist;
-};
-
 struct nfs4_getdeviceinfo_args {
 	struct nfs4_sequence_args seq_args;
 	struct pnfs_device *pdev;
-- 
1.9.1

