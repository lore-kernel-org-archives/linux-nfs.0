Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:51172 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113AbaGKOUx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2014 10:20:53 -0400
Received: by mail-ie0-f170.google.com with SMTP id lx4so956780iec.1
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jul 2014 07:20:53 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 1/5] nfs: mark nfs_page reqs with flag for extra ref
Date: Fri, 11 Jul 2014 10:20:45 -0400
Message-Id: <1405088449-11268-2-git-send-email-dros@primarydata.com>
In-Reply-To: <1405088449-11268-1-git-send-email-dros@primarydata.com>
References: <1405088449-11268-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the use of PG_INODE_REF - set it when taking extra reference on
subrequests and take care to only release once for each request.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c | 4 +++-
 fs/nfs/write.c    | 8 ++++++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 6e2c0bc..50e10bb 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -251,8 +251,10 @@ nfs_page_group_init(struct nfs_page *req, struct nfs_page *prev)
 		/* grab extra ref if head request has extra ref from
 		 * the write/commit path to handle handoff between write
 		 * and commit lists */
-		if (test_bit(PG_INODE_REF, &prev->wb_head->wb_flags))
+		if (test_bit(PG_INODE_REF, &prev->wb_head->wb_flags)) {
+			set_bit(PG_INODE_REF, &req->wb_flags);
 			kref_get(&req->wb_kref);
+		}
 	}
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 8534ee5..827b57b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -448,7 +448,9 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 		set_page_private(req->wb_page, (unsigned long)req);
 	}
 	nfsi->npages++;
-	set_bit(PG_INODE_REF, &req->wb_flags);
+	/* this a head request for a page group - mark it as having an
+	 * extra reference so sub groups can follow suit */
+	WARN_ON(test_and_set_bit(PG_INODE_REF, &req->wb_flags));
 	kref_get(&req->wb_kref);
 	spin_unlock(&inode->i_lock);
 }
@@ -474,7 +476,9 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 		nfsi->npages--;
 		spin_unlock(&inode->i_lock);
 	}
-	nfs_release_request(req);
+
+	if (test_and_clear_bit(PG_INODE_REF, &req->wb_flags))
+		nfs_release_request(req);
 }
 
 static void
-- 
1.8.5.2 (Apple Git-48)

