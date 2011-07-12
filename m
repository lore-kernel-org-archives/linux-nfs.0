Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55415 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754107Ab1GLTaH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 15:30:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/8] NFS: Clean up nfs_read_rpcsetup and nfs_write_rpcsetup
Date: Tue, 12 Jul 2011 15:29:47 -0400
Message-Id: <1310498994-12685-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1310498994-12685-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1310498994-12685-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Split them up into two parts: one which sets up the struct nfs_read/write_data,
the other which sets up the actual RPC call or pNFS call.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/read.c           |   42 +++++++++++++++++++++++++-----------------
 fs/nfs/write.c          |   41 ++++++++++++++++++++++++++---------------
 include/linux/nfs_xdr.h |    2 ++
 3 files changed, 53 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index c394662..248a554 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -213,17 +213,14 @@ EXPORT_SYMBOL_GPL(nfs_initiate_read);
 /*
  * Set up the NFS read request struct
  */
-static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
-		const struct rpc_call_ops *call_ops,
-		unsigned int count, unsigned int offset,
-		struct pnfs_layout_segment *lseg)
+static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
+		unsigned int count, unsigned int offset)
 {
 	struct inode *inode = req->wb_context->path.dentry->d_inode;
 
 	data->req	  = req;
 	data->inode	  = inode;
 	data->cred	  = req->wb_context->cred;
-	data->lseg	  = get_lseg(lseg);
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -237,10 +234,21 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	data->res.count   = count;
 	data->res.eof     = 0;
 	nfs_fattr_init(&data->fattr);
+}
 
-	if (data->lseg &&
-	    (pnfs_try_to_read_data(data, call_ops) == PNFS_ATTEMPTED))
-		return 0;
+static int nfs_do_read(struct nfs_read_data *data,
+		const struct rpc_call_ops *call_ops,
+		struct pnfs_layout_segment *lseg)
+{
+	struct inode *inode = data->args.context->path.dentry->d_inode;
+
+	if (lseg) {
+		data->lseg = get_lseg(lseg);
+		if (pnfs_try_to_read_data(data, call_ops) == PNFS_ATTEMPTED)
+			return 0;
+		put_lseg(data->lseg);
+		data->lseg = NULL;
+	}
 
 	return nfs_initiate_read(data, NFS_CLIENT(inode), call_ops);
 }
@@ -292,7 +300,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 		data = nfs_readdata_alloc(1);
 		if (!data)
 			goto out_bad;
-		list_add(&data->pages, &list);
+		list_add(&data->list, &list);
 		requests++;
 		nbytes -= len;
 	} while(nbytes != 0);
@@ -304,15 +312,15 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 	do {
 		int ret2;
 
-		data = list_entry(list.next, struct nfs_read_data, pages);
-		list_del_init(&data->pages);
+		data = list_entry(list.next, struct nfs_read_data, list);
+		list_del_init(&data->list);
 
 		data->pagevec[0] = page;
 
 		if (nbytes < rsize)
 			rsize = nbytes;
-		ret2 = nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
-					 rsize, offset, lseg);
+		nfs_read_rpcsetup(req, data, rsize, offset);
+		ret2 = nfs_do_read(data, &nfs_read_partial_ops, lseg);
 		if (ret == 0)
 			ret = ret2;
 		offset += rsize;
@@ -325,8 +333,8 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 
 out_bad:
 	while (!list_empty(&list)) {
-		data = list_entry(list.next, struct nfs_read_data, pages);
-		list_del(&data->pages);
+		data = list_entry(list.next, struct nfs_read_data, list);
+		list_del(&data->list);
 		nfs_readdata_free(data);
 	}
 	SetPageError(page);
@@ -362,8 +370,8 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc)
 	}
 	req = nfs_list_entry(data->pages.next);
 
-	ret = nfs_read_rpcsetup(req, data, &nfs_read_full_ops, desc->pg_count,
-				0, lseg);
+	nfs_read_rpcsetup(req, data, desc->pg_count, 0);
+	ret = nfs_do_read(data, &nfs_read_full_ops, lseg);
 out:
 	put_lseg(lseg);
 	desc->pg_lseg = NULL;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1af4d82..0aeb09b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -845,11 +845,9 @@ EXPORT_SYMBOL_GPL(nfs_initiate_write);
 /*
  * Set up the argument/result storage required for the RPC call.
  */
