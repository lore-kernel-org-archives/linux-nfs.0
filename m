Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:38282 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030508Ab2I1TjN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Sep 2012 15:39:13 -0400
Received: by mail-qa0-f46.google.com with SMTP id c26so180207qad.19
        for <linux-nfs@vger.kernel.org>; Fri, 28 Sep 2012 12:39:11 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsdcld: fix segfault in sqlite debug logging
Date: Fri, 28 Sep 2012 15:39:00 -0400
Message-Id: <1348861140-27036-1-git-send-email-jlayton@redhat.com>
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
1.7.11.4

