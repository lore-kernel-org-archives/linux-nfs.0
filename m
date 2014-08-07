Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45773 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217AbaHGHVg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:36 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 07/17] pnfs: allow splicing pre-encoded pages into the layoutcommit args
Date: Thu,  7 Aug 2014 09:23:39 +0200
Message-Id: <1407396229-4785-8-git-send-email-hch@lst.de>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently there is no XDR buffer space allocated for the per-layout driver
layoutcommit payload, which leads to server buffer overflows in the
blocklayout driver even under simple workloads.  As we can't do per-layout
sizes for XDR operations we'll have to splice a previously encoded list
of pages into the XDR stream, similar to how we handle ACL buffers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs4proc.c       | 14 ++++++++++++++
 fs/nfs/nfs4xdr.c        | 18 +++++++++++++-----
 fs/nfs/pnfs.c           | 15 +++++++++++++++
 fs/nfs/pnfs.h           |  4 ++--
 include/linux/nfs_xdr.h |  3 +++
 5 files changed, 47 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 66fd901..732fe09 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7920,6 +7920,18 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 	}
 }
 
+static void nfs4_layoutcommit_release_pages(
+		struct nfs4_layoutcommit_data *data)
+{
+	int nr_pages = DIV_ROUND_UP(data->args.layoutupdate_len, PAGE_SIZE), i;
+
+	for (i = 0; i < nr_pages; i++)
+		put_page(data->args.layoutupdate_pages[i]);
+
+	if (data->args.layoutupdate_pages != &data->args.layoutupdate_page)
+		kfree(data->args.layoutupdate_pages);
+}
+
 static void nfs4_layoutcommit_release(void *calldata)
 {
 	struct nfs4_layoutcommit_data *data = calldata;
@@ -7927,6 +7939,8 @@ static void nfs4_layoutcommit_release(void *calldata)
 	pnfs_cleanup_layoutcommit(data);
 	nfs_post_op_update_inode_force_wcc(data->args.inode,
 					   data->res.fattr);
+	if (data->args.layoutupdate_pages)
+		nfs4_layoutcommit_release_pages(data);
 	put_rpccred(data->cred);
 	kfree(data);
 }
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
index 13b1406..8c8955e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1833,6 +1833,7 @@ void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data)
 int
 pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 	struct nfs4_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
 	loff_t end_pos;
@@ -1883,6 +1884,20 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
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
index cab5259..603f460 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -131,8 +131,8 @@ struct pnfs_layoutdriver_type {
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
index 8a57de3..7d8c3d4 100644
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

