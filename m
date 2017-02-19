Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35988 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751067AbdBSCI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 18 Feb 2017 21:08:26 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/6] NFSv4: minor getacl cleanup
Date: Sat, 18 Feb 2017 21:07:48 -0500
Message-Id: <1487470070-32358-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1487470070-32358-1-git-send-email-bfields@redhat.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4proc.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a4e33e519f6e..eb6c34db9a79 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5134,11 +5134,9 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 out_ok:
 	ret = res.acl_len;
 out_free:
-	for (i = 0; i < npages; i++)
-		if (pages[i])
-			__free_page(pages[i]);
-	if (res.acl_scratch)
-		__free_page(res.acl_scratch);
+	for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
+		__free_page(pages[i]);
+	__free_page(res.acl_scratch);
 	return ret;
 }
 
-- 
2.9.3

