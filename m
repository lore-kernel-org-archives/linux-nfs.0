Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51194 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbaHUQHg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:36 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUti-0000AU-Tq
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:35 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/19] pnfs: allow splicing pre-encoded pages into the layoutcommit args
Date: Thu, 21 Aug 2014 11:09:25 -0500
Message-Id: <1408637375-11343-10-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently there is no XDR buffer space allocated for the per-layout driver
layoutcommit payload, which leads to server buffer overflows in the
blocklayout driver even under simple workloads.  As we can't do per-layout
sizes for XDR operations we'll have to splice a previously encoded list
of pages into the XDR stream, similar to how we handle ACL buffers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs4xdr.c        | 18 +++++++++++++-----
 fs/nfs/pnfs.c           | 15 +++++++++++++++
 fs/nfs/pnfs.h           |  4 ++--
 include/linux/nfs_xdr.h |  3 +++
 4 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e13b59d..f2cd957 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -395,7 +395,10 @@ static int nfs4_stat_to_errno(int);
 				2 /* last byte written */ + \
 				1 /* nt_timechanged (false) */ + \
 				1 /* layoutupdate4 layout type */ + \
-				1 /* NULL filelayout layoutupdate4 payload */)
+				1 /* layoutupdate4 opaqueue len */)
+				  /* the actual content of layoutupdate4 should
+				     be allocated by drivers and spliced in
+				     using xdr_write_pages */
 #define decode_layoutcommit_maxsz (op_decode_hdr_maxsz + 3)
 #define encode_layoutreturn_maxsz (8 + op_encode_hdr_maxsz + \
 				encode_stateid_maxsz + \
@@ -1990,7 +1993,7 @@ encode_layoutget(struct xdr_stream *xdr,
 static int
 encode_layoutcommit(struct xdr_stream *xdr,
 		    struct inode *inode,
-		    const struct nfs4_layoutcommit_args *args,
+		    struct nfs4_layoutcommit_args *args,
 		    struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -2011,11 +2014,16 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(0); /* Never send time_modify_changed */
 	*p++ = cpu_to_be32(NFS_SERVER(args->inode)->pnfs_curr_ld->id);/* type */
 
-	if (NFS_SERVER(inode)->pnfs_curr_ld->encode_layoutcommit)
+	if (NFS_SERVER(inode)->pnfs_curr_ld->encode_layoutcommit) {
 		NFS_SERVER(inode)->pnfs_curr_ld->encode_layoutcommit(
 			NFS_I(inode)->layout, xdr, args);
-	else
-		encode_uint32(xdr, 0); /* no layout-type payload */
+	} else {
+		encode_uint32(xdr, args->layoutupdate_len);
+		if (args->layoutupdate_pages) {
+			xdr_write_pages(xdr, args->layoutupdate_pages, 0,
+					args->layoutupdate_len);
+		}
+	}
 
 	return 0;
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e481d1c..a823edf 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1838,6 +1838,7 @@ void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data)
 int
 pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 	struct nfs4_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
 	loff_t end_pos;
@@ -1888,6 +1889,20 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	data->args.lastbytewritten = end_pos - 1;
 	data->res.server = NFS_SERVER(inode);
 
+	if (ld->prepare_layoutcommit) {
+		status = ld->prepare_layoutcommit(&data->args);
+		if (status) {
+			spin_lock(&inode->i_lock);
+			if (end_pos < nfsi->layout->plh_lwb)
+				nfsi->layout->plh_lwb = end_pos;
+			spin_unlock(&inode->i_lock);
+			put_rpccred(data->cred);
+			set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
+			goto clear_layoutcommitting;
+		}
+	}
+
+
 	status = nfs4_proc_layoutcommit(data, sync);
 out:
 	if (status)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 044c071..e11a161 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -132,8 +132,8 @@ struct pnfs_layoutdriver_type {
 				     const struct nfs4_layoutreturn_args *args);
 
 	void (*cleanup_layoutcommit) (struct nfs4_layoutcommit_data *data);
-
-	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
+	int (*prepare_layoutcommit) (struct nfs4_layoutcommit_args *args);
+	void (*encode_layoutcommit) (struct pnfs_layout_hdr *lo,
 				     struct xdr_stream *xdr,
 				     const struct nfs4_layoutcommit_args *args);
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0040629..d79b9c6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -279,6 +279,9 @@ struct nfs4_layoutcommit_args {
 	__u64 lastbytewritten;
 	struct inode *inode;
 	const u32 *bitmask;
+	size_t layoutupdate_len;
+	struct page *layoutupdate_page;
+	struct page **layoutupdate_pages;
 };
 
 struct nfs4_layoutcommit_res {
-- 
1.9.1

