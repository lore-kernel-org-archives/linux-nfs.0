Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33971 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751118AbdGLXLG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 19:11:06 -0400
Received: by mail-it0-f65.google.com with SMTP id o202so4452006itc.1
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 16:11:06 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/4] NFS: Fix a COMMIT race in pNFS
Date: Wed, 12 Jul 2017 19:10:56 -0400
Message-Id: <20170712231059.32293-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170712231059.32293-1-trond.myklebust@primarydata.com>
References: <20170712231059.32293-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must make sure that cinfo->ds->nwritten is in sync with the
commit list, since it is checked as part of pnfs_scan_commit_lists().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index d40755a0984b..3e6de85faf42 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -159,13 +159,18 @@ void pnfs_generic_recover_commit_reqs(struct list_head *dst,
 {
 	struct pnfs_commit_bucket *b;
 	struct pnfs_layout_segment *freeme;
+	int nwritten;
 	int i;
 
 	lockdep_assert_held(&cinfo->inode->i_lock);
 restart:
 	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
-		if (pnfs_generic_transfer_commit_list(&b->written, dst,
-						      cinfo, 0)) {
+		nwritten = pnfs_generic_transfer_commit_list(&b->written,
+				dst, cinfo, 0);
+		if (!nwritten)
+			continue;
+		cinfo->ds->nwritten -= nwritten;
+		if (list_empty(&b->written)) {
 			freeme = b->wlseg;
 			b->wlseg = NULL;
 			spin_unlock(&cinfo->inode->i_lock);
@@ -174,7 +179,6 @@ void pnfs_generic_recover_commit_reqs(struct list_head *dst,
 			goto restart;
 		}
 	}
-	cinfo->ds->nwritten = 0;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_recover_commit_reqs);
 
-- 
2.13.0

