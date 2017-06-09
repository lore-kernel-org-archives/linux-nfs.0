Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60890 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751562AbdFIPDk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Jun 2017 11:03:40 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix initialization of nfs_page_array->npages
Date: Fri,  9 Jun 2017 11:03:23 -0400
Message-Id: <a0aadd8ba44801d294fb919412c85f6b39bea852.1497020554.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 8ef9b0b9e1c0 open-coded nfs_pgarray_set(), and left out the
initialization of the nfs_page_array's npages.  This mistake didn't show up
until testing with block layouts, and there shows that all pNFS reads
return -EIO.

Fixes: 8ef9b0b9e1c0 ("NFS: move nfs_pgarray_set() to open code")
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/pagelist.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ad92b401326c..7ddba5022948 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -779,6 +779,7 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 	gfp_t gfp_flags = GFP_KERNEL;
 
 	pagecount = nfs_page_array_len(mirror->pg_base, mirror->pg_count);
+	pg_array->npages = pagecount;
 
 	if (pagecount <= ARRAY_SIZE(pg_array->page_array))
 		pg_array->pagevec = pg_array->page_array;
-- 
2.9.3

