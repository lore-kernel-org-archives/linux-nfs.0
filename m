Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:49997 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933852AbaH0PSH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2014 11:18:07 -0400
From: <bjschuma@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] NFSD: Implement SEEK
Date: Wed, 27 Aug 2014 11:17:58 -0400
Message-ID: <1409152678-7806-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1409152678-7806-1-git-send-email-bjschuma@netapp.com>
References: <1409152678-7806-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

This patch adds server support for the NFS v4.2 operation SEEK, which
returns the position of the next hole or data segment in a file.  This
operation is off by default, and needs CONFIG_NFSD_V4_2_SEEK=y to be
compiled.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/Kconfig      | 12 ++++++++++++
 fs/nfsd/nfs4proc.c   | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 45 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/xdr4.h       | 14 ++++++++++++++
 include/linux/nfs4.h |  5 +++++
 5 files changed, 123 insertions(+)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index f994e75..804b20a 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -81,6 +81,18 @@ config NFSD_V4
 
 	  If unsure, say N.
 
+config NFSD_V4_2_SEEK
+	bool "Enable SEEK support for the NFS v4.2 server"
+	depends on NFSD_V4
+	help
+	  Say Y here if you want to enable support for the NFS v4.2 operation
+	  SEEK, which adds in SEEK_HOLE and SEEK_DATA support.
+
+	  WARNING: there is still a chance of backwards-incompatible protocol
+	  changes.  This feature is targeted at developers and testers only.
+
+	  If unsure, say N.
+
 config NFSD_V4_SECURITY_LABEL
 	bool "Provide Security Label support for NFSv4 server"
 	depends on NFSD_V4 && SECURITY
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5e0dc52..f555eb2 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1013,6 +1013,45 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
+#ifdef CONFIG_NFSD_V4_2_SEEK
+static __be32
+nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_seek *seek)
+{
+	struct file *file;
+	__be32 status = nfs_ok;
+
+	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
+					    &seek->seek_stateid,
+					    RD_STATE | WR_STATE, &file);
+	if (status) {
+		dprintk("NFSD: nfsd4_seek: couldn't process stateid!\n");
+		return status;
+	}
+
+	switch (seek->seek_whence) {
+	case NFS4_CONTENT_DATA:
+		seek->seek_pos = vfs_llseek(file, seek->seek_offset, SEEK_DATA);
+		break;
+	case NFS4_CONTENT_HOLE:
+		seek->seek_pos = vfs_llseek(file, seek->seek_offset, SEEK_HOLE);
+		break;
+	default:
+		status = nfserr_union_notsupp;
+		goto out;
+	}
+
+	if (seek->seek_pos < 0)
+		status = nfserrno(seek->seek_pos);
+	else if (seek->seek_pos >= i_size_read(file_inode(file)))
+		seek->seek_eof = true;
+
+out:
+	fput(file);
+	return status;
+}
+#endif /* CONFIG_NFSD_V4_2_SEEK */
+
 /* This routine never returns NFS_OK!  If there are no other errors, it
  * will return NFSERR_SAME or NFSERR_NOT_SAME depending on whether the
  * attributes matched.  VERIFY is implemented by mapping NFSERR_SAME
@@ -1881,6 +1920,14 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_freestateid,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
+
+	/* NFSv4.2 operations */
+#ifdef CONFIG_NFSD_V4_2_SEEK
+	[OP_SEEK] = {
+		.op_func = (nfsd4op_func)nfsd4_seek,
+		.op_name = "OP_SEEK",
+	},
+#endif /* CONFIG_NFSD_V4_2_SEEK */
 };
 
 int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 94dde7b..5bedeb3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1520,6 +1520,24 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 	DECODE_TAIL;
 }
 
+#ifdef CONFIG_NFSD_V4_2_SEEK
+static __be32
+nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
+{
+	DECODE_HEAD;
+
+	status = nfsd4_decode_stateid(argp, &seek->seek_stateid);
+	if (status)
+		return status;
+
+	READ_BUF(12);
+	p = xdr_decode_hyper(p, &seek->seek_offset);
+	seek->seek_whence = be32_to_cpup(p);
+
+	DECODE_TAIL;
+}
+#endif /* CONFIG_NFSD_V4_2_SEEK */
+
 static __be32
 nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
 {
@@ -1605,7 +1623,11 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
+#ifdef CONFIG_NFSD_V4_2_SEEK
+	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
+#else
 	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_notsupp,
+#endif /* CONFIG_NFSD_V4_2_SEEK */
 	[OP_WRITE_SAME]		= (nfsd4_dec)nfsd4_decode_notsupp,
 };
 
@@ -3764,6 +3786,24 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 	return nfserr;
 }
 
+#ifdef CONFIG_NFSD_V4_2_SEEK
+static __be32
+nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
+		  struct nfsd4_seek *seek)
+{
+	__be32 *p;
+
+	if (nfserr)
+		return nfserr;
+
+	p = xdr_reserve_space(&resp->xdr, 12);
+	*p++ = cpu_to_be32(seek->seek_eof);
+	p = xdr_encode_hyper(p, seek->seek_pos);
+
+	return nfserr;
+}
+#endif /* CONFIG_NFSD_V4_2_SEEK */
+
 static __be32
 nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
 {
@@ -3848,8 +3888,13 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_OFFLOAD_CANCEL]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
+#ifdef CONFIG_NFSD_V4_2_SEEK
+	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
+#else
 	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_noop,
+#endif /* CONFIG_NFSD_V4_2_SEEK */
 	[OP_WRITE_SAME]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
 };
 
 /*
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

