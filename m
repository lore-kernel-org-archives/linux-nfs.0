Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58313 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932481Ab0IGUD4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:03:56 -0400
Received: from [10.58.61.36] (panchal1-lxp.hq.netapp.com [10.58.61.36] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o87K3tmO027444
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 13:03:55 -0700 (PDT)
Message-ID: <4C869AAB.40004@netapp.com>
Date: Tue, 07 Sep 2010 16:03:55 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 6/6] NFS: readdir with vmapped pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFS readdir with vmapped pages

We can use vmapped pages to read more information from the network at once.
This will reduce the number of calls needed to complete a readdir.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4e7df2a..dde5a89 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -901,8 +901,8 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
 	server->dtsize = nfs_block_size(fsinfo->dtpref, NULL);
-	if (server->dtsize > PAGE_CACHE_SIZE)
-		server->dtsize = PAGE_CACHE_SIZE;
+	if (server->dtsize > PAGE_CACHE_SIZE * NFS_MAX_READDIR_PAGES)
+		server->dtsize = PAGE_CACHE_SIZE * NFS_MAX_READDIR_PAGES;
 	if (server->dtsize > server->rsize)
 		server->dtsize = server->rsize;
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 6971946..ece0526 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -278,7 +278,7 @@ exit:
 
 /* Fill a page with xdr information before transferring to the cache page */
 static inline
-int nfs_readdir_xdr_filler(struct page *xdr_page, nfs_readdir_descriptor_t *desc,
+int nfs_readdir_xdr_filler(struct page **pages, nfs_readdir_descriptor_t *desc,
 			struct nfs_entry *entry, struct file *file, struct inode *inode)
 {
 	struct rpc_cred	*cred = nfs_file_cred(file);
@@ -288,7 +288,7 @@ int nfs_readdir_xdr_filler(struct page *xdr_page, nfs_readdir_descriptor_t *desc
  again:
 	timestamp = jiffies;
 	gencount = nfs_inc_attr_generation_counter();
-	error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, entry->cookie, xdr_page,
+	error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, entry->cookie, pages,
 					  NFS_SERVER(inode)->dtsize, desc->plus);
 	if (error < 0) {
 		/* We requested READDIRPLUS, but the server doesn't grok it */
@@ -388,22 +388,53 @@ out:
 /* Perform conversion from xdr to cache array */
 static inline
 void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
-				struct page *xdr_page, struct page *page)
+				void *xdr_page, struct page *page)
 {
-	__be32 *ptr = kmap(xdr_page);
+	__be32 *ptr = xdr_page;
 	while (xdr_decode(desc, entry, &ptr) == 0) {
 		if (nfs_readdir_add_to_array(entry, page) == -1)
 			break;
 		if (desc->plus == 1)
 			nfs_prime_dcache(desc->file->f_path.dentry, entry);
 	}
-	kunmap(xdr_page);
+}
+
+static inline
+void nfs_readdir_free_large_page(void *ptr, struct page **pages)
+{
+	unsigned int i;
+	if (ptr)
+		vm_unmap_ram(ptr, NFS_MAX_READDIR_PAGES);
+	for (i = 0; i < NFS_MAX_READDIR_PAGES; i++)
+		put_page(pages[i]);
+}
+
+/*
+ * nfs_readdir_large_page will allocate pages that must be freed with a call
+ * to nfs_readdir_free_large_page
+ */
+static inline
+void *nfs_readdir_large_page(struct page **pages)
+{
+	void *ptr = NULL;
+	struct page *page = NULL;
+	int i;
+	for (i = 0; i < NFS_MAX_READDIR_PAGES; i++) {
+		page = alloc_page(GFP_KERNEL);
+		pages[i] = page;
+	}
+
+	ptr = vm_map_ram(pages, NFS_MAX_READDIR_PAGES, 0, PAGE_KERNEL);
+	if (IS_ERR_OR_NULL(ptr))
+		nfs_readdir_free_large_page(ptr, pages);
+	return ptr;
 }
 
 static
 int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page, struct inode *inode)
 {
-	struct page *xdr_page;
+	struct page *pages[NFS_MAX_READDIR_PAGES];
+	void *pages_ptr = NULL;
 	struct nfs_entry entry;
 	struct file	*file = desc->file;
 	struct nfs_cache_array *array;
@@ -416,6 +447,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	entry.fattr = nfs_alloc_fattr();
 	if (entry.fh == NULL || entry.fattr == NULL)
 		goto out;
+	printk(KERN_DEBUG "%d %s %s", __LINE__, __FILE__, __func__);
 
 	array = nfs_readdir_get_array(page);
 	memset(array, 0, sizeof(struct nfs_cache_array));
@@ -426,18 +458,18 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		goto out;
 	}
 
