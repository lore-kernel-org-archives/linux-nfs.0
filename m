Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45275 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754404Ab0HMVdT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:33:19 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netpp.com>
Subject: [PATCH 39/50] pnfs_submit: data server write with no getattr
Date: Fri, 13 Aug 2010 17:31:51 -0400
Message-Id: <1281735122-1496-40-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-39-git-send-email-andros@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netpp.com>
---
 fs/nfs/nfs4proc.c    |    8 ++++++-
 fs/nfs/nfs4xdr.c     |   58 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h |    1 +
 3 files changed, 66 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a6a0e7e..44ffa33 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3220,13 +3220,19 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 	data->res.server = server;
 	data->timestamp   = jiffies;
 
+#ifdef CONFIG_NFS_V4_1
+	/* writes to DS use pnfs vector */
+	if (data->fldata.ds_nfs_client) {
+		msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_WRITE];
+		return;
+	}
+#endif /* CONFIG_NFS_V4_1 */
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE];
 }
 
 static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
-	
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 82a3412..520b589 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -757,6 +757,14 @@ static int nfs4_stat_to_errno(int);
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_layoutreturn_maxsz)
+#define NFS4_enc_dswrite_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz +\
+				encode_putfh_maxsz + \
+				encode_write_maxsz)
+#define NFS4_dec_dswrite_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
+				decode_putfh_maxsz + \
+				decode_write_maxsz)
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -2815,6 +2823,27 @@ static int nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req, uint32_t *p,
 	encode_nops(&hdr);
 	return 0;
 }
+
+/*
+ * Encode a pNFS File Layout Data Server WRITE request
+ */
+static int nfs4_xdr_enc_dswrite(struct rpc_rqst *req, uint32_t *p,
+				struct nfs_writeargs *args)
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
+	encode_write(&xdr, args, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
@@ -6367,6 +6396,34 @@ static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp, uint32_t *p,
 out:
 	return status;
 }
+
+/*
+ * Decode pNFS File Layout Data Server WRITE response
+ */
+static int nfs4_xdr_dec_dswrite(struct rpc_rqst *rqstp, uint32_t *p,
+				struct nfs_writeres *res)
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
+	status = decode_write(&xdr, res);
+	if (!status)
+		return res->count;
+out:
+	return status;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
@@ -6549,6 +6606,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(PNFS_LAYOUTGET,  enc_layoutget,     dec_layoutget),
   PROC(PNFS_LAYOUTCOMMIT, enc_layoutcommit,  dec_layoutcommit),
   PROC(PNFS_LAYOUTRETURN, enc_layoutreturn,  dec_layoutreturn),
+  PROC(PNFS_WRITE, enc_dswrite,  dec_dswrite),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 2737013..d5509b7 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -557,6 +557,7 @@ enum {
 	NFSPROC4_CLNT_PNFS_LAYOUTCOMMIT,
 	NFSPROC4_CLNT_PNFS_LAYOUTRETURN,
 	NFSPROC4_CLNT_PNFS_GETDEVICEINFO,
+	NFSPROC4_CLNT_PNFS_WRITE,
 };
 
 /* nfs41 types */
-- 
1.6.2.5

