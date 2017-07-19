Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36414 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755272AbdGSWKK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 18:10:10 -0400
Received: by mail-it0-f65.google.com with SMTP id r9so27486ita.3
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:10:10 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 08/20] NFS: Don't unlock writebacks before declaring PG_WB_END
Date: Wed, 19 Jul 2017 18:09:43 -0400
Message-Id: <20170719220955.58210-9-trond.myklebust@primarydata.com>
In-Reply-To: <20170719220955.58210-8-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
 <20170719220955.58210-2-trond.myklebust@primarydata.com>
 <20170719220955.58210-3-trond.myklebust@primarydata.com>
 <20170719220955.58210-4-trond.myklebust@primarydata.com>
 <20170719220955.58210-5-trond.myklebust@primarydata.com>
 <20170719220955.58210-6-trond.myklebust@primarydata.com>
 <20170719220955.58210-7-trond.myklebust@primarydata.com>
 <20170719220955.58210-8-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't want nfs_lock_and_join_requests() to start fiddling with
the request before the call to nfs_page_group_sync_on_bit().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 84b6818e5278..bb38c881fc48 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -335,8 +335,11 @@ static void nfs_end_page_writeback(struct nfs_page *req)
 {
 	struct inode *inode = page_file_mapping(req->wb_page)->host;
 	struct nfs_server *nfss = NFS_SERVER(inode);
+	bool is_done;
 
-	if (!nfs_page_group_sync_on_bit(req, PG_WB_END))
+	is_done = nfs_page_group_sync_on_bit(req, PG_WB_END);
+	nfs_unlock_request(req);
+	if (!is_done)
 		return;
 
 	end_page_writeback(req->wb_page);
@@ -596,7 +599,6 @@ nfs_lock_and_join_requests(struct page *page)
 
 static void nfs_write_error_remove_page(struct nfs_page *req)
 {
-	nfs_unlock_request(req);
 	nfs_end_page_writeback(req);
 	generic_error_remove_page(page_file_mapping(req->wb_page),
 				  req->wb_page);
@@ -1019,7 +1021,6 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 remove_req:
 		nfs_inode_remove_request(req);
 next:
-		nfs_unlock_request(req);
 		nfs_end_page_writeback(req);
 		nfs_release_request(req);
 	}
@@ -1406,7 +1407,6 @@ static void nfs_redirty_request(struct nfs_page *req)
 {
 	nfs_mark_request_dirty(req);
 	set_bit(NFS_CONTEXT_RESEND_WRITES, &req->wb_context->flags);
-	nfs_unlock_request(req);
 	nfs_end_page_writeback(req);
 	nfs_release_request(req);
 }
-- 
2.13.3

