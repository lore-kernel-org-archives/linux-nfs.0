Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34386 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756804AbdDRPkM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Apr 2017 11:40:12 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: move nfs_pgarray_set() to open code
Date: Tue, 18 Apr 2017 11:40:09 -0400
Message-Id: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 00bfa30abe86 ("NFS: Create a common pgio_alloc and
pgio_release function"), nfs_pgarray_set() has only a single caller.  Let's
open code it to make it easier to use the correct GFP_ flags in a following
patch.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/pagelist.c | 29 ++++++++++++-----------------
 1 file changed, 12 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 6e629b856a00..19eaae0dee51 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -29,19 +29,6 @@
 static struct kmem_cache *nfs_page_cachep;
 static const struct rpc_call_ops nfs_pgio_common_ops;
 
-static bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int pagecount)
-{
-	p->npages = pagecount;
-	if (pagecount <= ARRAY_SIZE(p->page_array))
-		p->pagevec = p->page_array;
-	else {
-		p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_KERNEL);
-		if (!p->pagevec)
-			p->npages = 0;
-	}
-	return p->pagevec != NULL;
-}
-
 struct nfs_pgio_mirror *
 nfs_pgio_current_mirror(struct nfs_pageio_descriptor *desc)
 {
@@ -754,13 +741,21 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 				*last_page;
 	struct list_head *head = &mirror->pg_list;
 	struct nfs_commit_info cinfo;
+	struct nfs_page_array *pg_array = &hdr->page_array;
 	unsigned int pagecount, pageused;
 
 	pagecount = nfs_page_array_len(mirror->pg_base, mirror->pg_count);
-	if (!nfs_pgarray_set(&hdr->page_array, pagecount)) {
-		nfs_pgio_error(hdr);
-		desc->pg_error = -ENOMEM;
-		return desc->pg_error;
+
+	if (pagecount <= ARRAY_SIZE(pg_array->page_array))
+		pg_array->pagevec = pg_array->page_array;
+	else {
+		pg_array->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_KERNEL);
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

