Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f46.google.com ([209.85.215.46]:46272 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732AbaGZL7o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Jul 2014 07:59:44 -0400
From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: [PATCH] nfs3_list_one_acl(): check get_acl() result with IS_ERR_OR_NULL
Date: Sat, 26 Jul 2014 14:58:01 +0300
Message-Id: <1406375881-18837-1-git-send-email-andrey.krieger.utkin@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There was a check for result being not NULL. But get_acl() may return
NULL, or ERR_PTR, or actual pointer.
The purpose of the function where current change is done is to "list
ACLs only when they are available", so any error condition of get_acl()
mustn't be elevated, and returning 0 there is still valid.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=81111
Signed-off-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>
---
 fs/nfs/nfs3acl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 8f854dd..d0fec26 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -256,7 +256,7 @@ nfs3_list_one_acl(struct inode *inode, int type, const char *name, void *data,
 	char *p = data + *result;
 
 	acl = get_acl(inode, type);
-	if (!acl)
+	if (IS_ERR_OR_NULL(acl))
 		return 0;
 
 	posix_acl_release(acl);
-- 
2.0.0

