Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:2209 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755368AbaIZR6d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 13:58:33 -0400
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 2/2] NFSD: Implement SEEK
Date: Fri, 26 Sep 2014 13:58:27 -0400
Message-ID: <1411754307-18457-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1411754307-18457-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1411754307-18457-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

This patch adds server support for the NFS v4.2 operation SEEK, which
returns the position of the next hole or data segment in a file.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4proc.c   | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 36 ++++++++++++++++++++++++++++++++++--
 fs/nfsd/xdr4.h       | 14 ++++++++++++++
 include/linux/nfs4.h |  5 +++++
 4 files changed, 102 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5e0dc52..cdeb3cf 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1013,6 +1013,49 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
+static __be32
+nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_seek *seek)
+{
+	int whence;
+	__be32 status;
+	struct file *file;
+
+	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
+					    &seek->seek_stateid,
+					    RD_STATE, &file);
+	if (status) {
+		dprintk("NFSD: nfsd4_seek: couldn't process stateid!\n");
+		return status;
+	}
+
+	switch (seek->seek_whence) {
+	case NFS4_CONTENT_DATA:
+		whence = SEEK_DATA;
+		break;
+	case NFS4_CONTENT_HOLE:
+		whence = SEEK_HOLE;
+		break;
+	default:
+		status = nfserr_union_notsupp;
+		goto out;
+	}
+
+	/*
+	 * Note:  This call does change file->f_pos, but nothing in NFSD
+	 *        should ever file->f_pos.
+	 */
+	seek->seek_pos = vfs_llseek(file, seek->seek_offset, whence);
+	if (seek->seek_pos < 0)
+		status = nfserrno(seek->seek_pos);
+	else if (seek->seek_pos >= i_size_read(file_inode(file)))
+		seek->seek_eof = true;
+
+out:
+	fput(file);
+	return status;
+}
+
 /* This routine never returns NFS_OK!  If there are no other errors, it
  * will return NFSERR_SAME or NFSERR_NOT_SAME depending on whether the
  * attributes matched.  VERIFY is implemented by mapping NFSERR_SAME
@@ -1881,6 +1924,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_freestateid,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
+
+	/* NFSv4.2 operations */
+	[OP_SEEK] = {
+		.op_func = (nfsd4op_func)nfsd4_seek,
+		.op_name = "OP_SEEK",
+	},
 };
 
 int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 94dde7b..d20e0a5 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1521,6 +1521,22 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 }
 
 static __be32
+nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
+{
+	DECODE_HEAD;
+
+	status = nfsd4_decode_stateid(argp, &seek->seek_stateid);
+	if (status)
+		return status;
+
+	READ_BUF(8 + 4);
+	p = xdr_decode_hyper(p, &seek->seek_offset);
+	seek->seek_whence = be32_to_cpup(p);
+
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
 {
 	return nfs_ok;
@@ -1605,7 +1621,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
 	[OP_WRITE_SAME]		= (nfsd4_dec)nfsd4_decode_notsupp,
 };
 
@@ -3765,6 +3781,22 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 }
 
 static __be32
+nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
+		  struct nfsd4_seek *seek)
+{
+	__be32 *p;
+
+	if (nfserr)
+		return nfserr;
+
+	p = xdr_reserve_space(&resp->xdr, 4 + 8);
+	*p++ = cpu_to_be32(seek->seek_eof);
+	p = xdr_encode_hyper(p, seek->seek_pos);
+
+	return nfserr;
+}
+
+static __be32
 nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
 {
 	return nfserr;
@@ -3848,7 +3880,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_OFFLOAD_CANCEL]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
 	[OP_WRITE_SAME]		= (nfsd4_enc)nfsd4_encode_noop,
 };
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 465e779..5720e94 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -428,6 +428,17 @@ struct nfsd4_reclaim_complete {
 	u32 rca_one_fs;
 };
 
+struct nfsd4_seek {
+	/* request */
+	stateid_t	seek_stateid;
+	loff_t		seek_offset;
+	u32		seek_whence;
+
+	/* response */
+	u32		seek_eof;
+	loff_t		seek_pos;
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -473,6 +484,9 @@ struct nfsd4_op {
 		struct nfsd4_reclaim_complete	reclaim_complete;
 		struct nfsd4_test_stateid	test_stateid;
 		struct nfsd4_free_stateid	free_stateid;
+
+		/* NFSv4.2 */
+		struct nfsd4_seek		seek;
 	} u;
 	struct nfs4_replay *			replay;
 };
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index cf38224..026b0c0 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -550,4 +550,9 @@ struct nfs4_deviceid {
 	char data[NFS4_DEVICEID4_SIZE];
 };
 
+enum data_content4 {
+	NFS4_CONTENT_DATA		= 0,
+	NFS4_CONTENT_HOLE		= 1,
+};
+
 #endif
-- 
2.1.0

