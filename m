Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:33747 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbaHHPBM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2014 11:01:12 -0400
Received: by mail-ie0-f177.google.com with SMTP id at20so6508187iec.36
        for <linux-nfs@vger.kernel.org>; Fri, 08 Aug 2014 08:01:11 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 3/5] nfs: use blocking page_group_lock in add_request
Date: Fri,  8 Aug 2014 11:00:55 -0400
Message-Id: <1407510057-6881-4-git-send-email-dros@primarydata.com>
In-Reply-To: <1407510057-6881-1-git-send-email-dros@primarydata.com>
References: <1407510057-6881-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

__nfs_pageio_add_request was calling nfs_page_group_lock nonblocking, but
this can return -EAGAIN which would end up passing -EIO to the application.

There is no reason not to block in this path, so change the two calls to
do so. Also, there is no need to check the return value of
nfs_page_group_lock when nonblock=false, so remove the error handling code.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>

---
 fs/nfs/pagelist.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index f393c72..af707e0 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -872,13 +872,8 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	struct nfs_page *subreq;
 	unsigned int bytes_left = 0;
 	unsigned int offset, pgbase;
-	int ret;
 
-	ret = nfs_page_group_lock(req, true);
-	if (ret < 0) {
-		desc->pg_error = ret;
-		return 0;
-	}
+	nfs_page_group_lock(req, false);
 
 	subreq = req;
 	bytes_left = subreq->wb_bytes;
@@ -900,11 +895,7 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			if (desc->pg_recoalesce)
 				return 0;
 			/* retry add_request for this subreq */
-			ret = nfs_page_group_lock(req, true);
-			if (ret < 0) {
-				desc->pg_error = ret;
-				return 0;
-			}
+			nfs_page_group_lock(req, false);
 			continue;
 		}
 
-- 
1.8.5.2 (Apple Git-48)

