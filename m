Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48560 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756543AbdDRPkM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Apr 2017 11:40:12 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Use GFP_NOIO for two allocations in writeback
Date: Tue, 18 Apr 2017 11:40:10 -0400
Message-Id: <8145bc699493a8ff826f00333b602d2594fb697c.1492529938.git.bcodding@redhat.com>
In-Reply-To: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
References: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
In-Reply-To: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
References: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prevent a deadlock that can occur if we wait on allocations
that try to write back our pages.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/pagelist.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 19eaae0dee51..fa2924ce5a78 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -668,6 +668,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 {
 	struct nfs_pgio_mirror *new;
 	int i;
+	gfp_t gfp_flags = GFP_KERNEL;
 
 	desc->pg_moreio = 0;
 	desc->pg_inode = inode;
@@ -687,8 +688,10 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
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
 
@@ -743,13 +746,16 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 	struct nfs_commit_info cinfo;
 	struct nfs_page_array *pg_array = &hdr->page_array;
 	unsigned int pagecount, pageused;
+	gfp_t gfp_flags = GFP_KERNEL;
 
 	pagecount = nfs_page_array_len(mirror->pg_base, mirror->pg_count);
 
 	if (pagecount <= ARRAY_SIZE(pg_array->page_array))
 		pg_array->pagevec = pg_array->page_array;
 	else {
-		pg_array->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_KERNEL);
+		if (desc->pg_rw_ops->rw_mode == FMODE_WRITE)
+			gfp_flags = GFP_NOIO;
+		pg_array->pagevec = kcalloc(pagecount, sizeof(struct page *), gfp_flags);
 		if (!pg_array->pagevec) {
 			pg_array->npages = 0;
 			nfs_pgio_error(hdr);
-- 
2.9.3

