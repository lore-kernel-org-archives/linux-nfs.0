Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:38823 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932130AbdGSWKV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 18:10:21 -0400
Received: by mail-it0-f68.google.com with SMTP id a62so848977itd.5
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:10:21 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 18/20] NFS: Fix up nfs_page_group_covers_page()
Date: Wed, 19 Jul 2017 18:09:53 -0400
Message-Id: <20170719220955.58210-19-trond.myklebust@primarydata.com>
In-Reply-To: <20170719220955.58210-18-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
 <20170719220955.58210-2-trond.myklebust@primarydata.com>
 <20170719220955.58210-3-trond.myklebust@primarydata.com>
 <20170719220955.58210-4-trond.myklebust@primarydata.com>
 <20170719220955.58210-5-trond.myklebust@primarydata.com>
 <20170719220955.58210-6-trond.myklebust@primarydata.com>
 <20170719220955.58210-7-trond.myklebust@primarydata.com>
 <20170719220955.58210-8-trond.myklebust@primarydata.com>
 <20170719220955.58210-9-trond.myklebust@primarydata.com>
 <20170719220955.58210-10-trond.myklebust@primarydata.com>
 <20170719220955.58210-11-trond.myklebust@primarydata.com>
 <20170719220955.58210-12-trond.myklebust@primarydata.com>
 <20170719220955.58210-13-trond.myklebust@primarydata.com>
 <20170719220955.58210-14-trond.myklebust@primarydata.com>
 <20170719220955.58210-15-trond.myklebust@primarydata.com>
 <20170719220955.58210-16-trond.myklebust@primarydata.com>
 <20170719220955.58210-17-trond.myklebust@primarydata.com>
 <20170719220955.58210-18-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up the test in nfs_page_group_covers_page(). The simplest implementation
is to check that we have a set of intersecting or contiguous subrequests
that connect page offset 0 to nfs_page_length(req->wb_page).

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0f418d825185..759e37d26acf 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -243,9 +243,6 @@ nfs_page_group_search_locked(struct nfs_page *head, unsigned int page_offset)
 {
 	struct nfs_page *req;
 
-	WARN_ON_ONCE(head != head->wb_head);
-	WARN_ON_ONCE(!test_bit(PG_HEADLOCK, &head->wb_head->wb_flags));
-
 	req = head;
 	do {
 		if (page_offset >= req->wb_pgbase &&
@@ -273,18 +270,15 @@ static bool nfs_page_group_covers_page(struct nfs_page *req)
 
 	nfs_page_group_lock(req);
 
-	do {
+	for (;;) {
 		tmp = nfs_page_group_search_locked(req->wb_head, pos);
-		if (tmp) {
-			/* no way this should happen */
-			WARN_ON_ONCE(tmp->wb_pgbase != pos);
-			pos += tmp->wb_bytes - (pos - tmp->wb_pgbase);
-		}
-	} while (tmp && pos < len);
+		if (!tmp)
+			break;
+		pos = tmp->wb_pgbase + tmp->wb_bytes;
+	}
 
 	nfs_page_group_unlock(req);
-	WARN_ON_ONCE(pos > len);
-	return pos == len;
+	return pos >= len;
 }
 
 /* We can set the PG_uptodate flag if we see that a write request
-- 
2.13.3