-	xdr_page = alloc_page(GFP_KERNEL);
-	if (!xdr_page)
+	pages_ptr = nfs_readdir_large_page(pages);
+	if (!pages_ptr)
 		goto out_put_page;
 	do {
-		status = nfs_readdir_xdr_filler(xdr_page, desc, &entry, file, inode);
+		status = nfs_readdir_xdr_filler(pages, desc, &entry, file, inode);
 		if (status < 0)
 			break;
-		nfs_readdir_page_filler(desc, &entry, xdr_page, page);
+		nfs_readdir_page_filler(desc, &entry, pages_ptr, page);
 	} while (array->eof_index < 0 && array->size < MAX_READDIR_ARRAY);
 
 out_put_page:
-	put_page(xdr_page);
+	nfs_readdir_free_large_page(pages_ptr, pages);
 out:
 	nfs_free_fattr(entry.fattr);
 	nfs_free_fhandle(entry.fh);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c961bc9..f64382c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -63,6 +63,12 @@ struct nfs_clone_mount {
 #define NFS_UNSPEC_PORT		(-1)
 
 /*
+ * Maximum number of pages that readdir can use for creating
+ * a vmapped array of pages.
+ */
+#define NFS_MAX_READDIR_PAGES 8
+
+/*
  * In-kernel mount arguments
  */
 struct nfs_parsed_mount_data {
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index fabb4f2..033ed04 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -611,7 +611,7 @@ out:
  */
 static int
 nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
-		  u64 cookie, struct page *page, unsigned int count, int plus)
+		  u64 cookie, struct page **pages, unsigned int count, int plus)
 {
 	struct inode		*dir = dentry->d_inode;
 	__be32			*verf = NFS_COOKIEVERF(dir);
@@ -621,7 +621,7 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		.verf		= {verf[0], verf[1]},
 		.plus		= plus,
 		.count		= count,
-		.pages		= &page
+		.pages		= pages
 	};
 	struct nfs3_readdirres	res = {
 		.verf		= verf,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 089da5b..479f422 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2896,12 +2896,12 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 }
 
 static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
-                  u64 cookie, struct page *page, unsigned int count, int plus)
+		u64 cookie, struct page **pages, unsigned int count, int plus)
 {
 	struct inode		*dir = dentry->d_inode;
 	struct nfs4_readdir_arg args = {
 		.fh = NFS_FH(dir),
-		.pages = &page,
+		.pages = pages,
 		.pgbase = 0,
 		.count = count,
 		.bitmask = NFS_SERVER(dentry->d_inode)->attr_bitmask,
@@ -2932,14 +2932,14 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 }
 
 static int nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
-                  u64 cookie, struct page *page, unsigned int count, int plus)
+		u64 cookie, struct page **pages, unsigned int count, int plus)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dentry->d_inode),
 				_nfs4_proc_readdir(dentry, cred, cookie,
-					page, count, plus),
+					pages, count, plus),
 				&exception);
 	} while (exception.retry);
 	return err;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 08ef912..f2e2f97 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4225,7 +4225,7 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 		pglen = recvd;
 	xdr_read_pages(xdr, pglen);
 
-	BUG_ON(pglen + readdir->pgbase > PAGE_CACHE_SIZE);
+	BUG_ON(pglen + readdir->pgbase > PAGE_CACHE_SIZE * NFS_MAX_READDIR_PAGES);
 	kaddr = p = kmap_atomic(page, KM_USER0);
 	end = p + ((pglen + readdir->pgbase) >> 2);
 	entry = p;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index fc46192..7d8cafa 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1044,7 +1044,7 @@ struct nfs_rpc_ops {
 	int	(*mkdir)   (struct inode *, struct dentry *, struct iattr *);
 	int	(*rmdir)   (struct inode *, struct qstr *);
 	int	(*readdir) (struct dentry *, struct rpc_cred *,
-			    u64, struct page *, unsigned int, int);
+			    u64, struct page **, unsigned int, int);
 	int	(*mknod)   (struct inode *, struct dentry *, struct iattr *,
 			    dev_t);
 	int	(*statfs)  (struct nfs_server *, struct nfs_fh *,