-static int nfs_write_rpcsetup(struct nfs_page *req,
+static void nfs_write_rpcsetup(struct nfs_page *req,
 		struct nfs_write_data *data,
-		const struct rpc_call_ops *call_ops,
 		unsigned int count, unsigned int offset,
-		struct pnfs_layout_segment *lseg,
 		int how)
 {
 	struct inode *inode = req->wb_context->path.dentry->d_inode;
@@ -860,7 +858,6 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 	data->req = req;
 	data->inode = inode = req->wb_context->path.dentry->d_inode;
 	data->cred = req->wb_context->cred;
-	data->lseg = get_lseg(lseg);
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -886,10 +883,22 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 	data->res.count   = count;
 	data->res.verf    = &data->verf;
 	nfs_fattr_init(&data->fattr);
+}
 
-	if (data->lseg &&
-	    (pnfs_try_to_write_data(data, call_ops, how) == PNFS_ATTEMPTED))
-		return 0;
+static int nfs_do_write(struct nfs_write_data *data,
+		const struct rpc_call_ops *call_ops,
+		struct pnfs_layout_segment *lseg,
+		int how)
+{
+	struct inode *inode = data->args.context->path.dentry->d_inode;
+
+	if (lseg != NULL) {
+		data->lseg = get_lseg(lseg);
+		if (pnfs_try_to_write_data(data, call_ops, how) == PNFS_ATTEMPTED)
+			return 0;
+		put_lseg(data->lseg);
+		data->lseg = NULL;
+	}
 
 	return nfs_initiate_write(data, NFS_CLIENT(inode), call_ops, how);
 }
@@ -938,7 +947,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 		data = nfs_writedata_alloc(1);
 		if (!data)
 			goto out_bad;
-		list_add(&data->pages, &list);
+		list_add(&data->list, &list);
 		requests++;
 		nbytes -= len;
 	} while (nbytes != 0);
@@ -950,15 +959,16 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 	do {
 		int ret2;
 
-		data = list_entry(list.next, struct nfs_write_data, pages);
-		list_del_init(&data->pages);
+		data = list_entry(list.next, struct nfs_write_data, list);
+		list_del_init(&data->list);
 
 		data->pagevec[0] = page;
 
 		if (nbytes < wsize)
 			wsize = nbytes;
-		ret2 = nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
-					  wsize, offset, lseg, desc->pg_ioflags);
+		nfs_write_rpcsetup(req, data, wsize, offset, desc->pg_ioflags);
+		ret2 = nfs_do_write(data, &nfs_write_partial_ops, lseg,
+				desc->pg_ioflags);
 		if (ret == 0)
 			ret = ret2;
 		offset += wsize;
@@ -971,8 +981,8 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 
 out_bad:
 	while (!list_empty(&list)) {
-		data = list_entry(list.next, struct nfs_write_data, pages);
-		list_del(&data->pages);
+		data = list_entry(list.next, struct nfs_write_data, list);
+		list_del(&data->list);
 		nfs_writedata_free(data);
 	}
 	nfs_redirty_request(req);
@@ -1024,7 +1034,8 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
 		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
 
 	/* Set up the argument struct */
-	ret = nfs_write_rpcsetup(req, data, &nfs_write_full_ops, desc->pg_count, 0, lseg, desc->pg_ioflags);
+	nfs_write_rpcsetup(req, data, desc->pg_count, 0, desc->pg_ioflags);
+	ret = nfs_do_write(data, &nfs_write_full_ops, lseg, desc->pg_ioflags);
 out:
 	put_lseg(lseg); /* Cleans any gotten in ->pg_test */
 	desc->pg_lseg = NULL;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 956d357..5b11595 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1126,6 +1126,7 @@ struct nfs_read_data {
 	struct rpc_cred		*cred;
 	struct nfs_fattr	fattr;	/* fattr storage */
 	struct list_head	pages;	/* Coalesced read requests */
+	struct list_head	list;	/* lists of struct nfs_read_data */
 	struct nfs_page		*req;	/* multi ops per nfs_page */
 	struct page		**pagevec;
 	unsigned int		npages;	/* Max length of pagevec */
@@ -1149,6 +1150,7 @@ struct nfs_write_data {
 	struct nfs_fattr	fattr;
 	struct nfs_writeverf	verf;
 	struct list_head	pages;		/* Coalesced requests we wish to flush */
+	struct list_head	list;		/* lists of struct nfs_write_data */
 	struct nfs_page		*req;		/* multi ops per nfs_page */
 	struct page		**pagevec;
 	unsigned int		npages;		/* Max length of pagevec */
-- 
1.7.6

