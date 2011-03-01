Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757115Ab1CAR3u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 12:29:50 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>,
        Andy Adamson <andros@netapp.com>, Andy Adamson <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>,
        Benny Halevy <bhalevy@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>
Subject: [PATCH pNFS wave 3 Version 3 10/18] NFSv4.1: shift pnfs_update_layout locations
Date: Mon, 28 Feb 2011 20:34:15 -0500
Message-Id: <1298943263-2886-11-git-send-email-andros@netapp.com>
In-Reply-To: <1298943263-2886-10-git-send-email-andros@netapp.com>
References: <1298943263-2886-1-git-send-email-andros@netapp.com>
 <1298943263-2886-2-git-send-email-andros@netapp.com>
 <1298943263-2886-3-git-send-email-andros@netapp.com>
 <1298943263-2886-4-git-send-email-andros@netapp.com>
 <1298943263-2886-5-git-send-email-andros@netapp.com>
 <1298943263-2886-6-git-send-email-andros@netapp.com>
 <1298943263-2886-7-git-send-email-andros@netapp.com>
 <1298943263-2886-8-git-send-email-andros@netapp.com>
 <1298943263-2886-9-git-send-email-andros@netapp.com>
 <1298943263-2886-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Move the pnfs_update_layout call location to nfs_pageio_do_add_request().
Grab the lseg sent in the doio function to nfs_read_rpcsetup and attach
it to each nfs_read_data so it can be sent to the layout driver.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
---
 fs/nfs/file.c            |    4 ----
 fs/nfs/pagelist.c        |    7 +++++--
 fs/nfs/pnfs.c            |   27 ++++++++++++++++-----------
 fs/nfs/pnfs.h            |    1 +
 fs/nfs/read.c            |   40 ++++++++++++++++++++++++----------------
 fs/nfs/write.c           |    4 ++--
 include/linux/nfs_page.h |    4 ++--
 include/linux/nfs_xdr.h  |    1 +
 8 files changed, 51 insertions(+), 37 deletions(-)

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
index 9b9a65c..45b0fb8 100644
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
@@ -315,7 +316,9 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 					  nfs_page_array_len(desc->pg_base,
 							     desc->pg_count),
 					  desc->pg_count,
-					  desc->pg_ioflags);
+					  desc->pg_ioflags,
+					  desc->pg_lseg);
+		desc->pg_lseg = NULL;
 		if (error < 0)
 			desc->pg_error = error;
 		else
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 330cee1..77966ec 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -245,7 +245,7 @@ put_lseg_common(struct pnfs_layout_segment *lseg)
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
-static void
+void
 put_lseg(struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode;
@@ -784,7 +784,6 @@ pnfs_update_layout(struct inode *ino,
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout ? nfsi->layout->plh_flags : -1, lseg);
-	put_lseg(lseg); /* STUB - callers currently ignore return value */
 	return lseg;
 out_unlock:
 	spin_unlock(&ino->i_lock);
@@ -858,20 +857,26 @@ out_forget_reply:
 	goto out;
 }
 
-static void
-pnfs_set_pg_test(struct inode *inode, struct nfs_pageio_descriptor *pgio)
+static int pnfs_read_pg_test(struct nfs_pageio_descriptor *pgio,
+			     struct nfs_page *prev,
+			     struct nfs_page *req)
 {
-	struct pnfs_layoutdriver_type *ld;
-
-	ld = NFS_SERVER(inode)->pnfs_curr_ld;
-	pgio->pg_test = (ld ? ld->pg_test : NULL);
+	if (pgio->pg_count == prev->wb_bytes) {
+		/* This is first coelesce call for a series of nfs_pages */
+		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+						   prev->wb_context,
+						   IOMODE_READ);
+	}
+	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
 }
 
 void
-pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
-		  struct inode *inode)
+pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 {
-	pnfs_set_pg_test(inode, pgio);
+	struct pnfs_layoutdriver_type *ld;
+
+	ld = NFS_SERVER(inode)->pnfs_curr_ld;
+	pgio->pg_test = (ld && ld->pg_test) ? pnfs_read_pg_test : NULL;
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index db52d96..5107d14 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -151,6 +151,7 @@ extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
 
 /* pnfs.c */
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
+void put_lseg(struct pnfs_layout_segment *lseg);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 2a27659..6dc9eaf 100644
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
 
@@ -69,6 +69,7 @@ void nfs_readdata_free(struct nfs_read_data *p)
 
 static void nfs_readdata_release(struct nfs_read_data *rdata)
 {
+	put_lseg(rdata->lseg);
 	put_nfs_open_context(rdata->args.context);
 	nfs_readdata_free(rdata);
 }
@@ -121,7 +122,6 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	pnfs_update_layout(inode, ctx, IOMODE_READ);
 	new = nfs_create_request(ctx, inode, page, 0, len);
 	if (IS_ERR(new)) {
 		unlock_page(page);
@@ -132,9 +132,9 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 
 	nfs_list_add_request(new, &one_request);
 	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
-		nfs_pagein_multi(inode, &one_request, 1, len, 0);
+		nfs_pagein_multi(inode, &one_request, 1, len, 0, NULL);
 	else
-		nfs_pagein_one(inode, &one_request, 1, len, 0);
+		nfs_pagein_one(inode, &one_request, 1, len, 0, NULL);
 	return 0;
 }
 
@@ -160,7 +160,8 @@ static void nfs_readpage_release(struct nfs_page *req)
  */
 static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 		const struct rpc_call_ops *call_ops,
-		unsigned int count, unsigned int offset)
+		unsigned int count, unsigned int offset,
+		struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode = req->wb_context->path.dentry->d_inode;
 	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
@@ -183,6 +184,7 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	data->req	  = req;
 	data->inode	  = inode;
 	data->cred	  = msg.rpc_cred;
+	data->lseg	  = get_lseg(lseg);
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -240,7 +242,7 @@ nfs_async_read_error(struct list_head *head)
  * won't see the new data until our attribute cache is updated.  This is more
  * or less conventional NFS client behavior.
  */
-static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
+static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -266,6 +268,8 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
 	} while(nbytes != 0);
 	atomic_set(&req->wb_complete, requests);
 
+	/* We know lseg==NULL */
+	lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_READ);
 	ClearPageError(page);
 	offset = 0;
 	nbytes = count;
@@ -280,12 +284,13 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
 		if (nbytes < rsize)
 			rsize = nbytes;
 		ret2 = nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
-				  rsize, offset);
+					 rsize, offset, lseg);
 		if (ret == 0)
 			ret = ret2;
 		offset += rsize;
 		nbytes -= rsize;
 	} while (nbytes != 0);
+	put_lseg(lseg);
 
 	return ret;
 
@@ -300,7 +305,7 @@ out_bad:
 	return -ENOMEM;
 }
 
-static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
+static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
@@ -308,8 +313,10 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
 	int ret = -ENOMEM;
 
 	data = nfs_readdata_alloc(npages);
-	if (!data)
-		goto out_bad;
+	if (!data) {
+		nfs_async_read_error(head);
+		goto out;
+	}
 
 	pages = data->pagevec;
 	while (!list_empty(head)) {
@@ -320,10 +327,12 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
 		*pages++ = req->wb_page;
 	}
 	req = nfs_list_entry(data->pages.next);
+	if ((!lseg) && list_is_singular(&data->pages))
+		lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_READ);
 
-	return nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0);
-out_bad:
-	nfs_async_read_error(head);
+	ret = nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0, lseg);
+out:
+	put_lseg(lseg);
 	return ret;
 }
 
@@ -625,7 +634,6 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
-	pnfs_update_layout(inode, desc.ctx, IOMODE_READ);
 	pnfs_pageio_init_read(&pgio, inode);
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 6e90cdf..aca0268 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -880,7 +880,7 @@ static void nfs_redirty_request(struct nfs_page *req)
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
  */
-static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how)
+static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -947,7 +947,7 @@ out_bad:
  * This is the case if nfs_updatepage detects a conflicting request
  * that has been written but not committed.
  */
-static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how)
+static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 4eaf27a..ba88ff4 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -59,7 +59,7 @@ struct nfs_pageio_descriptor {
 	unsigned int		pg_base;
 
 	struct inode		*pg_inode;
-	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int);
+	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
 	int 			pg_ioflags;
 	int			pg_error;
 	struct pnfs_layout_segment *pg_lseg;
@@ -81,7 +81,7 @@ extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *dst,
 			  pgoff_t idx_start, unsigned int npages, int tag);
 extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     struct inode *inode,
-			     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
+			     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *),
 			     size_t bsize,
 			     int how);
 extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d159fe7..560923e 100644
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
1.6.6

