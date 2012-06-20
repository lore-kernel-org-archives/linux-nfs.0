Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18016 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757972Ab2FTTyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:54:09 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 08/10] NFS: Create an read_pageio_init() function
Date: Wed, 20 Jun 2012 15:53:47 -0400
Message-Id: <1340222029-18027-9-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
References: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

pNFS needs to select a read function based on the layout driver
currently in use, so I let each NFS version decide how to best handle
initializing reads.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h       |  2 +-
 fs/nfs/nfs3proc.c       |  1 +
 fs/nfs/nfs4proc.c       |  1 +
 fs/nfs/pnfs.c           | 11 +++++------
 fs/nfs/pnfs.h           |  6 +++---
 fs/nfs/proc.c           |  1 +
 fs/nfs/read.c           | 16 +++-------------
 include/linux/nfs_xdr.h |  3 +++
 8 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 633af81..b312112 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -306,7 +306,7 @@ extern int nfs_initiate_read(struct rpc_clnt *clnt,
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
 			      struct nfs_pgio_header *hdr);
-extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
+extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 			struct inode *inode,
 			const struct nfs_pgio_completion_ops *compl_ops);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 77c7aac..9864d05 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -921,6 +921,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.pathconf	= nfs3_proc_pathconf,
 	.decode_dirent	= nfs3_decode_dirent,
 	.read_setup	= nfs3_proc_read_setup,
+	.read_pageio_init = nfs_pageio_init_read,
 	.read_rpc_prepare = nfs3_proc_read_rpc_prepare,
 	.read_done	= nfs3_read_done,
 	.write_setup	= nfs3_proc_write_setup,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9ed2cc3..31d9c80 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6790,6 +6790,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.set_capabilities = nfs4_server_capabilities,
 	.decode_dirent	= nfs4_decode_dirent,
 	.read_setup	= nfs4_proc_read_setup,
+	.read_pageio_init = pnfs_pageio_init_read,
 	.read_rpc_prepare = nfs4_proc_read_rpc_prepare,
 	.read_done	= nfs4_read_done,
 	.write_setup	= nfs4_proc_write_setup,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bbc49ca..9c83060 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1209,7 +1209,7 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
 
-bool
+void
 pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
 		      const struct nfs_pgio_completion_ops *compl_ops)
 {
@@ -1217,10 +1217,9 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
 	struct pnfs_layoutdriver_type *ld = server->pnfs_curr_ld;
 
 	if (ld == NULL)
-		return false;
-	nfs_pageio_init(pgio, inode, ld->pg_read_ops, compl_ops,
-			server->rsize, 0);
-	return true;
+		nfs_pageio_init_read(pgio, inode, compl_ops);
+	else
+		nfs_pageio_init(pgio, inode, ld->pg_read_ops, compl_ops, server->rsize, 0);
 }
 
 bool
@@ -1427,7 +1426,7 @@ int pnfs_read_done_resend_to_mds(struct inode *inode,
 	LIST_HEAD(failed);
 
 	/* Resend all requests through the MDS */
-	nfs_pageio_init_read_mds(&pgio, inode, compl_ops);
+	nfs_pageio_init_read(&pgio, inode, compl_ops);
 	while (!list_empty(head)) {
 		struct nfs_page *req = nfs_list_entry(head->next);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 64f90d8..80ee891 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -178,7 +178,7 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
 void put_lseg(struct pnfs_layout_segment *lseg);
 
-bool pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
+void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   const struct nfs_pgio_completion_ops *);
 bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *,
 			    int, const struct nfs_pgio_completion_ops *);
@@ -438,10 +438,10 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
 {
 }
 
-static inline bool pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
+static inline void pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
 					 const struct nfs_pgio_completion_ops *compl_ops)
 {
-	return false;
+	nfs_pageio_init_read(pgio, inode, compl_ops);
 }
 
 static inline bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 99a0025..6fea6e1 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -778,6 +778,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.pathconf	= nfs_proc_pathconf,
 	.decode_dirent	= nfs2_decode_dirent,
 	.read_setup	= nfs_proc_read_setup,
+	.read_pageio_init = nfs_pageio_init_read,
 	.read_rpc_prepare = nfs_proc_read_rpc_prepare,
 	.read_done	= nfs_read_done,
 	.write_setup	= nfs_proc_write_setup,
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 86ced78..6267b87 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -20,8 +20,6 @@
 #include <linux/nfs_page.h>
 #include <linux/module.h>
 
-#include "pnfs.h"
-
 #include "nfs4_fs.h"
 #include "internal.h"
 #include "iostat.h"
@@ -108,7 +106,7 @@ int nfs_return_empty_page(struct page *page)
 	return 0;
 }
 
-void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
+void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 			      struct inode *inode,
 			      const struct nfs_pgio_completion_ops *compl_ops)
 {
@@ -123,14 +121,6 @@ void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_reset_read_mds);
 
-void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
-			  struct inode *inode,
-			  const struct nfs_pgio_completion_ops *compl_ops)
-{
-	if (!pnfs_pageio_init_read(pgio, inode, compl_ops))
-		nfs_pageio_init_read_mds(pgio, inode, compl_ops);
-}
-
 int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 		       struct page *page)
 {
@@ -149,7 +139,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	if (len < PAGE_CACHE_SIZE)
 		zero_user_segment(page, len, PAGE_CACHE_SIZE);
 
-	nfs_pageio_init_read(&pgio, inode, &nfs_async_read_completion_ops);
+	NFS_PROTO(inode)->read_pageio_init(&pgio, inode, &nfs_async_read_completion_ops);
 	nfs_pageio_add_request(&pgio, new);
 	nfs_pageio_complete(&pgio);
 	NFS_I(inode)->read_io += pgio.pg_bytes_written;
@@ -652,7 +642,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
-	nfs_pageio_init_read(&pgio, inode, &nfs_async_read_completion_ops);
+	NFS_PROTO(inode)->read_pageio_init(&pgio, inode, &nfs_async_read_completion_ops);
 
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4d62b77..e00b8b3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1354,6 +1354,7 @@ struct nfs_access_entry;
 struct nfs_client;
 struct rpc_timeout;
 struct nfs_client_initdata;
+struct nfs_pageio_descriptor;
 
 /*
  * RPC procedure vector for NFSv2/NFSv3 demuxing
@@ -1407,6 +1408,8 @@ struct nfs_rpc_ops {
 	int	(*set_capabilities)(struct nfs_server *, struct nfs_fh *);
 	int	(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, int);
 	void	(*read_setup)   (struct nfs_read_data *, struct rpc_message *);
+	void	(*read_pageio_init)(struct nfs_pageio_descriptor *, struct inode *,
+				    const struct nfs_pgio_completion_ops *);
 	void	(*read_rpc_prepare)(struct rpc_task *, struct nfs_read_data *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
-- 
1.7.11

