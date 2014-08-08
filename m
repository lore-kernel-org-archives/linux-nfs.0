Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:37856 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663AbaHHPBN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2014 11:01:13 -0400
Received: by mail-ie0-f180.google.com with SMTP id at20so6538402iec.39
        for <linux-nfs@vger.kernel.org>; Fri, 08 Aug 2014 08:01:12 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 4/5] nfs: fix error handling in lock_and_join_requests
Date: Fri,  8 Aug 2014 11:00:56 -0400
Message-Id: <1407510057-6881-5-git-send-email-dros@primarydata.com>
In-Reply-To: <1407510057-6881-1-git-send-email-dros@primarydata.com>
References: <1407510057-6881-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes handling of errors from nfs_page_group_lock in
nfs_lock_and_join_requests.  It now releases the inode lock and the
reference to the head request.

Reported-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>

---
 fs/nfs/write.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 321e561..0e3186b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -480,8 +480,11 @@ try_again:
 
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
1.8.5.2 (Apple Git-48)

