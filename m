Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay109.isp.belgacom.be ([195.238.20.136]:21120 "EHLO
        mailrelay109.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965256AbdDZSpU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 14:45:20 -0400
From: Fabian Frederick <fabf@skynet.be>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        fabf@skynet.be
Subject: [PATCH V2 linux-next] nfs: kmap can't fail
Date: Wed, 26 Apr 2017 20:45:16 +0200
Message-Id: <20170426184516.21784-1-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove NULL test on kmap()

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
V2: Remove ptr and return kmap(page) directly
(Suggested by Anna Schumaker)

 fs/nfs/dir.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3a188cb..12ed806b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -175,13 +175,9 @@ typedef struct {
 static
 struct nfs_cache_array *nfs_readdir_get_array(struct page *page)
 {
-	void *ptr;
 	if (page == NULL)
 		return ERR_PTR(-EIO);
-	ptr = kmap(page);
-	if (ptr == NULL)
-		return ERR_PTR(-ENOMEM);
-	return ptr;
+	return kmap(page);
 }
 
 static
-- 
2.9.3

