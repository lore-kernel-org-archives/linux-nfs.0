From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/37] NFS: Fix a preemption count leak in
	nfs_update_request
Date: Thu, 12 Jun 2008 15:22:00 -0400
Message-ID: <20080612192200.24528.31958.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Nick Piggin <npiggin@suse.de>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64822 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754688AbYFLTd6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:33:58 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The commit 2785259631697ebb0749a3782cca206e2e542939 (nfs: use GFP_NOFS
preloads for radix-tree insertion) appears to have introduced a bug:
We only want to call radix_tree_preload() once after creating a request.
Calling it every time we loop after we created the request, will cause
preemption count leaks.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Nick Piggin <npiggin@suse.de>
---

 fs/nfs/write.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 6d8ace3..c2dd219 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -584,13 +584,6 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 		/* Loop over all inode entries and see if we find
 		 * A request for the page we wish to update
 		 */
-		if (new) {
-			if (radix_tree_preload(GFP_NOFS)) {
-				nfs_release_request(new);
-				return ERR_PTR(-ENOMEM);
-			}
-		}
-
 		spin_lock(&inode->i_lock);
 		req = nfs_page_find_request_locked(page);
 		if (req) {
@@ -630,6 +623,10 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 		new = nfs_create_request(ctx, inode, page, offset, bytes);
 		if (IS_ERR(new))
 			return new;
+		if (radix_tree_preload(GFP_NOFS)) {
+			nfs_release_request(new);
+			return ERR_PTR(-ENOMEM);
+		}
 	}
 
 	/* We have a request for our page.

