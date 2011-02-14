Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41287 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507Ab1BNTSv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Feb 2011 14:18:51 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>,
        Andy Adamon <andros@netapp.com>, Andy Adamon <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>,
        Benny Halevy <bhalevy@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>
Subject: [PATCH 09/16] pnfs: wave 3: shift pnfs_update_layout locations
Date: Mon, 14 Feb 2011 14:18:29 -0500
Message-Id: <1297711116-3139-10-git-send-email-andros@netapp.com>
In-Reply-To: <1297711116-3139-1-git-send-email-andros@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Move the pnfs_update_layout call location to nfs_pageio_do_add_request().
Grab the lseg sent in the doio function to nfs_read_rpcsetup and attach
it to each nfs_read_data so it can be sent to the layout driver.

Signed-off-by: Andy Adamon <andros@netapp.com>
Signed-off-by: Andy Adamon <andros@citi.umich.edu>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
---
 fs/nfs/file.c            |    4 ----
 fs/nfs/pagelist.c        |   15 ++++++++++++---
 fs/nfs/pnfs.c            |    4 ++--
 fs/nfs/pnfs.h            |    1 +
 fs/nfs/read.c            |   28 ++++++++++++++++------------
 fs/nfs/write.c           |    4 ++--
 include/linux/nfs_page.h |    5 +++--
 include/linux/nfs_xdr.h  |    1 +
 8 files changed, 37 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 7bf029e..d85a534 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -387,10 +387,6 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
 
-	pnfs_update_layout(mapping->host,
-			   nfs_file_open_context(file),
-			   IOMODE_RW);
-
 start:
 	/*
 	 * Prevent starvation issues if someone is doing a consistency
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e1164e3..e0a0cb4 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -20,6 +20,7 @@
 #include <linux/nfs_mount.h>
 
 #include "internal.h"
+#include "pnfs.h"
 
 static struct kmem_cache *nfs_page_cachep;
 
@@ -213,7 +214,7 @@ nfs_wait_on_request(struct nfs_page *req)
  */
 void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 		     struct inode *inode,
-		     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
+		     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *),
 		     size_t bsize,
 		     int io_flags)
 {
@@ -226,6 +227,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_doio = doio;
 	desc->pg_ioflags = io_flags;
 	desc->pg_error = 0;
+	desc->pg_lseg = NULL;
 }
 
 /**
@@ -288,8 +290,13 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 		prev = nfs_list_entry(desc->pg_list.prev);
 		if (!nfs_can_coalesce_requests(prev, req))
 			return 0;
-	} else
+	} else {
+		put_lseg(desc->pg_lseg);
 		desc->pg_base = req->wb_pgbase;
+		desc->pg_lseg = pnfs_update_layout(desc->pg_inode,
+						   req->wb_context,
+						   IOMODE_READ);
+	}
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &desc->pg_list);
 	desc->pg_count = newlen;
@@ -307,7 +314,8 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 					  nfs_page_array_len(desc->pg_base,
 							     desc->pg_count),
 					  desc->pg_count,
-					  desc->pg_ioflags);
+					  desc->pg_ioflags,
+					  desc->pg_lseg);
 		if (error < 0)
 			desc->pg_error = error;
 		else
@@ -345,6 +353,7 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 {
 	nfs_pageio_doio(desc);
+	put_lseg(desc->pg_lseg);
 }
 
 /**
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f0a9578..dcd4356 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -264,7 +264,7 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
 	return 0;
 }
 
-static void
+void
 put_lseg(struct pnfs_layout_segment *lseg)
 {
 	struct inode *ino;
@@ -285,6 +285,7 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		pnfs_free_lseg_list(&free_me);
 	}
 }
+EXPORT_SYMBOL_GPL(put_lseg);
 
 static bool
 should_free_lseg(u32 lseg_iomode, u32 recall_iomode)
@@ -797,7 +798,6 @@ pnfs_update_layout(struct inode *ino,
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout ? nfsi->layout->plh_flags : -1, lseg);
-	put_lseg(lseg); /* STUB - callers currently ignore return value */
 	return lseg;
 out_unlock:
 	spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9a994bc..121d6a3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -146,6 +146,7 @@ extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
 
 /* pnfs.c */
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
+void put_lseg(struct pnfs_layout_segment *lseg);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index aedcaa7..c453164 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -20,17 +20,17 @@
 #include <linux/nfs_page.h>
 
 #include <asm/system.h>
