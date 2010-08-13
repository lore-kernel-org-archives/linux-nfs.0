Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45275 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754293Ab0HMVdU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:33:20 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 43/50] pnfs_submit: data server commit with no getattr
Date: Fri, 13 Aug 2010 17:31:55 -0400
Message-Id: <1281735122-1496-44-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-43-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
 <1281735122-1496-32-git-send-email-andros@netapp.com>
 <1281735122-1496-33-git-send-email-andros@netapp.com>
 <1281735122-1496-34-git-send-email-andros@netapp.com>
 <1281735122-1496-35-git-send-email-andros@netapp.com>
 <1281735122-1496-36-git-send-email-andros@netapp.com>
 <1281735122-1496-37-git-send-email-andros@netapp.com>
 <1281735122-1496-38-git-send-email-andros@netapp.com>
 <1281735122-1496-39-git-send-email-andros@netapp.com>
 <1281735122-1496-40-git-send-email-andros@netapp.com>
 <1281735122-1496-41-git-send-email-andros@netapp.com>
 <1281735122-1496-42-git-send-email-andros@netapp.com>
 <1281735122-1496-43-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c    |    6 ++++++
 fs/nfs/nfs4xdr.c     |   50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h |    1 +
 3 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 55aba4c..8879fab 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3262,6 +3262,12 @@ static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_messa
 	
 	data->args.bitmask = server->cache_consistency_bitmask;
 	data->res.server = server;
+#if defined(CONFIG_NFS_V4_1)
+	if (data->fldata.ds_nfs_client) {
+		msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_COMMIT];
+		return;
+	}
+#endif /* CONFIG_NFS_V4_1 */
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
 }
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 520b589..bb2cb86 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -765,6 +765,12 @@ static int nfs4_stat_to_errno(int);
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_write_maxsz)
+#define NFS4_enc_dscommit_sz	(compound_encode_hdr_maxsz + \
+				encode_putfh_maxsz + \
+				encode_commit_maxsz)
+#define NFS4_dec_dscommit_sz	(compound_decode_hdr_maxsz + \
+				decode_putfh_maxsz + \
+				decode_commit_maxsz)
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -2844,6 +2850,25 @@ static int nfs4_xdr_enc_dswrite(struct rpc_rqst *req, uint32_t *p,
 	return 0;
 }
 
+/*
+ * Encode a pNFS File Layout Data Server COMMIT request
+ */
+static int nfs4_xdr_enc_dscommit(struct rpc_rqst *req, uint32_t *p,
+				 struct nfs_writeargs *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_commit(&xdr, args, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
@@ -6424,6 +6449,30 @@ out:
 	return status;
 }
 
+/*
+ * Decode pNFS File Layout Data Server COMMIT response
+ */
+static int nfs4_xdr_dec_dscommit(struct rpc_rqst *rqstp, uint32_t *p,
+				 struct nfs_writeres *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status)
+		goto out;
+	status = decode_commit(&xdr, res);
+out:
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
@@ -6607,6 +6656,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(PNFS_LAYOUTCOMMIT, enc_layoutcommit,  dec_layoutcommit),
   PROC(PNFS_LAYOUTRETURN, enc_layoutreturn,  dec_layoutreturn),
   PROC(PNFS_WRITE, enc_dswrite,  dec_dswrite),
+  PROC(PNFS_COMMIT, enc_dscommit,  dec_dscommit),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index d5509b7..6ee7357 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -558,6 +558,7 @@ enum {
 	NFSPROC4_CLNT_PNFS_LAYOUTRETURN,
 	NFSPROC4_CLNT_PNFS_GETDEVICEINFO,
 	NFSPROC4_CLNT_PNFS_WRITE,
+	NFSPROC4_CLNT_PNFS_COMMIT,
 };
 
 /* nfs41 types */
-- 
1.6.2.5

