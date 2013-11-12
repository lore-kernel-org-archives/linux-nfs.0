Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:3328 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972Ab3KLTER (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 14:04:17 -0500
From: Anna Schumaker <bjschuma@netapp.com>
To: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3/3] NFSD: Implement SEEK
Date: Tue, 12 Nov 2013 14:04:08 -0500
Message-ID: <1384283048-7699-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds in the SEEK operation used by clients doing an llseek on
a file to find either hole or data segments.  I am making the assumption
that allocated == true in the NFS4_CONTENT_DATA case and false for the
NFS4_CONTENT_HOLE case.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>

---
Changed in V2:
- Handle the NFS4_CONTENT_APP_DATA_HOLE case
- Return error codes provided by nfserrno()

 fs/nfsd/nfs4proc.c   | 56 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 40 +++++++++++++++++++++++++++++++++++--
 fs/nfsd/xdr4.h       | 16 +++++++++++++++
 include/linux/nfs4.h |  6 ++++++
 4 files changed, 116 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 419572f..a82021c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1028,6 +1028,57 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
+static __be32
+nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_seek *seek)
+{
+	struct file *file;
+	loff_t end_pos = 0;
+	__be32 status;
+
+	nfs4_lock_state();
+	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
+					    &seek->seek_stateid,
+					    RD_STATE | WR_STATE, &file);
+	if (status != nfs_ok) {
+		nfs4_unlock_state();
+		return status;
+	} else
+		get_file(file);
+	nfs4_unlock_state();
+
+	switch (seek->seek_whence) {
+	case NFS4_CONTENT_APP_DATA_HOLE:
+		status = nfserr_union_notsupp;
+		break;
+	case NFS4_CONTENT_DATA:
+		seek->seek_pos = vfs_llseek(file, seek->seek_offset, SEEK_DATA);
+		end_pos = vfs_llseek(file, seek->seek_pos, SEEK_HOLE);
+		seek->seek_allocated = true;
+		break;
+	case NFS4_CONTENT_HOLE:
+		seek->seek_pos = vfs_llseek(file, seek->seek_offset, SEEK_HOLE);
+		end_pos = vfs_llseek(file, seek->seek_pos, SEEK_DATA);
+		seek->seek_allocated = false;
+		break;
+	default:
+		status = nfs_ok;
+		seek->seek_eof = true;
+		goto out;
+	}
+
+	if (seek->seek_pos < 0) {
+		status = nfserrno(seek->seek_pos);
+		goto out;
+	}
+
+	seek->seek_length = end_pos - seek->seek_pos;
+
+out:
+	fput(file);
+	return status;
+}
+
 /* This routine never returns NFS_OK!  If there are no other errors, it
  * will return NFSERR_SAME or NFSERR_NOT_SAME depending on whether the
  * attributes matched.  VERIFY is implemented by mapping NFSERR_SAME
@@ -1840,6 +1891,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_freestateid,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
+
+	[OP_SEEK] = {
+		.op_func = (nfsd4op_func)nfsd4_seek,
+		.op_name = "OP_SEEK",
+	},
 };
 
 #ifdef NFSD_DEBUG
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3af6c46..45ad9ec 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1508,6 +1508,22 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
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
+	READ_BUF(12);
+	READ64(seek->seek_offset);
+	READ32(seek->seek_whence);
+
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
 {
 	return nfs_ok;
@@ -1589,7 +1605,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_WRITE_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
 };
 
@@ -3515,6 +3531,26 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
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
+	RESERVE_SPACE(28);
+	WRITE32(seek->seek_eof);
+	WRITE32(seek->seek_whence);
+	WRITE64(seek->seek_pos);
+	WRITE64(seek->seek_length);
+	WRITE32(seek->seek_allocated);
+	ADJUST_ARGS();
+
+	return nfserr;
+}
+
+static __be32
 nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
 {
 	return nfserr;
@@ -3595,7 +3631,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_WRITE_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
 	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
 };
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b3ed644..c2f4e30 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -430,6 +430,19 @@ struct nfsd4_reclaim_complete {
 	u32 rca_one_fs;
 };
 
+struct nfsd4_seek {
+	/* request */
+	stateid_t	seek_stateid;
+	loff_t		seek_offset;
+	u32		seek_whence;
+
+	/* response */
+	u64		seek_pos;
+	u32		seek_eof;
+	u64		seek_length;
+	u32		seek_allocated;
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -475,6 +488,9 @@ struct nfsd4_op {
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
index 01119ed..144f511 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -556,4 +556,10 @@ struct nfs4_deviceid {
 	char data[NFS4_DEVICEID4_SIZE];
 };
 
+enum data_content4 {
+	NFS4_CONTENT_DATA		= 0,
+	NFS4_CONTENT_APP_DATA_HOLE	= 1,
+	NFS4_CONTENT_HOLE		= 2,
+};
+
 #endif
-- 
1.8.4.2

