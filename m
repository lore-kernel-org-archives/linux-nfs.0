Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33109 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdDLRA6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Apr 2017 13:00:58 -0400
Received: by mail-io0-f194.google.com with SMTP id k87so7900869ioi.0
        for <linux-nfs@vger.kernel.org>; Wed, 12 Apr 2017 10:00:57 -0700 (PDT)
Received: from localhost.localdomain.localdomain (c-68-40-188-1.hsd1.mi.comcast.net. [68.40.188.1])
        by smtp.gmail.com with ESMTPSA id f19sm2667411itf.19.2017.04.12.10.00.56
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 10:00:56 -0700 (PDT)
From: Fred Isaman <fred.isaman@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix use after free in write error path
Date: Wed, 12 Apr 2017 13:00:46 -0400
Message-Id: <1492016446-55020-1-git-send-email-fred.isaman@gmail.com>
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

