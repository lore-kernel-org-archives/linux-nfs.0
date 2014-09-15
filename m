Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:47201 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414AbaIOSPB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 14:15:01 -0400
Received: by mail-ig0-f175.google.com with SMTP id h15so4410591igd.8
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 11:15:00 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 10/14] nfs: use blocking page_group_lock in add_request
Date: Mon, 15 Sep 2014 14:14:41 -0400
Message-Id: <1410804885-17228-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1410804885-17228-10-git-send-email-trond.myklebust@primarydata.com>
References: <1410804885-17228-1-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-2-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-3-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-4-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-5-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-6-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-7-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-8-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-9-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

commit bfd484a5606d6a0379a0a2f04251b1e5c1f8995c upstream.

__nfs_pageio_add_request was calling nfs_page_group_lock nonblocking, but
this can return -EAGAIN which would end up passing -EIO to the application.

There is no reason not to block in this path, so change the two calls to
do so. Also, there is no need to check the return value of
nfs_page_group_lock when nonblock=false, so remove the error handling code.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index c27a05c27c11..ab96711d518f 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -873,13 +873,8 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
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
@@ -901,11 +896,7 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
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
1.9.3

