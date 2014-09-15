Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:47157 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226AbaIOSPD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 14:15:03 -0400
Received: by mail-ie0-f180.google.com with SMTP id rd18so5130749iec.11
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 11:15:02 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 11/14] nfs: fix error handling in lock_and_join_requests
Date: Mon, 15 Sep 2014 14:14:42 -0400
Message-Id: <1410804885-17228-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1410804885-17228-11-git-send-email-trond.myklebust@primarydata.com>
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
 <1410804885-17228-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

commit 94970014c46223cbcdfbfc67b89596a412f9e3dd upstream.

This fixes handling of errors from nfs_page_group_lock in
nfs_lock_and_join_requests.  It now releases the inode lock and the
reference to the head request.

Reported-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c8eb14eb6659..014d23c7d16e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -455,8 +455,11 @@ try_again:
 
 	/* lock each request in the page group */
 	ret = nfs_page_group_lock(head, true);
-	if (ret < 0)
+	if (ret < 0) {
+		spin_unlock(&inode->i_lock);
+		nfs_release_request(head);
 		return ERR_PTR(ret);
+	}
 	subreq = head;
 	do {
 		/*
-- 
1.9.3

