Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18375 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756298AbaAFV5R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 16:57:17 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
Subject: [PATCH 1/3] NFSD: Implement READ_PLUS support
Date: Mon, 6 Jan 2014 16:57:11 -0500
Message-ID: <1389045433-22990-2-git-send-email-Anna.Schumaker@netapp.com>
In-Reply-To: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com>
References: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I don't break the entire file into appropriate chunks.  Instead, if the
first section is a hole I send hole information.  Everything else is
reported as data.
---
 fs/nfsd/Kconfig    |  14 +++++
 fs/nfsd/nfs4proc.c |   9 +++
 fs/nfsd/nfs4xdr.c  | 177 +++++++++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 181 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 28d7f5d..cd35125 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -106,6 +106,20 @@ config NFSD_V4_2_WRITE_PLUS
 
 	  If unsure, say N.
 
+config NFSD_V4_2_READ_PLUS
+	bool "Enable READ_PLUS support for the NFS v4.2 server"
+	depends on NFSD_V4
+	help
+	  Say Y here if you want to enable support for the NFS v4.2 operation
+	  READ_PLUS, which is used for reading a file that may contain data
+	  holes (sparse files)
+
+	  WARNING: there is still a chance of backwards-incompatible protocol
+	  changes.  This feature is targeted at developers and testers only.
+
+	  If unsure, say N.
+
+
 config NFSD_V4_SECURITY_LABEL
 	bool "Provide Security Label support for NFSv4 server"
 	depends on NFSD_V4 && SECURITY
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 67ed233..905019c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1943,6 +1943,15 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_writestateid,
 	},
 #endif /* CONFIG_NFSD_V4_2_WRITE_PLUS */
+#ifdef CONFIG_NFSD_V4_2_READ_PLUS
+	[OP_READ_PLUS] = {
+		.op_func = (nfsd4op_func)nfsd4_read,
+		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_name = "OP_READ_PLUS",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_read_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_readstateid,
+	},
+#endif /* CONFIG_NFSD_V4_2_READ_PLUS */
 #ifdef CONFIG_NFSD_V4_2_SEEK
 	[OP_SEEK] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 92946bb..40b7793 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1636,7 +1636,11 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 #else
 	[OP_WRITE_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
 #endif /* CONFIG_NFSD_V4_2_WRITE_PLUS */
+#ifdef CONFIG_NFSD_V4_2_READ_PLUS
+	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_read,
+#else
 	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
+#endif /* CONFIG_NFSD_V4_2_READ_PLUS */
 #ifdef CONFIG_NFSD_V4_2_SEEK
 	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
 #else
@@ -3038,29 +3042,14 @@ nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr, struc
 	return nfserr;
 }
 
-static __be32
-nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
-		  struct nfsd4_read *read)
+static void nfsd4_encode_read_setup_pages(struct nfsd4_compoundres *resp,
+					  struct nfsd4_read *read,
+					  unsigned long maxcount)
 {
-	u32 eof;
 	int v;
 	struct page *page;
-	unsigned long maxcount; 
-	long len;
-	__be32 *p;
-
-	if (nfserr)
-		return nfserr;
-	if (resp->xbuf->page_len)
-		return nfserr_resource;
-
-	RESERVE_SPACE(8); /* eof flag and byte count */
-
-	maxcount = svc_max_payload(resp->rqstp);
-	if (maxcount > read->rd_length)
-		maxcount = read->rd_length;
+	long len = maxcount;
 
-	len = maxcount;
 	v = 0;
 	while (len > 0) {
 		page = *(resp->rqstp->rq_next_page);
@@ -3076,7 +3065,28 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		len -= PAGE_SIZE;
 	}
 	read->rd_vlen = v;
+}
+
+static __be32
+nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
+		  struct nfsd4_read *read)
+{
+	u32 eof;
+	unsigned long maxcount;
+	__be32 *p;
 
+	if (nfserr)
+		return nfserr;
+	if (resp->xbuf->page_len)
+		return nfserr_resource;
+
+	RESERVE_SPACE(8); /* eof flag and byte count */
+
+	maxcount = svc_max_payload(resp->rqstp);
+	if (maxcount > read->rd_length)
+		maxcount = read->rd_length;
+
+	nfsd4_encode_read_setup_pages(resp, read, maxcount);
 	nfserr = nfsd_read_file(read->rd_rqstp, read->rd_fhp, read->rd_filp,
 			read->rd_offset, resp->rqstp->rq_vec, read->rd_vlen,
 			&maxcount);
@@ -3631,6 +3641,131 @@ nfsd4_encode_write_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
 }
 #endif /* CONFIG_NFSD_V4_2_WRITE_PLUS */
 
