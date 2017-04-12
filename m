Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f193.google.com ([209.85.213.193]:33456 "EHLO
        mail-yb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752851AbdDLVBO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Apr 2017 17:01:14 -0400
Received: by mail-yb0-f193.google.com with SMTP id 206so1612314ybe.0
        for <linux-nfs@vger.kernel.org>; Wed, 12 Apr 2017 14:01:14 -0700 (PDT)
Received: from localhost.localdomain.localdomain (99-8-84-98.lightspeed.livnmi.sbcglobal.net. [99.8.84.98])
        by smtp.gmail.com with ESMTPSA id b15sm9170076ywb.62.2017.04.12.14.01.12
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 14:01:12 -0700 (PDT)
From: Fred Isaman <fred.isaman@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix use after free in write error path
Date: Wed, 12 Apr 2017 17:01:11 -0400
Message-Id: <1492030871-56107-1-git-send-email-fred.isaman@gmail.com>
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