+#include "pnfs.h"
 
 #include "nfs4_fs.h"
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
-#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-static int nfs_pagein_multi(struct inode *, struct list_head *, unsigned int, size_t, int);
-static int nfs_pagein_one(struct inode *, struct list_head *, unsigned int, size_t, int);
+static int nfs_pagein_multi(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
+static int nfs_pagein_one(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
 static const struct rpc_call_ops nfs_read_partial_ops;
 static const struct rpc_call_ops nfs_read_full_ops;
 
@@ -70,6 +70,7 @@ void nfs_readdata_free(struct nfs_read_data *p)
 static void nfs_readdata_release(struct nfs_read_data *rdata)
 {
 	put_nfs_open_context(rdata->args.context);
+	put_lseg(rdata->lseg);
 	nfs_readdata_free(rdata);
 }
 
@@ -117,11 +118,11 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	LIST_HEAD(one_request);
 	struct nfs_page	*new;
 	unsigned int len;
+	struct pnfs_layout_segment *lseg;
 
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	pnfs_update_layout(inode, ctx, IOMODE_READ);
 	new = nfs_create_request(ctx, inode, page, 0, len);
 	if (IS_ERR(new)) {
 		unlock_page(page);
@@ -131,10 +132,12 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 		zero_user_segment(page, len, PAGE_CACHE_SIZE);
 
 	nfs_list_add_request(new, &one_request);
+	lseg = pnfs_update_layout(inode, ctx, IOMODE_READ);
 	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
-		nfs_pagein_multi(inode, &one_request, 1, len, 0);
+		nfs_pagein_multi(inode, &one_request, 1, len, 0, lseg);
 	else
-		nfs_pagein_one(inode, &one_request, 1, len, 0);
+		nfs_pagein_one(inode, &one_request, 1, len, 0, lseg);
+	put_lseg(lseg);
 	return 0;
 }
 
@@ -160,7 +163,8 @@ static void nfs_readpage_release(struct nfs_page *req)
  */
 static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 		const struct rpc_call_ops *call_ops,
-		unsigned int count, unsigned int offset)
+		unsigned int count, unsigned int offset,
+		struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode = req->wb_context->path.dentry->d_inode;
 	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
@@ -183,6 +187,7 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	data->req	  = req;
 	data->inode	  = inode;
 	data->cred	  = msg.rpc_cred;
+	data->lseg	  = get_lseg(lseg);
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -240,7 +245,7 @@ nfs_async_read_error(struct list_head *head)
  * won't see the new data until our attribute cache is updated.  This is more
  * or less conventional NFS client behavior.
  */
-static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
+static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -280,7 +285,7 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
 		if (nbytes < rsize)
 			rsize = nbytes;
 		ret2 = nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
-				  rsize, offset);
+					 rsize, offset, lseg);
 		if (ret == 0)
 			ret = ret2;
 		offset += rsize;
@@ -300,7 +305,7 @@ out_bad:
 	return -ENOMEM;
 }
 
-static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
+static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
@@ -321,7 +326,7 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
 	}
 	req = nfs_list_entry(data->pages.next);
 
-	return nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0);
+	return nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0, lseg);
 out_bad:
 	nfs_async_read_error(head);
 	return ret;
@@ -625,7 +630,6 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
-	pnfs_update_layout(inode, desc.ctx, IOMODE_READ);
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
 	else
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c8278f4..004c28b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -879,7 +879,7 @@ static void nfs_redirty_request(struct nfs_page *req)
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
  */
-static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how)
+static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -946,7 +946,7 @@ out_bad:
  * This is the case if nfs_updatepage detects a conflicting request
  * that has been written but not committed.
  */
-static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how)
+static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index d55cee7..2db0372 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -59,9 +59,10 @@ struct nfs_pageio_descriptor {
 	unsigned int		pg_base;
 
 	struct inode		*pg_inode;
-	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int);
+	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
 	int 			pg_ioflags;
 	int			pg_error;
+	struct pnfs_layout_segment *pg_lseg;
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
@@ -79,7 +80,7 @@ extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *dst,
 			  pgoff_t idx_start, unsigned int npages, int tag);
 extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     struct inode *inode,
-			     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
+			     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *),
 			     size_t bsize,
 			     int how);
 extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 51bfadb..37e91c3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1017,6 +1017,7 @@ struct nfs_read_data {
 	struct nfs_readargs args;
 	struct nfs_readres  res;
 	unsigned long		timestamp;	/* For lease renewal */
+	struct pnfs_layout_segment *lseg;
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
-- 
1.7.2.3

