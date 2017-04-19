Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49010 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934704AbdDSOLm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Apr 2017 10:11:42 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] NFS: move nfs_pgarray_set() to open code
Date: Wed, 19 Apr 2017 10:11:34 -0400
Message-Id: <fee82497668b40eafb6c4bfb24c916c7ef1025b2.1492611057.git.bcodding@redhat.com>
In-Reply-To: <01bf89b13b51faa8b9adcd3a5e09eea55b8d9827.1492611057.git.bcodding@redhat.com>
References: <01bf89b13b51faa8b9adcd3a5e09eea55b8d9827.1492611057.git.bcodding@redhat.com>
In-Reply-To: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
References: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 00bfa30abe86 ("NFS: Create a common pgio_alloc and
pgio_release function"), nfs_pgarray_set() has only a single caller.  Let's
open code it.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/pagelist.c | 34 ++++++++++++++--------------------
 1 file changed, 14 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index cd6ec9bdd1c7..fa2924ce5a78 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -29,20 +29,6 @@
 static struct kmem_cache *nfs_page_cachep;
 static const struct rpc_call_ops nfs_pgio_common_ops;
 
-static bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int pagecount,
-					gfp_t gfp_flags)
-{
-	p->npages = pagecount;
-	if (pagecount <= ARRAY_SIZE(p->page_array))
-		p->pagevec = p->page_array;
-	else {
-		p->pagevec = kcalloc(pagecount, sizeof(struct page *), gfp_flags);
-		if (!p->pagevec)
-			p->npages = 0;
-	}
-	return p->pagevec != NULL;
-}
-
 struct nfs_pgio_mirror *
 nfs_pgio_current_mirror(struct nfs_pageio_descriptor *desc)
 {
@@ -758,16 +744,24 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 				*last_page;
 	struct list_head *head = &mirror->pg_list;
 	struct nfs_commit_info cinfo;
+	struct nfs_page_array *pg_array = &hdr->page_array;
 	unsigned int pagecount, pageused;
 	gfp_t gfp_flags = GFP_KERNEL;
 
 	pagecount = nfs_page_array_len(mirror->pg_base, mirror->pg_count);
-	if (desc->pg_rw_ops->rw_mode == FMODE_WRITE)
-		gfp_flags = GFP_NOIO;
-	if (!nfs_pgarray_set(&hdr->page_array, pagecount, gfp_flags)) {
-		nfs_pgio_error(hdr);
-		desc->pg_error = -ENOMEM;
-		return desc->pg_error;
+
+	if (pagecount <= ARRAY_SIZE(pg_array->page_array))
+		pg_array->pagevec = pg_array->page_array;
+	else {
+		if (desc->pg_rw_ops->rw_mode == FMODE_WRITE)
+			gfp_flags = GFP_NOIO;
+		pg_array->pagevec = kcalloc(pagecount, sizeof(struct page *), gfp_flags);
+		if (!pg_array->pagevec) {
+			pg_array->npages = 0;
+			nfs_pgio_error(hdr);
+			desc->pg_error = -ENOMEM;
+			return desc->pg_error;
+		}
 	}
 
 	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
-- 
2.9.3

