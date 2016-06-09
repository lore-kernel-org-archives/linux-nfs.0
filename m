Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36055 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154AbcFIPpb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2016 11:45:31 -0400
From: Weston Andros Adamson <dros@monkey.org>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>,
        stable@vger.kernel.org
Subject: [PATCH] pnfs_nfs: fix _cancel_empty_pagelist
Date: Thu,  9 Jun 2016 11:45:26 -0400
Message-Id: <1465487126-1899-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_generic_commit_cancel_empty_pagelist calls nfs_commitdata_release,
but that is wrong: nfs_commitdata_release puts the open context, something
that isn't valid until nfs_init_commit is called, which is never the case
when pnfs_generic_commit_cancel_empty_pagelist is called.

This was introduced in "nfs: avoid race that crashes nfs_init_commit".

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Cc: stable@vger.kernel.org
---

This is fix to the issue I brought up on the list last week.

It fixes a bug I introduced in the last "fix":

"nfs: avoid race that crashes nfs_init_commit"

So it should be included in the stable releases that patch was sent to.

 -dros

 fs/nfs/pnfs_nfs.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 0dfc476da3e1..b38e3c0dc790 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -247,7 +247,11 @@ void pnfs_fetch_commit_bucket_list(struct list_head *pages,
 }
 
 /* Helper function for pnfs_generic_commit_pagelist to catch an empty
- * page list. This can happen when two commits race. */
+ * page list. This can happen when two commits race.
+ *
+ * This must be called instead of nfs_init_commit - call one or the other, but
+ * not both!
+ */
 static bool
 pnfs_generic_commit_cancel_empty_pagelist(struct list_head *pages,
 					  struct nfs_commit_data *data,
@@ -256,7 +260,11 @@ pnfs_generic_commit_cancel_empty_pagelist(struct list_head *pages,
 	if (list_empty(pages)) {
 		if (atomic_dec_and_test(&cinfo->mds->rpcs_out))
 			wake_up_atomic_t(&cinfo->mds->rpcs_out);
-		nfs_commitdata_release(data);
+		/* don't call nfs_commitdata_release - it tries to put
+		 * the open_context which is not acquired until nfs_init_commit
+		 * which has not been called on @data */
+		WARN_ON_ONCE(data->context);
+		nfs_commit_free(data);
 		return true;
 	}
 
-- 
2.6.4 (Apple Git-63)

