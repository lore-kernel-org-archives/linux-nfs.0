Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay105.isp.belgacom.be ([195.238.20.132]:26474 "EHLO
        mailrelay105.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1432685AbdDYSKx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Apr 2017 14:10:53 -0400
From: Fabian Frederick <fabf@skynet.be>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        fabf@skynet.be
Subject: [PATCH 1/1 linux-next] nfs: kmap can't fail
Date: Tue, 25 Apr 2017 20:10:33 +0200
Message-Id: <20170425181033.1892-1-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove NULL test on kmap()

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 fs/nfs/dir.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3a188cb..f89e54c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -179,8 +179,6 @@ struct nfs_cache_array *nfs_readdir_get_array(struct page *page)
 	if (page == NULL)
 		return ERR_PTR(-EIO);
 	ptr = kmap(page);
-	if (ptr == NULL)
-		return ERR_PTR(-ENOMEM);
 	return ptr;
 }
 
-- 
2.9.3

