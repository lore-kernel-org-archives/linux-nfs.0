Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52149 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757177Ab0JVOOl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:14:41 -0400
Message-ID: <4CC19C50.5070902@netapp.com>
Date: Fri, 22 Oct 2010 10:14:40 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/10] NFS: readdir with vmapped pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We can use vmapped pages to read more information from the network at once.
This will reduce the number of calls needed to complete a readdir.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
[trondmy: Added #include for linux/vmalloc.h> in fs/nfs/dir.c]
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c         |    4 +-
 fs/nfs/dir.c            |   66 ++++++++++++++++++++++++++++++++++++++--------
 fs/nfs/internal.h       |    6 ++++
 fs/nfs/nfs3proc.c       |    4 +-
 fs/nfs/nfs4proc.c       |    8 +++---
 fs/nfs/proc.c           |    4 +-
 include/linux/nfs_xdr.h |    2 +-
 7 files changed, 71 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5f01f42..876ba85 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -903,8 +903,8 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
 	server->dtsize = nfs_block_size(fsinfo->dtpref, NULL);
-	if (server->dtsize > PAGE_CACHE_SIZE)
-		server->dtsize = PAGE_CACHE_SIZE;
+	if (server->dtsize > PAGE_CACHE_SIZE * NFS_MAX_READDIR_PAGES)
+		server->dtsize = PAGE_CACHE_SIZE * NFS_MAX_READDIR_PAGES;
 	if (server->dtsize > server->rsize)
 		server->dtsize = server->rsize;
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 72063ff..879308e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -33,6 +33,7 @@
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/sched.h>
+#include <linux/vmalloc.h>
 
 #include "delegation.h"
 #include "iostat.h"
@@ -327,7 +328,7 @@ out:
 
 /* Fill a page with xdr information before transferring to the cache page */
 static
-int nfs_readdir_xdr_filler(struct page *xdr_page, nfs_readdir_descriptor_t *desc,
+int nfs_readdir_xdr_filler(struct page **pages, nfs_readdir_descriptor_t *desc,
 			struct nfs_entry *entry, struct file *file, struct inode *inode)
 {
 	struct rpc_cred	*cred = nfs_file_cred(file);
@@ -337,7 +338,7 @@ int nfs_readdir_xdr_filler(struct page *xdr_page, nfs_readdir_descriptor_t *desc
  again:
 	timestamp = jiffies;
 	gencount = nfs_inc_attr_generation_counter();
-	error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, entry->cookie, xdr_page,
+	error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, entry->cookie, pages,
 					  NFS_SERVER(inode)->dtsize, desc->plus);
 	if (error < 0) {
 		/* We requested READDIRPLUS, but the server doesn't grok it */
@@ -436,11 +437,11 @@ out:
 /* Perform conversion from xdr to cache array */
 static
 void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
-				struct page *xdr_page, struct page *page, unsigned int buflen)
+				void *xdr_page, struct page *page, unsigned int buflen)
 {
 	struct xdr_stream stream;
 	struct xdr_buf buf;
-	__be32 *ptr = kmap(xdr_page);
+	__be32 *ptr = xdr_page;
 
 	buf.head->iov_base = xdr_page;
 	buf.head->iov_len = buflen;
@@ -458,18 +459,59 @@ void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *e
 		if (desc->plus == 1)
 			nfs_prime_dcache(desc->file->f_path.dentry, entry);
 	}
-	kunmap(xdr_page);
+}
+
+static
+void nfs_readdir_free_pagearray(struct page **pages, unsigned int npages)
+{
+	unsigned int i;
+	for (i = 0; i < npages; i++)
+		put_page(pages[i]);
+}
+
+static
+void nfs_readdir_free_large_page(void *ptr, struct page **pages,
+		unsigned int npages)
+{
+	vm_unmap_ram(ptr, npages);
+	nfs_readdir_free_pagearray(pages, npages);
+}
+
+/*
+ * nfs_readdir_large_page will allocate pages that must be freed with a call
+ * to nfs_readdir_free_large_page
+ */
+static
+void *nfs_readdir_large_page(struct page **pages, unsigned int npages)
+{
+	void *ptr;
+	unsigned int i;
+
+	for (i = 0; i < npages; i++) {
+		struct page *page = alloc_page(GFP_KERNEL);
+		if (page == NULL)
+			goto out_freepages;
+		pages[i] = page;
+	}
+
+	ptr = vm_map_ram(pages, NFS_MAX_READDIR_PAGES, 0, PAGE_KERNEL);
+	if (!IS_ERR_OR_NULL(ptr))
+		return ptr;
+out_freepages:
+	nfs_readdir_free_pagearray(pages, i);
+	return NULL;
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
 	int status = 0;
-	unsigned int array_size = 1;
+	unsigned int array_size = ARRAY_SIZE(pages);
 
 	entry.prev_cookie = 0;
 	entry.cookie = *desc->dir_cookie;
@@ -483,18 +525,18 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	memset(array, 0, sizeof(struct nfs_cache_array));
 	array->eof_index = -1;
 
-	xdr_page = alloc_page(GFP_KERNEL);
-	if (!xdr_page)
+	pages_ptr = nfs_readdir_large_page(pages, array_size);
+	if (!pages_ptr)
 		goto out_release_array;
 	do {
-		status = nfs_readdir_xdr_filler(xdr_page, desc, &entry, file, inode);
+		status = nfs_readdir_xdr_filler(pages, desc, &entry, file, inode);
 
 		if (status < 0)
 			break;
-		nfs_readdir_page_filler(desc, &entry, xdr_page, page, array_size * PAGE_SIZE);
+		nfs_readdir_page_filler(desc, &entry, pages_ptr, page, array_size * PAGE_SIZE);
 	} while (array->eof_index < 0 && array->size < MAX_READDIR_ARRAY);
 
-	put_page(xdr_page);
+	nfs_readdir_free_large_page(pages_ptr, pages, array_size);
 out_release_array:
 	nfs_readdir_release_array(page);
 out:
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 74b0155..7b0e894 100644
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
index f8446b3..ce939c0 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -630,7 +630,7 @@ out:
  */
 static int
 nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
-		  u64 cookie, struct page *page, unsigned int count, int plus)
+		  u64 cookie, struct page **pages, unsigned int count, int plus)
 {
 	struct inode		*dir = dentry->d_inode;
 	__be32			*verf = NFS_COOKIEVERF(dir);
@@ -640,7 +640,7 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		.verf		= {verf[0], verf[1]},
 		.plus		= plus,
 		.count		= count,
-		.pages		= &page
+		.pages		= pages
 	};
 	struct nfs3_readdirres	res = {
 		.verf		= verf,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index aa771c1..cb33c73 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2823,12 +2823,12 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
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
@@ -2859,14 +2859,14 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
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
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index e5e84aa..58e7f84 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -534,14 +534,14 @@ nfs_proc_rmdir(struct inode *dir, struct qstr *name)
  */
 static int
 nfs_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
-		 u64 cookie, struct page *page, unsigned int count, int plus)
+		 u64 cookie, struct page **pages, unsigned int count, int plus)
 {
 	struct inode		*dir = dentry->d_inode;
 	struct nfs_readdirargs	arg = {
 		.fh		= NFS_FH(dir),
 		.cookie		= cookie,
 		.count		= count,
-		.pages		= &page,
+		.pages		= pages,
 	};
 	struct rpc_message	msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_READDIR],
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ca0e8fd..1b9a17a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1026,7 +1026,7 @@ struct nfs_rpc_ops {
 	int	(*mkdir)   (struct inode *, struct dentry *, struct iattr *);
 	int	(*rmdir)   (struct inode *, struct qstr *);
 	int	(*readdir) (struct dentry *, struct rpc_cred *,
-			    u64, struct page *, unsigned int, int);
+			    u64, struct page **, unsigned int, int);
 	int	(*mknod)   (struct inode *, struct dentry *, struct iattr *,
 			    dev_t);
 	int	(*statfs)  (struct nfs_server *, struct nfs_fh *,