+#ifdef CONFIG_NFSD_V4_2_READ_PLUS
+static __be32
+nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp,
+			    struct nfsd4_read *read, u32 *eof)
+{
+	__be32 *p, nfserr;
+	unsigned long maxcount;
+
+	maxcount = svc_max_payload(resp->rqstp);
+	if (maxcount > read->rd_length)
+		maxcount = read->rd_length;
+
+	nfsd4_encode_read_setup_pages(resp, read, maxcount);
+	nfserr = nfsd_read_file(read->rd_rqstp, read->rd_fhp, read->rd_filp,
+			read->rd_offset, resp->rqstp->rq_vec, read->rd_vlen,
+			&maxcount);
+	if (nfserr)
+		return nfserr;
+
+	RESERVE_SPACE(20);
+	WRITE32(NFS4_CONTENT_DATA);
+	WRITE64(read->rd_offset);
+	WRITE32(true); /* allocated flag */
+	WRITE32(maxcount);
+	ADJUST_ARGS();
+
+	*eof = (read->rd_offset + maxcount >=
+	       read->rd_fhp->fh_dentry->d_inode->i_size);
+
+	resp->xbuf->head[0].iov_len = (char*)p
+					- (char*)resp->xbuf->head[0].iov_base;
+	resp->xbuf->page_len = maxcount;
+
+	/* Use rest of head for padding and remaining ops: */
+	resp->xbuf->tail[0].iov_base = p;
+	resp->xbuf->tail[0].iov_len = 0;
+	if (maxcount&3) {
+		RESERVE_SPACE(4);
+		WRITE32(0);
+		resp->xbuf->tail[0].iov_base += maxcount&3;
+		resp->xbuf->tail[0].iov_len = 4 - (maxcount&3);
+		ADJUST_ARGS();
+	}
+	return 0;
+}
+
+static __be32
+nfsd4_encode_read_plus_hole(struct nfsd4_compoundres *resp,
+			    struct nfsd4_read *read, u32 *eof)
+{
+	__be32 *p;
+	u64 data_pos, max_pos, count;
+
+	/*
+	 * Sometimes the file doesn't have any more data
+	 */
+	data_pos = vfs_llseek(read->rd_filp, read->rd_offset, SEEK_DATA);
+	max_pos = read->rd_fhp->fh_dentry->d_inode->i_size;
+	if (data_pos > max_pos)
+		data_pos = max_pos;
+	count = data_pos - read->rd_offset;
+
+	RESERVE_SPACE(24);
+	WRITE32(NFS4_CONTENT_HOLE);
+	WRITE64(read->rd_offset);
+	WRITE64(count);
+	WRITE32(false);
+	ADJUST_ARGS();
+
+	*eof = (read->rd_offset + count >= max_pos);
+
+	read->rd_offset += count;
+	if (count > read->rd_length)
+		read->rd_length = 0;
+	else
+		read->rd_length -= count;
+
+	return 0;
+}
+
+static __be32
+nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
+		       struct nfsd4_read *read)
+{
+	u32 eof, count = 0;
+	__be32 *p, *p_saved;
+
+	if (nfserr)
+		return nfserr;
+	if (resp->xbuf->page_len)
+		return nfserr_resource;
+
+	RESERVE_SPACE(8); /* eof flag and contents count */
+	p_saved = p;
+	WRITE32(0); /* dummy write, we'll revisit this point later */
+	WRITE32(0); /* transmit one giant data chunk */
+	ADJUST_ARGS();
+
+	/**
+	 * Encode a hole only if we begin reading from one
+	 */
+	if (read->rd_offset == vfs_llseek(read->rd_filp, read->rd_offset, SEEK_HOLE)) {
+		nfserr = nfsd4_encode_read_plus_hole(resp, read, &eof);
+		if (nfserr)
+			return nfserr;
+		count++;
+		if ((read->rd_length == 0) || (eof == true))
+			goto out_done;
+	}
+
+	/**
+	 * Encode the rest as data
+	 */
+	nfserr = nfsd4_encode_read_plus_data(resp, read, &eof);
+	if (nfserr)
+		return nfserr;
+	count++;
+
+out_done:
+	*p_saved++ = htonl(eof);
+	*p_saved = htonl(count);
+	return 0;
+}
+#endif /* CONFIG_NFSD_V4_2_READ_PLUS */
+
 #ifdef CONFIG_NFSD_V4_2_SEEK
 static __be32
 nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
@@ -3737,7 +3872,11 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 #else
 	[OP_WRITE_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
 #endif /* CONFIG_NFSD_V4_2_WRITE_PLUS */
+#ifdef CONFIG_NFSD_V4_2_READ_PLUS
+	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_read_plus,
+#else
 	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
+#endif /* CONFIG_NFSD_V4_2_READ_PLUS */
 #ifdef CONFIG_NFSD_V4_2_SEEK
 	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
 #else
-- 
1.8.5.2

