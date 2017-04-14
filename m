Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34073 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752046AbdDNSYb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Apr 2017 14:24:31 -0400
Received: by mail-it0-f67.google.com with SMTP id 193so18735itm.1
        for <linux-nfs@vger.kernel.org>; Fri, 14 Apr 2017 11:24:31 -0700 (PDT)
From: Fred Isaman <fred.isaman@gmail.com>
To: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH] NFS: Fix use after free in write error path
Date: Fri, 14 Apr 2017 14:24:28 -0400
Message-Id: <1492194268-77154-1-git-send-email-fred.isaman@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
---
 fs/nfs/write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index abb2c8a..3d1c284 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -548,9 +548,9 @@ static void nfs_write_error_remove_page(struct nfs_page *req)
 {
 	nfs_unlock_request(req);
 	nfs_end_page_writeback(req);
-	nfs_release_request(req);
 	generic_error_remove_page(page_file_mapping(req->wb_page),
 				  req->wb_page);
+	nfs_release_request(req);
 }
 
 /*
-- 
2.7.4

