Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38464 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934723AbdDSOLm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Apr 2017 10:11:42 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] NFS: Use GFP_NOIO for two allocations in writeback
Date: Wed, 19 Apr 2017 10:11:33 -0400
Message-Id: <01bf89b13b51faa8b9adcd3a5e09eea55b8d9827.1492611057.git.bcodding@redhat.com>
In-Reply-To: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
References: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prevent a deadlock that can occur if we wait on allocations
that try to write back our pages.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/pagelist.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 6e629b856a00..cd6ec9bdd1c7 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -29,13 +29,14 @@
 static struct kmem_cache *nfs_page_cachep;
 static const struct rpc_call_ops nfs_pgio_common_ops;
 
-static bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int pagecount)
+static bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int pagecount,
+					gfp_t gfp_flags)
 {
 	p->npages = pagecount;
 	if (pagecount <= ARRAY_SIZE(p->page_array))
 		p->pagevec = p->page_array;
 	else {
-		p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_KERNEL);
+		p->pagevec = kcalloc(pagecount, sizeof(struct page *), gfp_flags);
 		if (!p->pagevec)
 			p->npages = 0;
 	}
@@ -681,6 +682,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 {
 	struct nfs_pgio_mirror *new;
 	int i;
+	gfp_t gfp_flags = GFP_KERNEL;
 
 	desc->pg_moreio = 0;
 	desc->pg_inode = inode;
@@ -700,8 +702,10 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	if (pg_ops->pg_get_mirror_count) {
 		/* until we have a request, we don't have an lseg and no
 		 * idea how many mirrors there will be */
+		if (desc->pg_rw_ops->rw_mode == FMODE_WRITE)
+			gfp_flags = GFP_NOIO;
 		new = kcalloc(NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX,
-			      sizeof(struct nfs_pgio_mirror), GFP_KERNEL);
+			      sizeof(struct nfs_pgio_mirror), gfp_flags);
 		desc->pg_mirrors_dynamic = new;
 		desc->pg_mirrors = new;
 
@@ -755,9 +759,12 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 	struct list_head *head = &mirror->pg_list;
 	struct nfs_commit_info cinfo;
 	unsigned int pagecount, pageused;
+	gfp_t gfp_flags = GFP_KERNEL;
 
 	pagecount = nfs_page_array_len(mirror->pg_base, mirror->pg_count);
-	if (!nfs_pgarray_set(&hdr->page_array, pagecount)) {
+	if (desc->pg_rw_ops->rw_mode == FMODE_WRITE)
+		gfp_flags = GFP_NOIO;
+	if (!nfs_pgarray_set(&hdr->page_array, pagecount, gfp_flags)) {
 		nfs_pgio_error(hdr);
 		desc->pg_error = -ENOMEM;
 		return desc->pg_error;
-- 
2.9.3

