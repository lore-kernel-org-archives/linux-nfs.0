Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:50610 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759931Ab2JYRVw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2012 13:21:52 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so2161469vbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 25 Oct 2012 10:21:51 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/9] nfsdcltrack: fix segfault in sqlite debug logging
Date: Thu, 25 Oct 2012 13:21:35 -0400
Message-Id: <1351185703-14191-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351185703-14191-1-git-send-email-jlayton@redhat.com>
References: <1351185703-14191-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One too few arguments...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcld/sqlite.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index bb2519d..fc882c6 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -320,7 +320,7 @@ sqlite_check_client(const unsigned char *clname, const size_t namelen)
 	}
 
 	ret = sqlite3_column_int(stmt, 0);
-	xlog(D_GENERAL, "%s: select returned %d rows", ret);
+	xlog(D_GENERAL, "%s: select returned %d rows", __func__, ret);
 	if (ret != 1) {
 		ret = -EACCES;
 		goto out_err;
-- 
1.7.11.7

