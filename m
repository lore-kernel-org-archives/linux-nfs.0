Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.122]:50086 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648Ab0J1OKj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 10:10:39 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: [PATCH] nfs: handle lock context allocation failures in nfs_create_request
Date: Thu, 28 Oct 2010 10:10:37 -0400
Message-Id: <1288275037-22816-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

nfs_get_lock_context can return NULL on an allocation failure.

Reported-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/pagelist.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 9194902..137b549 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -65,6 +65,13 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	if (req == NULL)
 		return ERR_PTR(-ENOMEM);
 
+	/* get lock context early so we can deal with alloc failures */
+	req->wb_lock_context = nfs_get_lock_context(ctx);
+	if (req->wb_lock_context == NULL) {
+		nfs_page_free(req);
+		return ERR_PTR(-ENOMEM);
+	}
+
 	/* Initialize the request struct. Initially, we assume a
 	 * long write-back delay. This will be adjusted in
 	 * update_nfs_request below if the region is not locked. */
@@ -79,7 +86,6 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
 	req->wb_context = get_nfs_open_context(ctx);
-	req->wb_lock_context = nfs_get_lock_context(ctx);
 	kref_init(&req->wb_kref);
 	return req;
 }
-- 
1.7.2.3

