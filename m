Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:37552 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbdHCNpi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:38 -0400
Received: by mail-it0-f68.google.com with SMTP id 77so1306990itj.4
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 04/28] NFS: Ensure we always dereference the page head last
Date: Thu,  3 Aug 2017 09:44:59 -0400
Message-Id: <20170803134523.4922-5-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-4-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes a race with nfs_page_group_sync_on_bit() whereby the
call to wake_up_bit() in nfs_page_group_unlock() could occur after
the page header had been freed.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index de9066a92c0d..a6f2bbd709ba 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -306,14 +306,11 @@ static void
 nfs_page_group_destroy(struct kref *kref)
 {
 	struct nfs_page *req = container_of(kref, struct nfs_page, wb_kref);
+	struct nfs_page *head = req->wb_head;
 	struct nfs_page *tmp, *next;
 
-	/* subrequests must release the ref on the head request */
-	if (req->wb_head != req)
-		nfs_release_request(req->wb_head);
-
 	if (!nfs_page_group_sync_on_bit(req, PG_TEARDOWN))
-		return;
+		goto out;
 
 	tmp = req;
 	do {
@@ -324,6 +321,10 @@ nfs_page_group_destroy(struct kref *kref)
 		nfs_free_request(tmp);
 		tmp = next;
 	} while (tmp != req);
+out:
+	/* subrequests must release the ref on the head request */
+	if (head != req)
+		nfs_release_request(head);
 }
 
 /**
-- 
2.13.3

