Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35761 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbcFJPon (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2016 11:44:43 -0400
Received: by mail-it0-f68.google.com with SMTP id e5so2197486ith.2
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2016 08:44:42 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix a double page unlock
Date: Fri, 10 Jun 2016 11:44:14 -0400
Message-Id: <1465573454-79785-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 0bcbf039f6b2, nfs_readpage_release() has been used to
unlock the page in the read code.

Fixes: 0bcbf039f6b2 ("nfs: handle request add failure properly")
Cc: stable@vger.kernel.org # v4.5+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/read.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 6776d7a7839e..572e5b3b06f1 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -367,13 +367,13 @@ readpage_async_filler(void *data, struct page *page)
 		nfs_list_remove_request(new);
 		nfs_readpage_release(new);
 		error = desc->pgio->pg_error;
-		goto out_unlock;
+		goto out;
 	}
 	return 0;
 out_error:
 	error = PTR_ERR(new);
-out_unlock:
 	unlock_page(page);
+out:
 	return error;
 }
 
-- 
2.5.5

